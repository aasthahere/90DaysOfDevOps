# Day 55 – Persistent Volumes (PV) and Persistent Volume Claims (PVC)
### Task 1: See the Problem — Data Lost on Pod Deletion
1. Write a Pod manifest that uses an `emptyDir` volume and writes a timestamped message to `/data/message.txt`
```YML
 apiVersion: v1
kind: Pod
metadata:
  name: busybox-pod
spec:
  containers:
  - name: busybox
    image: busybox
    command: ["sh", "-c", "echo Hello Kuberneties $(date) > /data/message.txt && sleep 3600"]
    volumeMounts:
    - name: data
      mountPath: /data
  volumes:
  - name: data
    emptyDir: {}
  ```

2. Apply it, verify the data exists with `kubectl exec`
     ```kubectl exec busybox-pod -- cat /data/message.txt```
   
4. Delete the Pod, recreate it, check the file again — the old message is gone
      + ```kubectl delete busybox-pod```
      + ```kubetl apply -f task1-pod.yml```

**Verify:** Is the timestamp the same or different after recreation?
      + **its diffrent after creation!!**

<img width="1920" height="252" alt="Screenshot (450)" src="https://github.com/user-attachments/assets/75e75574-afbf-4f90-971b-d688192f6932" />

---

### Task 2: Create a PersistentVolume (Static Provisioning)
1. Write a PV manifest with `capacity: 1Gi`, `accessModes: ReadWriteOnce`, `persistentVolumeReclaimPolicy: Retain`, and `hostPath` pointing to `/tmp/k8s-pv-data`
  ```YML
 
apiVersion: v1
kind: PersistentVolume
metadata:
  name: k8s-pv
spec:
  storageClassName: manual
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  hostPath: 
    path: /tmp/k8s-pv-data

```
     
2. Apply it and check `kubectl get pv` — status should be `Available`
     + ```kubectl apply -f pv.yml```
     + ```kubectl get pv```

Access modes to know:
- `ReadWriteOnce (RWO)` — read-write by a single node
- `ReadOnlyMany (ROX)` — read-only by many nodes
- `ReadWriteMany (RWX)` — read-write by many nodes

`hostPath` is fine for learning, not for production.

**Verify:** What is the STATUS of the PV?
  + **its status is Available**

<img width="1920" height="165" alt="Screenshot (452)" src="https://github.com/user-attachments/assets/3cdf003b-bf8c-4954-861d-41d6c4481f2b" />

---

### Task 3: Create a PersistentVolumeClaim
1. Write a PVC manifest requesting `500Mi` of storage with `ReadWriteOnce` access
 ```YML

apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: k8s-pvc
spec:
  storageClassName: manual
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 500Mi
```
2. Apply it and check both `kubectl get pvc` and `kubectl get pv`
3. Both should show `Bound` — Kubernetes matched them by capacity and access mode

**Verify:** What does the VOLUME column in `kubectl get pvc` show?
  + **it shows the bound status**
<img width="1920" height="292" alt="Screenshot (454)" src="https://github.com/user-attachments/assets/ead1b031-820b-4ea6-8b27-e737941c6a10" />

---

### Task 4: Use the PVC in a Pod — Data That Survives
1. Write a Pod manifest that mounts the PVC at `/data` using `persistentVolumeClaim.claimName`
 ```YML
 apiVersion: v1
kind: Pod
metadata:
  name: task-4-pod
spec:
  containers:
  - name: busybox
    image: busybox
    command: ["sh", "-c", "echo Hello Kubernetes ceated pvc! $(date) >> /data/message.txt && sleep 3600"]
    volumeMounts:
    - name: data
      mountPath: /data
  volumes:
  - name: data
    persistentVolumeClaim:
      claimName: k8s-pvc
  ```
2. Write data to `/data/message.txt`, then delete and recreate the Pod
   + ```kubectl delete task4-pod```
3. Check the file — it should contain data from both Pods
   + ``` kubectl exec task-4-pod -- cat /data/message.txt```
**Verify:** Does the file contain data from both the first and second Pod?
     + **yes its there**
<img width="1920" height="477" alt="Screenshot (455)" src="https://github.com/user-attachments/assets/da7a8f72-c76e-4951-a386-48061554c9e0" />

---
### Task 5: StorageClasses and Dynamic Provisioning
1. Run `kubectl get storageclass` and `kubectl describe storageclass`
2. Note the provisioner, reclaim policy, and volume binding mode
3. With dynamic provisioning, developers only create PVCs — the StorageClass handles PV creation automatically

**Verify:** What is the default StorageClass in your cluster?
     + **If a PVC (PersistentVolumeClaim) does NOT specify a storageClassName, Kubernetes automatically uses the default StorageClass.**
     + **If no default exists → PVC will stay in Pending state.**

<img width="1920" height="484" alt="Screenshot (456)" src="https://github.com/user-attachments/assets/1ecd43c5-87e7-4dd4-b04d-00a066430154" />

---

### Task 6: Dynamic Provisioning
1. Write a PVC manifest that includes `storageClassName: standard` (or your cluster's default)
```YML
apiVersion: v1
kind: Pod
metadata:
  name: task6-pod
spec:
  containers:
  - name: busybox
    image: busybox
    command: ["sh", "-c", "echo Hello you have Task 6 Pod $(date) >> /data/message.txt && sleep 3600"]
    volumeMounts:
    - name: data
      mountPath: /data
  volumes:
  - name: data
    persistentVolumeClaim:
      claimName: task6-pvc
 ```
3. Apply it — a PV should appear automatically in `kubectl get pv`
4. Use this PVC in a Pod, write data, verify it works

**Verify:** How many PVs exist now? Which was manual, which was dynamic?
       + **there is two pv and k8s-pv is manual and task6-pv is standard**
       
<img width="1920" height="256" alt="Screenshot (457)" src="https://github.com/user-attachments/assets/1e53a93c-a33d-44d7-aaf0-d1fe0c135ae5" />

---
### Task 7: Clean Up
1. Delete all pods first
2. Delete PVCs — check `kubectl get pv` to see what happened
3. The dynamic PV is gone (Delete reclaim policy). The manual PV shows `Released` (Retain policy).
4. Delete the remaining PV manually

**Verify:** Which PV was auto-deleted and which was retained? Why?
 + **The task6-PV was dynamically created using a StorageClass with Delete policy,so it got auto-deleted,**
 + **while the manually created K8s-PV had Retain policy, so it moved to Released state instead of deleting**
<img width="1920" height="671" alt="Screenshot (458)" src="https://github.com/user-attachments/assets/7782ad44-8cc1-4b51-abf7-bf948136eae0" />

  --- 
  ## Documentation
- Why containers need persistent storage
    + Containers are ephemeral, meaning their data is lost when the Pod is deleted or crashes.
    + Persistent storage ensures data remains safe beyond the lifecycle of Pods,
    + which is essential for stateful applications like databases and logs.
      
- What PVs and PVCs are and how they relate
    + Persistent Volume (PV) is the actual storage resource in the cluster,
    + while Persistent Volume Claim (PVC) is a request for storage by a user or application.
    + Kubernetes binds a PVC to a suitable PV, allowing applications to use storage without worrying about underlying details.
      
- Static vs dynamic provisioning
   + Static provisioning involves manually creating PVs before they are used.
   + Dynamic provisioning automatically creates PVs when a PVC is requested, using a StorageClass.
     
- Access modes and reclaim policies
   + Access modes define how a volume can be accessed (e.g., ReadWriteOnce, ReadOnlyMany, ReadWriteMany).
   + Reclaim policy determines what happens to the storage after a PVC is deleted (Delete or Retain).

