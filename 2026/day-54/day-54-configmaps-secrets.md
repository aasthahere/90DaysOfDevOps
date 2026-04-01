# Day 54 – Kubernetes ConfigMaps and Secrets
### Task 1: Create a ConfigMap from Literals
1. Use `kubectl create configmap` with `--from-literal` to create a ConfigMap called `app-config` with keys `APP_ENV=production`, `APP_DEBUG=false`, and `APP_PORT=8080`
    ```kubectl create configmap app-config --from-literals=APP_ENV=production --from-literals=APP_DEBUG=False -from-literals=APP_PORT=8080```
    
2. Inspect it with `kubectl describe configmap app-config` and `kubectl get configmap app-config -o yaml`
   
3. Notice the data is stored as plain text — no encoding, no encryption
   
      **Verify:** Can you see all three key-value pairs?

     + **yes i can all three key-value pairs!!**

<img width="1755" height="575" alt="Screenshot (436)" src="https://github.com/user-attachments/assets/b5e5b218-b071-46fb-8186-8ee9ae79e342" />

---
### Task 2: Create a ConfigMap from a File
1. Write a custom Nginx config file that adds a `/health` endpoint returning "healthy"
 ```
    server {
    listen 80;

    location /health {
        return 200 "healthy";
    }
}
  ```

2. Create a ConfigMap from this file using `kubectl create configmap nginx-config --from-file=default.conf=<your-file>`
           ```kubectl create configmap nginx-config --from-file=default.conf=./default.conf```
   
3. The key name (`default.conf`) becomes the filename when mounted into a Pod

**Verify:** Does `kubectl get configmap nginx-config -o yaml` show the file contents?

 **yes it shows the file content**

<img width="1920" height="475" alt="Screenshot (438)" src="https://github.com/user-attachments/assets/99909552-772d-4c63-98d2-7f75f820a05c" />

 ---

 ### Task 3: Use ConfigMaps in a Pod
1. Write a Pod manifest that uses `envFrom` with `configMapRef` to inject all keys from `app-config` as environment variables. Use a busybox container that prints the values.
  ```YML
apiVersion: v1
kind: Pod
metadata:
  name: busybox-pod
  labels:
    app: busybox
spec:
  containers:
  - name: busybox
    image: busybox:latest
    command: ["sh", "-c", "echo $APP_ENV && echo $APP_DEBUG && echo $APP_PORT && sleep 3600"]
    envFrom:
      - configMapRef:
          name: app-config
 ```
<img width="1828" height="244" alt="Screenshot (439)" src="https://github.com/user-attachments/assets/e24e0f3a-b1ca-481c-8dd3-62716dabd008" />

   
2. Write a second Pod manifest that mounts `nginx-config` as a volume at `/etc/nginx/conf.d`. Use the nginx image.
 ```YML
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pod
spec:
  containers:
  - name: nginx
    image: nginx:latest
    volumeMounts:
    - name: nginx-config-volume
      mountPath: /etc/nginx/conf.d
  volumes:
  - name: nginx-config-volume
    configMap:
      name: nginx-config
 ```
   
3. Test that the mounted config works: `kubectl exec <pod> -- curl -s http://localhost/health`

Use environment variables for simple key-value settings. Use volume mounts for full config files.

**Verify:** Does the `/health` endpoint respond?

 **yes it show the endpoint healthy**
<img width="1868" height="392" alt="Screenshot (440)" src="https://github.com/user-attachments/assets/367f566c-b921-4a62-a9ed-c7738e73619c" />

 ---
 ### Task 4: Create a Secret
1. Use `kubectl create secret generic db-credentials` with `--from-literal` to store `DB_USER=admin` and `DB_PASSWORD=s3cureP@ssw0rd`
    ```kubectl create secret generic db-credentials --from-literal=DB_USER=admin --from-literal=DB_PASSWORD=s3cureP@ssw0rd```
3. Inspect with `kubectl get secret db-credentials -o yaml` — the values are base64-encoded
4. Decode a value: `echo '<base64-value>' | base64 --decode`

**base64 is encoding, not encryption.** Anyone with cluster access can decode Secrets. The real advantages are RBAC separation, tmpfs storage on nodes, and optional encryption at rest.

**Verify:** Can you decode the password back to plaintext?
     + **yes i can decode it**

  <img width="1920" height="422" alt="Screenshot (442)" src="https://github.com/user-attachments/assets/cd60aebb-e092-428a-ab81-5d35a41b11d2" />


---

### Task 5: Use Secrets in a Pod
1. Write a Pod manifest that injects `DB_USER` as an environment variable using `secretKeyRef`
```YML
apiVersion: v1
kind: Pod
metadata:
  name: secret-pod
spec:
  containers:
  - name: nginx
    image: nginx:latest
    env:
    - name: DB_USER
      valueFrom:
        secretKeyRef:
          name: db-credentials
          key: DB_USER
    volumeMounts:
    - name: db-secret-volume
      mountPath: /etc/db-credentials
      readOnly: true
  volumes:
  - name: db-secret-volume
    secret:
      secretName: db-credentials
 ```
    
3. In the same Pod, mount the entire `db-credentials` Secret as a volume at `/etc/db-credentials` with `readOnly: true`
4. Verify: each Secret key becomes a file, and the content is the decoded plaintext value

**Verify:** Are the mounted file values plaintext or base64?
+ **plain text**
   
<img width="1369" height="270" alt="Screenshot (443)" src="https://github.com/user-attachments/assets/81f2d230-5732-4e66-adcd-139638b036c7" />

---

### Task 6: Update a ConfigMap and Observe Propagation
1. Create a ConfigMap `live-config` with a key `message=hello`
     ``` kubectl create configmap live-config --from-literal=message=hello```
    
3. Write a Pod that mounts this ConfigMap as a volume and reads the file in a loop every 5 seconds
```YML
apiVersion: v1
kind: Pod
metadata:
  name: busybox-pod
spec:
  containers:
  - name: busybox
    image: busybox:latest
    command: ["sh", "-c", "while true; do cat /etc/live-config/message; echo ''; sleep 5; done"]
    volumeMounts:
    - name: live-config-volume
      mountPath: /etc/live-config
  volumes:
  - name: live-config-volume
    configMap:
      name: live-config
```

5. Update the ConfigMap: `kubectl patch configmap live-config --type merge -p '{"data":{"message":"world"}}'`
   ```kubectl patch configmap live-config --type merge -p '{"data":{"message":"world"}}'```
   
7. Wait 30-60 seconds — the volume-mounted value updates automatically
8. Environment variables from earlier tasks do NOT update — they are set at pod startup only

**Verify:** Did the volume-mounted value change without a pod restart?

 + **yes the volume mounted change without a pod restart**

 <img width="1920" height="469" alt="Screenshot (446)" src="https://github.com/user-attachments/assets/b9f56883-ccdf-4a04-ba43-21c26d401afa" />

---
   
### Task 7: Clean Up
Delete all pods, ConfigMaps, and Secrets you created.

```
  kubectl delete pod busybox-pod
  kubectl delete configmap app-config
  kubectl delete configmap nginx-config
  kubectl delete configmap live-config
  kubectl delete secret db-credentials
```
<img width="1476" height="498" alt="Screenshot (448)" src="https://github.com/user-attachments/assets/ece217ac-3b88-4c84-8826-86c1bbd0750c" />

---

## Documentation
Create `day-54-configmaps-secrets.md` with:
- What ConfigMaps and Secrets are and when to use each
  
   + ConfigMap stores non-sensitive settings like app port,
   + environment name, or config files anything that is safe to read openly.
   + Secret stores sensitive data like passwords and API keys data that should only be accessed by authorised people.
  
- The difference between environment variables and volume mounts
  
    + Environment variables inject a one-time copy of the value into the container at startup
    + like taking a screenshot of a notice board, the photo never updates.
    + Volume mounts create a live link between the file and the container
    + like a TV screen sharing the board live, it always shows the latest value.
      
- Why base64 is encoding, not encryption
  
  + Base64 just converts data into a different format anyone can decode it freely on Google in seconds,
  + just like reading pig latin. Encryption locks data with a secret key — without the key, nobody can read it, making it truly secure.
    
  
- How ConfigMap updates propagate to volumes but not env vars
   + Volume mount stays live connected to ConfigMap
   + Env variable is just a one time copy taken at pod startup connection breaks after that!

---


