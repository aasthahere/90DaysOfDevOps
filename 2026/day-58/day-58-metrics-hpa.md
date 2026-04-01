# Day 58 – Metrics Server and Horizontal Pod Autoscaler (HPA)

### Task 1: Install the Metrics Server

1. Check if it is already running: `kubectl get pods -n kube-system | grep metrics-server`
2. If not, install it:
   - Minikube: `minikube addons enable metrics-server`
   - Kind/kubeadm: apply the official manifest from the metrics-server GitHub releases
3. On local clusters, you may need the `--kubelet-insecure-tls` flag (never in production)
4. Wait 60 seconds, then verify: `kubectl top nodes` and `kubectl top pods -A`

**Verify:** What is the current CPU and memory usage of your node?
    + **Current CPU usage: 588m (14%) Current Memory usage: 803Mi (20%)**

  <img width="1493" height="342" alt="Screenshot (506)" src="https://github.com/user-attachments/assets/79d1893c-64a7-4c25-983f-3a9c735b288e" />

---
### Task 2: Explore kubectl top
1. Run `kubectl top nodes`, `kubectl top pods -A`, `kubectl top pods -A --sort-by=cpu`
2. `kubectl top` shows real-time usage, not requests or limits — these are different things
3. Data comes from the Metrics Server, which polls kubelets every 15 seconds

**Verify:** Which pod is using the most CPU right now?
   + **kube-system   kube-apiserver-minikube            149m         192Mi**


  ---
  ### Task 3: Create a Deployment with CPU Requests
1. Write a Deployment manifest using the `registry.k8s.io/hpa-example` image (a CPU-intensive PHP-Apache server)
 ```YML
 apiVersion: apps/v1
kind: Deployment
metadata:
  name: php-apache
spec:
  replicas: 1
  selector:
    matchLabels:
      run: php-apache
  template:
    metadata:
      labels:
        run: php-apache
    spec:
      containers:
      - name: php-apache
        image: registry.k8s.io/hpa-example
        ports:
        - containerPort: 80
        resources:
          requests:
            cpu: 200m
  ```
  
3. Set `resources.requests.cpu: 200m` — HPA needs this to calculate utilization percentages
4. Expose it as a Service: `kubectl expose deployment php-apache --port=80`

Without CPU requests, HPA cannot work — this is the most common HPA setup mistake.

**Verify:** What is the current CPU usage of the Pod?
   + **current cpu usage of my pod is   34m**

<img width="1532" height="632" alt="Screenshot (507)" src="https://github.com/user-attachments/assets/90d0a97c-0d4b-40ce-87aa-c1677461dfbe" />


---


### Task 4: Create an HPA (Imperative)
1. Run: `kubectl autoscale deployment php-apache --cpu-percent=50 --min=1 --max=10`
2. Check: `kubectl get hpa` and `kubectl describe hpa php-apache`
3. TARGETS may show `<unknown>` initially — wait 30 seconds for metrics to arrive

This scales up when average CPU exceeds 50% of requests, and down when it drops below.

**Verify:** What does the TARGETS column show?
    + **its shows cpu: 0%/50%**

<img width="1920" height="369" alt="Screenshot (509)" src="https://github.com/user-attachments/assets/cfb51ec2-455e-4fe2-835d-282714dc89ef" />

---

### Task 5: Generate Load and Watch Autoscaling
1. Start a load generator: `kubectl run load-generator --image=busybox:1.36 --restart=Never -- /bin/sh -c "while true; do wget -q -O- http://php-apache; done"`
2. Watch HPA: `kubectl get hpa php-apache --watch`
3. Over 1-3 minutes, CPU climbs above 50%, replicas increase, CPU stabilizes
4. Stop the load: `kubectl delete pod load-generator`
5. Scale-down is slow (5-minute stabilization window) — you do not need to wait

**Verify:** How many replicas did HPA scale to under load?
   + **HPA scale  4 replicas under the load**

<img width="1515" height="209" alt="Screenshot (510)" src="https://github.com/user-attachments/assets/de5736f5-075d-4297-a3d2-f1daddd77c24" />


---
### Task 6: Create an HPA from YAML (Declarative)
1. Delete the imperative HPA: `kubectl delete hpa php-apache`
2. Write an HPA manifest using `autoscaling/v2` API with CPU target at 50% utilization
 ```YML
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: php-apache
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: php-apache
  minReplicas: 1
  maxReplicas: 5

  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 50

  behavior:
    scaleUp:
      stabilizationWindowSeconds: 0
      policies:
      - type: Percent
        value: 100
        periodSeconds: 15

   scaleDown:
      stabilizationWindowSeconds: 300
      policies:
      - type: Percent
        value: 100
        periodSeconds: 15
  ```
4. Add a `behavior` section to control scale-up speed (no stabilization) and scale-down speed (300 second window)
5. Apply and verify with `kubectl describe hpa`

`autoscaling/v2` supports multiple metrics and fine-grained scaling behavior that the imperative command cannot configure.

**Verify:** What does the `behavior` section control?

 + **The behavior section controls how fast or slow the HPA scales up or scales down pods, including delays and limits on scaling actions.**

<img width="1479" height="703" alt="Screenshot (511)" src="https://github.com/user-attachments/assets/ac45c13d-3ffb-4c0f-92cf-037d59e60d62" />

   <img width="1460" height="328" alt="Screenshot (512)" src="https://github.com/user-attachments/assets/56c5323d-243b-4cfb-9385-1af77eeb92aa" />

---
### Task 7: Clean Up
Delete the HPA, Service, Deployment, and load-generator pod. Leave the Metrics Server installed.

  ```
    kubectl delete hpa php-apache
    kubectl delete svc php-apache
    kubectl delete deployment php-apache
    kubectl delete pod load-generator
```
## Documentation

- What the Metrics Server is and why HPA needs it
     + the Metrics Server is a Kubernetes component that collects resource usage data such as
     + CPU usage ,  Memory usage
     + It gathers metrics from: Kubelets (running on each node) This data is exposed through the Kubernetes API.
 
       ---
        + Why HPA needs Metrics Server
            + The Horizontal Pod Autoscaler (HPA) uses this data to: Monitor CPU or memory usage of pods Make scaling decisions Without Metrics Server:
            + kubectl top will not work HPA cannot calculate utilization Auto-scaling will fail
     ---
  
              
- How HPA calculates desired replicas
  
  + desiredReplicas = currentReplicas × (currentMetricValue / desiredMetricValue)
      + example we have Current replicas = 2 Current CPU usage = 80% Target CPU = 50%
      + desiredReplicas = 2 × (80 / 50) = 3.2 ≈ 3 pods

    ---
    
- The difference between `autoscaling/v1` and `v2`
  ### Difference between autoscaling/v1 and autoscaling/v2

| Feature                  | autoscaling/v1        | autoscaling/v2                          |
|-------------------------|----------------------|-----------------------------------------|
| Metrics support         | CPU only             | CPU, Memory, Custom metrics             |
| Scaling behavior control|  Not available     |  Available (`behavior` field)         |
| Flexibility             | Basic                | Advanced                                |
| Use case                | Simple scaling       | Production-grade scaling                |

---




