# Day 59 – Helm — Kubernetes Package Manager

### Task 1: Install Helm
1. Install Helm (brew, curl script, or chocolatey depending on your OS)
   
      ```sudo snap install helm --classic```
   
3. Verify with `helm version` and `helm env`
      ```helm version```

Three core concepts:
- **Chart** — a package of Kubernetes manifest templates
- **Release** — a specific installation of a chart in your cluster
- **Repository** — a collection of charts (like a package repo)

**Verify:** What version of Helm is installed?
       + **"v4.1.3"**

   <img width="1920" height="350" alt="Screenshot (514)" src="https://github.com/user-attachments/assets/388d3cbe-7a6e-4f2b-b6c7-7a87ae904f35" />


---

### Task 2: Add a Repository and Search
1. Add the Bitnami repository: `helm repo add bitnami https://charts.bitnami.com/bitnami`
2. Update: `helm repo update`
3. Search: `helm search repo nginx` and `helm search repo bitnami`

**Verify:** How many charts does Bitnami have?
       + **there is so many charts in bitnami**

   <img width="1920" height="822" alt="Screenshot (515)" src="https://github.com/user-attachments/assets/74bee249-4cf3-4187-8d54-88c5292cca8d" />

---

### Task 3: Install a Chart
1. Deploy nginx: `helm install my-nginx bitnami/nginx`
2. Check what was created: `kubectl get all`
3. Inspect the release: `helm list`, `helm status my-nginx`, `helm get manifest my-nginx`

One command replaced writing a Deployment, Service, and ConfigMap by hand.

**Verify:** How many Pods are running? What Service type was created?
   + 1 pod is running
   + service type is LoadBalancer

     <img width="1920" height="335" alt="Screenshot (516)" src="https://github.com/user-attachments/assets/57b153be-b7bd-4879-a97f-cbaa8db792c9" />


---
### Task 4: Customize with Values
1. View defaults: `helm show values bitnami/nginx`
2. Install a custom release with `--set replicaCount=3 --set service.type=NodePort`
3. Create a `custom-values.yaml` file with replicaCount, service type, and resource limits
4. Install another release using `-f custom-values.yaml`
5. Check overrides: `helm get values <release-name>`

**Verify:** Does the values file release have the correct replicas and service type?
     + yes its have
     
<img width="1920" height="976" alt="Screenshot (517)" src="https://github.com/user-attachments/assets/37f9d0ce-7739-43c3-be7a-4ab4a8489a68" />

---
### Task 5: Upgrade and Rollback
1. Upgrade: `helm upgrade my-nginx bitnami/nginx --set replicaCount=5`
2. Check history: `helm history my-nginx`
3. Rollback: `helm rollback my-nginx 1`
4. Check history again — rollback creates a new revision (3), not overwriting revision 2

Same concept as Deployment rollouts from Day 52, but at the full stack level.

**Verify:** How many revisions after the rollback?
  + 3 revisions

    <img width="1920" height="334" alt="Screenshot (518)" src="https://github.com/user-attachments/assets/73a0f65e-4633-4430-abe3-ff6e275c80dd" />

---


### Task 6: Create Your Own Chart
1. Scaffold: `helm create my-app`
2. Explore the directory: `Chart.yaml`, `values.yaml`, `templates/deployment.yaml`
3. Look at the Go template syntax in templates: `{{ .Values.replicaCount }}`, `{{ .Chart.Name }}`
4. Edit `values.yaml` — set replicaCount to 3 and image to nginx:1.25
5. Validate: `helm lint my-app`
6. Preview: `helm template my-release ./my-app`
7. Install: `helm install my-release ./my-app`
8. Upgrade: `helm upgrade my-release ./my-app --set replicaCount=5`

**Verify:** After installing, 3 replicas? After upgrading, 5?
  + Yes, the deployment has 3 replicas as defined in values.yaml
  + Yes, the deployment is updated to 5 replicas using --set replicaCount=5
    
<img width="1623" height="398" alt="Screenshot (519)" src="https://github.com/user-attachments/assets/b5351b6e-3331-414e-b3bf-cb845b3ebabe" />

---
### Task 7: Clean Up
1. Uninstall all releases: `helm uninstall <name>` for each
2. Remove chart directory and values file
3. Use `--keep-history` if you want to retain release history for auditing

**Verify:** Does `helm list` show zero releases?

+ Yes, helm list shows zero releases. All resources have been successfully cleaned up.
  
<img width="1585" height="416" alt="Screenshot (528)" src="https://github.com/user-attachments/assets/58c93bcc-5d74-4ca3-8a92-474b422a9dc3" />

---

## Documentation
Create `day-59-helm.md` with:
- What Helm is and the three core concepts
     + Helm is a package manager for Kubernetes that helps you define, install, and manage applications using reusable templates called charts.
          + three core concepts
              + charts
                  + A package of Kubernetes resources Contains templates, values, and metadata
              + Release
                 + A running instance of a chart Each install creates a new release
             + Repository
                + A collection of Helm charts
                  
- How to install, customize, upgrade, and rollback

  helm install my-nginx bitnami/nginx

  helm install my-nginx bitnami/nginx \
  --set replicaCount=3 \
  --set service.type=NodePort

  helm install my-nginx bitnami/nginx -f custom-values.yaml

  helm upgrade my-nginx bitnami/nginx --set replicaCount=5

  helm rollback my-nginx 1

  
- The structure of a Helm chart and how Go templating works
     + helm create my-app
       
       my-app/
├── Chart.yaml
├── values.yaml
├── templates/
│   ├── deployment.yaml
│   ├── service.yaml


- Your `custom-values.yaml` with explanations
  + value.yml:
  + its have Default configuration values such as replicaCount: 1
 
  + templates/:
  + Contains Kubernetes YAML with placeholders
 
  + Helm uses Go template syntax: replicas: {{ .Values.replicaCount }}
   + Value is dynamically taken from values.yaml

 ```YML
 replicaCount: 3

service:
  type: NodePort

resources:
  limits:
    cpu: "200m"
    memory: "256Mi"
  requests:
    cpu: "100m"
    memory: "128Mi"
    
```

---

