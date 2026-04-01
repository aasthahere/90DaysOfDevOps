# Day 60 – Capstone: Deploy WordPress + MySQL on Kubernetes

## Challenge Tasks

### Task 1: Create the Namespace (Day 52)
1. Create a `capstone` namespace
   - ```kubectl create namespace capstone```
     
3. Set it as your default: `kubectl config set-context --current --namespace=capstone`

   

---
### Task 2: Deploy MySQL (Days 54-56)
1. Create a Secret with `MYSQL_ROOT_PASSWORD`, `MYSQL_DATABASE`, `MYSQL_USER`, and `MYSQL_PASSWORD` using `stringData`

```YML
apiVersion: v1
kind: Secret
metadata:
  name: mysql-secret
type: Opaque
stringData:
  MYSQL_ROOT_PASSWORD: rootpass
  MYSQL_DATABASE: wordpress
  MYSQL_USER: wpuser
  MYSQL_PASSWORD: wppass
  ```

   
3. Create a Headless Service (`clusterIP: None`) for MySQL on port 3306
 ```YML
apiVersion: v1
kind: Service
metadata:
  name: mysql
spec:
  clusterIP: None
  selector:
    app: mysql
  ports:
    - port: 3306
  ```
 
5. Create a StatefulSet for MySQL with:
   - Image: `mysql:8.0`
   - `envFrom` referencing the Secret
   - Resource requests (cpu: 250m, memory: 512Mi) and limits (cpu: 500m, memory: 1Gi)
   - A `volumeClaimTemplates` section requesting 1Gi of storage, mounted at `/var/lib/mysql`

 ```YML
 apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: mysql
spec:
  serviceName: mysql
  replicas: 1
  selector:
    matchLabels:
      app: mysql
  template:
    metadata:
      labels:
        app: mysql
    spec:
      containers:
      - name: mysql
        image: mysql:8.0
        ports:
        - containerPort: 3306
        envFrom:
        - secretRef:
            name: mysql-secret
        resources:
          requests:
            cpu: "250m"
            memory: "512Mi"
          limits:
            cpu: "500m"
            memory: "1Gi"
        volumeMounts:
        - name: mysql-storage
          mountPath: /var/lib/mysql
  volumeClaimTemplates:
  - metadata:
      name: mysql-storage
    spec:
      accessModes: ["ReadWriteOnce"]
      resources:
        requests:
          storage: 1Gi
  ```
6. Verify MySQL works: `kubectl exec -it mysql-0 -- mysql -u <user> -p<password> -e "SHOW DATABASES;"`

**Verify:** Can you see the `wordpress` database?

  - yes i can see the database!!
    
<img width="1920" height="1029" alt="Screenshot (534)" src="https://github.com/user-attachments/assets/d69d1b99-b3ed-4e70-990c-0c758c3e5619" />

---

### Task 3: Deploy WordPress (Days 52, 54, 57)
1. Create a ConfigMap with `WORDPRESS_DB_HOST` set to `mysql-0.mysql.capstone.svc.cluster.local:3306` and `WORDPRESS_DB_NAME`
 ```YML
apiVersion: v1
kind: ConfigMap
metadata:
  name: wordpress-config
data:
  WORDPRESS_DB_HOST: mysql-0.mysql.capstone.svc.cluster.local:3306
  WORDPRESS_DB_NAME: wordpress

```
   
3. Create a Deployment with 2 replicas using `wordpress:latest` that:
   - Uses `envFrom` for the ConfigMap
   - Uses `secretKeyRef` for `WORDPRESS_DB_USER` and `WORDPRESS_DB_PASSWORD` from the MySQL Secret
   - Has resource requests and limits
   - Has a liveness probe and readiness probe on `/wp-login.php` port 80
 ```YML
apiVersion: apps/v1
kind: Deployment
metadata:
  name: wordpress
  namespace: capstone
spec:
  replicas: 2
  selector:
    matchLabels:
      app: wordpress
  template:
    metadata:
      labels:
        app: wordpress
    spec:
      containers:
      - name: wordpress
        image: wordpress:latest

        ports:
        - containerPort: 80

        envFrom:
        - configMapRef:
            name: wordpress-config

        env:
        - name: WORDPRESS_DB_USER
          valueFrom:
            secretKeyRef:
              name: mysql-secret
              key: MYSQL_USER

        - name: WORDPRESS_HOME
          value: http://127.0.0.1:8085

        - name: WORDPRESS_SITEURL
          value: http://127.0.0.1:8085

        - name: WORDPRESS_DB_PASSWORD
          valueFrom:
            secretKeyRef:
              name: mysql-secret
              key: MYSQL_PASSWORD

        resources:
          requests:
            cpu: "250m"
            memory: "512Mi"
          limits:
            cpu: "500m"
            memory: "1Gi"
```
4. Wait until both pods show `1/1 Running`

**Verify:** Are both WordPress pods running and ready?

  - yes all the pds are running and readyy
    
<img width="1920" height="1080" alt="Screenshot (535)" src="https://github.com/user-attachments/assets/7c4caf84-4f6e-45e5-bc83-3fb1c8827201" />

---

### Task 4: Expose WordPress (Day 53)
1. Create a NodePort Service on port 30080 targeting the WordPress pods
```YML
 apiVersion: v1
kind: Service
metadata:
  name: wordpress
  namespace: capstone
spec:
  type: NodePort
  selector:
    app: wordpress
  ports:
    - port: 80
      targetPort: 80
      nodePort: 30080
```

3. Access WordPress in your browser:
   - Minikube: `minikube service wordpress -n capstone`
   - Kind: `kubectl port-forward svc/wordpress 8080:80 -n capstone`
4. Complete the setup wizard and create a blog post

**Verify:** Can you see the WordPress setup page?

- ys i can see the setup page!!
  
<img width="1920" height="1005" alt="Screenshot (538)" src="https://github.com/user-attachments/assets/967b7fc3-5b29-4d2e-8509-281aee3cfff5" />

---

### Task 5: Test Self-Healing and Persistence
1. Delete a WordPress pod — watch the Deployment recreate it within seconds. Refresh the site.
2. Delete the MySQL pod: `kubectl delete pod mysql-0 -n capstone` — watch the StatefulSet recreate it
3. After MySQL recovers, refresh WordPress — your blog post should still be there

**Verify:** After deleting both pods, is your blog post still there?
  - yes my data and blog post are still there....

<img width="1406" height="557" alt="Screenshot (551)" src="https://github.com/user-attachments/assets/d9335253-c5e4-4dd2-8145-661e7035e2c5" />
<img width="938" height="478" alt="Screenshot (550)" src="https://github.com/user-attachments/assets/423c472b-ded3-4f75-84d6-0cf223e3460f" />


---

### Task 7: (Bonus) Compare with Helm (Day 59)
1. Install WordPress using `helm install wp-helm bitnami/wordpress` in a separate namespace
2. Compare: how many resources did each approach create? Which gives more control?
3. Clean up the Helm deployment
   
<img width="1920" height="654" alt="Screenshot (554)" src="https://github.com/user-attachments/assets/2613a9df-f5bc-47c6-8475-316f99992673" />

---

### Task 8: Clean Up and Reflect
1. Take a final look: `kubectl get all -n capstone`
2. Count the concepts you used: Namespace, Secret, ConfigMap, PVC, StatefulSet, Headless Service, Deployment, NodePort Service, Resource Limits, Probes, HPA, Helm — twelve concepts in one deployment
3. Delete the namespace: `kubectl delete namespace capstone`
4. Reset default: `kubectl config set-context --current --namespace=default`

**Verify:** Did deleting the namespace remove everything?
  - yes deleting name space deletes everything
    
<img width="1920" height="779" alt="Screenshot (555)" src="https://github.com/user-attachments/assets/670002bb-5ec8-485a-b2f8-f382466ac49f" />

---

## Documentation
- Architecture of your deployment (which resources connect to which)
- Results of self-healing and persistence tests
- A table mapping each concept to the day you learned it
- Reflection: what was hardest, what clicked, what you would add for production

#  Architecture Overview

This project deploys a two-tier application:

### Components:

- **Namespace**: `capstone` (isolated environment)
- **MySQL (Database Layer)**:
  - StatefulSet (`mysql`)
  - Headless Service (`mysql`)
  - Persistent Volume Claim (1Gi storage)
  - Secret (credentials)

- **WordPress (Application Layer)**:
  - Deployment (`wordpress`)
  - ConfigMap (DB host + DB name)
  - Secret (DB user + password)
  - NodePort Service (`wordpress`)

- **Scaling & Reliability**:
  - Horizontal Pod Autoscaler (HPA)
  - Resource limits (CPU/Memory)
  - Probes (initially used, later adjusted)

---

###  Flow of Communication

User → NodePort Service → WordPress Pods → MySQL Service → MySQL Pod → Persistent Storage

---

##  Self-Healing Test

### Steps:
- Deleted WordPress pod
- Deployment recreated pod automatically
- Deleted MySQL pod (`mysql-0`)
- StatefulSet recreated pod with same identity

### Result:
✅ Application recovered automatically  
✅ Pods were recreated without manual intervention  

---

## Persistence Test

### Steps:
- Created a blog post in WordPress
- Deleted MySQL pod
- Waited for recovery
- Accessed WordPress again

### Result:
✅ Blog post still existed  
✅ Data persisted via PVC  

---

## Concepts Mapping

| Concept | Description | Learned On |
|--------|------------|-----------|
| Namespace | Logical isolation | Day 50 |
| Secret | Store sensitive data | Day 52 |
| ConfigMap | Store configuration | Day 52 |
| PVC | Persistent storage | Day 54 |
| StatefulSet | Stable DB pods | Day 55 |
| Headless Service | DB discovery | Day 55 |
| Deployment | Stateless app | Day 53 |
| NodePort Service | External access | Day 53 |
| Resource Limits | CPU/Memory control | Day 56 |
| Probes | Health checks | Day 57 |
| HPA | Auto scaling | Day 58 |
| Helm | Package manager | Day 59 |

---

###  What was hardest
- Debugging WordPress connectivity issues
- Understanding Service → Pod communication
- Handling networking issues with Minikube (WSL environment)

---

###  What clicked
- Difference between Deployment and StatefulSet
- How Services route traffic using labels
- How Kubernetes handles self-healing automatically
- Persistence using PVC and StatefulSet

---

### What I would add for production

- Ingress Controller (for proper routing & domain)
- LoadBalancer Service (instead of NodePort)
- TLS/HTTPS (security)
- Monitoring (Prometheus + Grafana)
- Logging (ELK stack)
- CI/CD pipeline (GitHub Actions)
- Backup strategy for MySQL

---

## Conclusion

This capstone project demonstrated:

- Full Kubernetes application lifecycle
- Deployment, scaling, and recovery
- Persistent storage management
- Real-world debugging and troubleshooting

This marks a strong foundation in Kubernetes and DevOps practices.

---
---
