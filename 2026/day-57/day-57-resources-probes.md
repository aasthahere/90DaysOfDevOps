# Day 57 – Resource Requests, Limits, and Probes

### Task 1: Resource Requests and Limits
1. Write a Pod manifest with `resources.requests` (cpu: 100m, memory: 128Mi) and `resources.limits` (cpu: 250m, memory: 256Mi)
 ```YML
 apiVersion: v1
kind: Pod
metadata:
  name: resource-demo
spec:
  containers:
  - name: nginx
    image: nginx
    resources:
      requests:
        cpu: "100m"
        memory: "128Mi"
      limits:
        cpu: "250m"
        memory: "256Mi"
   ```

3. Apply and inspect with `kubectl describe pod` — look for the Requests, Limits, and QoS Class sections
4. Since requests and limits differ, the QoS class is `Burstable`. If equal, it would be `Guaranteed`. If missing, `BestEffort`.

CPU is in millicores: `100m` = 0.1 CPU. Memory is in mebibytes: `128Mi`.

**Requests** = guaranteed minimum (scheduler uses this for placement). **Limits** = maximum allowed (kubelet enforces at runtime).

**Verify:** What QoS class does your Pod have?

+ **its have Burstable**

<img width="1497" height="589" alt="Screenshot (494)" src="https://github.com/user-attachments/assets/2ff7e61d-3f4f-46ed-91c6-ef5e672fe2bd" />
<img width="1489" height="612" alt="Screenshot (493)" src="https://github.com/user-attachments/assets/0b885e35-94ad-4c1c-b1d4-8a4691d81d3c" />

---
### Task 2: OOMKilled — Exceeding Memory Limits
1. Write a Pod manifest using the `polinux/stress` image with a memory limit of `100Mi`
```YML
 apiVersion: v1
kind: Pod
metadata:
  name: oom-demo
spec:
  containers:
  - name: stress
    image: polinux/stress
    resources:
      limits:
        memory: "100Mi"
    command: ["stress"]
    args: ["--vm", "1", "--vm-bytes", "200M", "--vm-hang", "1"]
```
    
   
3. Set the stress command to allocate 200M of memory: `command: ["stress"] args: ["--vm", "1", "--vm-bytes", "200M", "--vm-hang", "1"]`
4. Apply and watch — the container gets killed immediately

CPU is throttled when over limit. Memory is killed — no mercy.

Check `kubectl describe pod` for `Reason: OOMKilled` and `Exit Code: 137` (128 + SIGKILL).

**Verify:** What exit code does an OOMKilled container have?
     + **An OOMKilled container exits with code 137, which indicates it was terminated by SIGKILL due to exceeding its memory limit.**
<img width="1449" height="662" alt="Screenshot (504)" src="https://github.com/user-attachments/assets/1e3d7936-274f-4f57-b002-659095d8701b" />

---

### Task 3: Pending Pod — Requesting Too Much
1. Write a Pod manifest requesting `cpu: 100` and `memory: 128Gi`
 ```YML
 apiVersion: v1
kind: Pod
metadata:
  name: oom-demo
spec:
  containers:
  - name: stress
    image: polinux/stress
    resources:
      limits:
        memory: "100Mi"
    command: ["stress"]
    args: ["--vm", "1", "--vm-bytes", "200M", "--vm-hang", "1"]
```
    
3. Apply and check — STATUS stays `Pending` forever
4. Run `kubectl describe pod` and read the Events — the scheduler says exactly why: insufficient resources
   

**Verify:** What event message does the scheduler produce?
   + **its shows 2 insufficient cpu and memory** 

<img width="1546" height="576" alt="Screenshot (499)" src="https://github.com/user-attachments/assets/80269dbe-d7cc-4767-bb02-d58e26f37daf" />

---
### Task 4: Liveness Probe
A liveness probe detects stuck containers. If it fails, Kubernetes restarts the container.

1. Write a Pod manifest with a busybox container that creates `/tmp/healthy` on startup, then deletes it after 30 seconds
 ```YML
apiVersion: v1
kind: Pod
metadata:
  name: liveness-demo
spec:
  containers:
  - name: busybox
    image: busybox
    command:
      - sh
      - -c
      - |
        touch /tmp/healthy
        sleep 30
        rm -f /tmp/healthy
        sleep 600
    livenessProbe:
      exec:
        command:
          - cat
          - /tmp/healthy
      periodSeconds: 5
      failureThreshold: 3
```
3. Add a liveness probe using `exec` that runs `cat /tmp/healthy`, with `periodSeconds: 5` and `failureThreshold: 3`
4. After the file is deleted, 3 consecutive failures trigger a restart. Watch with `kubectl get pod -w`

**Verify:** How many times has the container restarted?

+ **my container is restarted 5 times**

<img width="1594" height="316" alt="Screenshot (500)" src="https://github.com/user-attachments/assets/494b6488-3fc9-41f6-beab-6a171e762028" />

---
### Task 5: Readiness Probe
A readiness probe controls traffic. Failure removes the Pod from Service endpoints but does NOT restart it.

1. Write a Pod manifest with nginx and a `readinessProbe` using `httpGet` on path `/` port `80`
  ```YML
 apiVersion: v1
kind: Pod
metadata:
  name: readiness-demo
  labels:
    app: nginx
spec: 
  containers:
  - name: nginx
    image: nginx
    readinessProbe:
      httpGet:
        path: /
        port: 80
      periodSeconds: 5
      failureThreshold: 3
 ```
 
3. Expose it as a Service: `kubectl expose pod <name> --port=80 --name=readiness-svc`
4. Check `kubectl get endpoints readiness-svc` — the Pod IP is listed
5. Break the probe: `kubectl exec <pod> -- rm /usr/share/nginx/html/index.html`
6. Wait 15 seconds — Pod shows `0/1` READY, endpoints are empty, but the container is NOT restarted

**Verify:** When readiness failed, was the container restarted?
+ **no the container is not restarted!!**
<img width="1530" height="613" alt="Screenshot (501)" src="https://github.com/user-attachments/assets/df6632f5-ff97-45e8-bed8-502c9b32f1d3" />

---

### Task 6: Startup Probe
A startup probe gives slow-starting containers extra time. While it runs, liveness and readiness probes are disabled.
1. Write a Pod manifest where the container takes 20 seconds to start (e.g., `sleep 20 && touch /tmp/started`)
2. Add a `startupProbe` checking for `/tmp/started` with `periodSeconds: 5` and `failureThreshold: 12` (60 second budget)
3. Add a `livenessProbe` that checks the same file — it only kicks in after startup succeeds
```YML
   apiVersion: v1
kind: Pod
metadata:
  name: startup-demo
spec:
  containers:
  - name: busybox
    image: busybox
    command:
      - sh
      - -c
      - |
        sleep 20
        touch /tmp/started
        sleep 300
    startupProbe:
      exec:
        command:
          - cat
          - /tmp/started
      periodSeconds: 5
      failureThreshold: 12
    livenessProbe:
      exec:
        command:
          - cat
          - /tmp/started
      periodSeconds: 5
      failureThreshold: 3
```

**Verify:** What would happen if `failureThreshold` were 2 instead of 12?
   +  **if the failurethreshold were 2 so (2*5)=10 total time will be 10 seconds but**
   +  **app need 20 seconds to start**
   +  Startup probe fails before app is ready Kubernetes will thinks App is broken**
   +  **od goes into CrashLoopBackOff**
     <img width="1146" height="595" alt="Screenshot (502)" src="https://github.com/user-attachments/assets/c827d8a8-35e6-41c6-bd3d-c7ebe602f730" />

---
### Task 7: Clean Up
Delete all pods and services you created.
```
    kubectl delete pod big-request
    kubectl delete pod liveness-demo
    kubectl delete pod oom-demo
    kubectl delete pod readiness-demo
    kubectl delete pod resource-demo
    kubectl delete pod startup-demo

```
---
## Documentation
- Requests vs limits (scheduling vs enforcement)
    + Requests = minimum guaranteed resources for scheduling
    + Limits = maximum resources a container can use
      
---

- What happens when CPU or memory limits are exceeded
     + Memory limit breach causes OOM kill
     + CPU limit breach causes throttling

---

- Liveness vs readiness vs startup probes
  - probes:
      + Probes are health checks configured in Kubernetes to monitor containers
        
  - liveness:
     + Checks if the container is still running properly?
     + If it fails Kubernetes restarts the container
 - readiness:
     + Checks if the container is ready to accept requests
     + If it fails Pod is removed from service (no traffic sent)
     + Container is NOT restarted

  - startup:
     + Used for slow-starting applications
     + While this runs Liveness & Readiness are disabled If it fails container restarted
         
  ---

