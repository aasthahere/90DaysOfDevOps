# Day 56 – Kubernetes StatefulSets

### Task 1: Understand the Problem
1. Create a Deployment with 3 replicas using nginx
 ```YML
 apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.14.2
        ports:
        - containerPort: 80
```
     
3. Check the pod names — they are random (`app-xyz-abc`)

     ```kubectl get pods```
    ***yes they are random*** 
   
5. Delete a pod and notice the replacement gets a different random name

   ```kubectl delete pod -l app=nginx```

This is fine for web servers but not for databases where you need stable identity.

| Feature | Deployment | StatefulSet |
|---|---|---|
| Pod names | Random | Stable, ordered (`app-0`, `app-1`) |
| Startup order | All at once | Ordered: pod-0, then pod-1, then pod-2 |
| Storage | Shared PVC | Each pod gets its own PVC |
| Network identity | No stable hostname | Stable DNS per pod |

Delete the Deployment before moving on.

```kubectl delete deployment nginx-deployment```


**Verify:** Why would random pod names be a problem for a database cluster?
    + ***in database clusters, each pod must have a stable identity and hostname.but With Deployments pods get random names on recreation This breaks Cluster communication Node recognition Data consistency***
<img width="1286" height="582" alt="Screenshot (476)" src="https://github.com/user-attachments/assets/fbdc9ecb-eb15-4f2f-988b-812173de2ada" />

---

Task 2: Create a Headless Service
Write a Service manifest with clusterIP: None — this is a Headless Service

```YML
 apiVersion: v1
kind: Service
metadata:
  name: nginx-service
  labels:
    app: nginx
spec:
  selector:
    app: nginx
  clusterIP: None
  ports:
   - port: 80
     targetPort: 80
```

Set the selector to match the labels you will use on your StatefulSet pods
Apply it and confirm CLUSTER-IP shows None
A Headless Service creates individual DNS entries for each pod instead of load-balancing to one IP. StatefulSets require this.

**Verify:** What does the CLUSTER-IP column show?
 + **cluster-ip colume shows None**
<img width="1499" height="229" alt="Screenshot (477)" src="https://github.com/user-attachments/assets/8d934d97-dfda-41d5-a22a-af6202ea04a3" />

---

### Task 3: Create a StatefulSet
1. Write a StatefulSet manifest with `serviceName` pointing to your Headless Service
 ```YML
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: web
spec:
  serviceName: "nginx-service"
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: registry.k8s.io/nginx-slim:0.21
        ports:
        - containerPort: 80
          name: web
        volumeMounts:  
        - name: www     
          mountPath: /usr/share/nginx/html
  volumeClaimTemplates:
  - metadata:
      name: www
    spec:
      accessModes: [ "ReadWriteOnce" ]
      resources:
        requests:
          storage: 100Mi
 ```
3. Set replicas to 3, use the nginx image
4. Add a `volumeClaimTemplates` section requesting 100Mi of ReadWriteOnce storage
5. Apply and watch: `kubectl get pods -l <your-label> -w`

   + ```kubectl get pods -l app=nginx -w```
     
Observe ordered creation — `web-0` first, then `web-1` after `web-0` is Ready, then `web-2`.

Check the PVCs: `kubectl get pvc` — you should see `web-data-web-0`, `web-data-web-1`, `web-data-web-2` (names follow the pattern `<template-name>-<pod-name>`).

**Verify:** What are the exact pod names and PVC names?
    + pods are: 
        + web-0  
        + web-1   
        + web-2  
    + pvc are:
        + www-web-0
        + www-web-1
        + www-web-2

  
  <img width="1563" height="549" alt="Screenshot (479)" src="https://github.com/user-attachments/assets/b63a7333-9bde-4bfb-beea-66b886e94971" />

---

### Task 4: Stable Network Identity
Each StatefulSet pod gets a DNS name: `<pod-name>.<service-name>.<namespace>.svc.cluster.local`

1. Run a temporary busybox pod and use `nslookup` to resolve `web-0.<your-headless-service>.default.svc.cluster.local`
     + ```kubectl run test-dns --image=busybox:1.28 -it --rm -- sh```
     + ```
       nslookup web-0.nginx-service.default.svc.cluster.local
       nslookup web-1.nginx-service.default.svc.cluster.local
       nslookup web-2.nginx-service.default.svc.cluster.local
       ```
       
3. Do the same for `web-1` and `web-2`
5. Confirm the IPs match `kubectl get pods -o wide`
   + **yes the ip match**
     

**Verify:** Does the nslookup IP match the pod IP?
      + **yes the nslookup ip matched to the pod ip**
      + **reason is Each StatefulSet pod has its own DNS name that directly resolves to its actual pod IP (because of Headless Service)**
<img width="1520" height="732" alt="Screenshot (482)" src="https://github.com/user-attachments/assets/25e3bdae-4374-4ebe-87bc-e2f2501ff0bb" />

---

### Task 5: Stable Storage — Data Survives Pod Deletion
1. Write unique data to each pod: `kubectl exec web-0 -- sh -c "echo 'Data from web-0' > /usr/share/nginx/html/index.html"`
2. Delete `web-0`: `kubectl delete pod web-0`
3. Wait for it to come back, then check the data — it should still be "Data from web-0"

      + ```kubectl exec web-0 -- sh -c "cat /usr/share/nginx/html/index.html"```

The new pod reconnected to the same PVC.

**Verify:** Is the data identical after pod recreation?
   + **yes the data is identical after recreation**

     
  <img width="1503" height="405" alt="Screenshot (485)" src="https://github.com/user-attachments/assets/39ff9760-c6b5-40ff-ae0a-44448fc449f1" />

---
### Task 6: Ordered Scaling
1. Scale up to 5: `kubectl scale statefulset web --replicas=5` — pods create in order (web-3, then web-4)
2. Scale down to 3 — pods terminate in reverse order (web-4, then web-3)
3. Check `kubectl get pvc` — all five PVCs still exist. Kubernetes keeps them on scale-down so data is preserved if you scale back up.

**Verify:** After scaling down, how many PVCs exist?

+ **five pvcs are existing after sacalling down**

<img width="1435" height="377" alt="Screenshot (488)" src="https://github.com/user-attachments/assets/da525f7f-35b6-4e8d-9128-2ca2dd9ac1e7" />

  <img width="1549" height="344" alt="Screenshot (489)" src="https://github.com/user-attachments/assets/bbaca363-f65d-479f-9de5-2ea48cd139e4" />

---
### Task 7: Clean Up
1. Delete the StatefulSet and the Headless Service

    ```kubectl delete statefulset web```
   ```kubectl delete service nginx-service```
   
3. Check `kubectl get pvc` — PVCs are still there (safety feature)

   ```kubectl delete pvc --all```

**Verify:** Were PVCs auto-deleted with the StatefulSet?
    + **no pvcs are not auto-deleted with statefulset becuase to ensure data persistence and prevent accidental data loss.**
    
 <img width="1485" height="592" alt="Screenshot (491)" src="https://github.com/user-attachments/assets/6f084e6c-4cfd-4c1e-953f-3667ebe873e6" />

 ---
 ## Documentation
Create `day-56-statefulsets.md` with:
- What StatefulSets are and when to use them vs Deployments
     + **statefulSet creates pods with stable names and automatically provisions a unique PVC for each pod using volumeClaimTemplates, ensuring persistent identity and storage.**
     + **In deployment the random pods are created and it shared storage and no identity**
- The comparison table
- How Headless Services, stable DNS, and volumeClaimTemplates work
  
 | Feature | Normal Service | Headless Service | StatefulSet |
|--------|--------------|-----------------|-------------|
| IP | One fixed IP (ClusterIP) | No IP (`None`) | Uses Headless Service |
| Traffic | Load balances to any pod | Direct access to specific pod | Direct pod communication |
| Pod Identity | Random names | Random (if not StatefulSet) | Stable (`web-0`, `web-1`) |
| DNS | One DNS → one IP | One DNS → multiple pod IPs | Unique DNS per pod |
| Storage | Shared / none | Same as pods | One PVC per pod |
| Use Case | Web apps (nginx) | Advanced networking | Databases, stateful apps |

---

