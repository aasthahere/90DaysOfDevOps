### Task 1: Create Your First Pod (Nginx)
Create a file called `nginx-pod.yaml`:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pod
  labels:
    app: nginx
spec:
  containers:
  - name: nginx
    image: nginx:latest
    ports:
    - containerPort: 80
```

Apply it:
```bash
kubectl apply -f nginx-pod.yaml
+ this will create the pod

```

Verify:
```bash
kubectl get pods
  + to see the pod details

kubectl get pods -o wide
  + to see the additional details 
```

Wait until the STATUS shows `Running`. Then explore:
```bash
# Detailed info about the pod
kubectl describe pod nginx-pod

+ this will the whole detialed of the pod such as
+ ip ,cantianer id , image id , condition ,volumes etc

# Read the logs
kubectl logs nginx-pod
+ logs shows that the looking the image , launching the image and started 

# Get a shell inside the container
kubectl exec -it nginx-pod -- /bin/bash
 to enter inside the cantianer


# Inside the container, run:
curl localhost:80
exit
```

**Verify:** Can you see the Nginx welcome page when you curl from inside the pod?


 **yes! i can see the welcome to nginx html text inside the pod after doing curl**
 
---
<img width="1082" height="948" alt="Screenshot (390)" src="https://github.com/user-attachments/assets/57cb2098-7fce-4881-a8ae-695b1abd45e2" />

---
### Task 2: Create a Custom Pod (BusyBox)
Write a new manifest `busybox-pod.yaml` from scratch (do not copy-paste the nginx one):

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: busybox-pod
  labels:
    app: busybox
    environment: dev
spec:
  containers:
  - name: busybox
    image: busybox:latest
    command: ["sh", "-c", "echo Hello from BusyBox && sleep 3600"]
```

Apply and verify:
```bash
kubectl apply -f busybox-pod.yaml
kubectl get pods
kubectl logs busybox-pod
```

Notice the `command` field — BusyBox does not run a long-lived server like Nginx. Without a command that keeps it running, the container would exit immediately and the pod would go into `CrashLoopBackOff`.

**Verify:** Can you see "Hello from BusyBox" in the logs?


+ **yes i can see the hello from Busybox**
  
---

<img width="1124" height="186" alt="Screenshot (391)" src="https://github.com/user-attachments/assets/80600460-f5d0-4753-b75a-e4923769c70f" />

---

### Task 3: Imperative vs Declarative
You have been using the declarative approach (writing YAML, then `kubectl apply`). Kubernetes also supports imperative commands:

```bash
# Create a pod without a YAML file
kubectl run redis-pod --image=redis:latest

# Check it
kubectl get pods
```

Now extract the YAML that Kubernetes generated:
```bash
kubectl get pod redis-pod -o yaml
```

Compare this output with your hand-written manifests. Notice how much extra metadata Kubernetes adds automatically (status, timestamps, uid, resource version).

You can also use dry-run to generate YAML without creating anything:
```bash
kubectl run test-pod --image=nginx --dry-run=client -o yaml
```

This is a powerful trick — use it to quickly scaffold a manifest, then customize it.

**Verify:** Save the dry-run output to a file and compare its structure with your nginx-pod.yaml.
+ *What fields are the same?* 
    + **apiversion , kind , metadata , image , name ,labels are the same**

+ *What is different?*
   + **resources , dnspolicy , restartpolicy and status are diffrent**

     <img width="1239" height="939" alt="Screenshot (395)" src="https://github.com/user-attachments/assets/5a11f0c3-33e4-4866-ab4d-445f583d2e69" />


---
 
### Task 4: Validate Before Applying
Before applying a manifest, you can validate it:

```bash
# Check if the YAML is valid without actually creating the resource
kubectl apply -f nginx-pod.yaml --dry-run=client

# Validate against the cluster's API (server-side validation)
kubectl apply -f nginx-pod.yaml --dry-run=server
```

Now intentionally break your YAML (remove the `image` field or add an invalid field) and run dry-run again. See what error you get.

**Verify:** What error does Kubernetes give when the image field is missing?

 + **it give erorr this = The Pod "nginx-pod" is invalid: spec.containers[0].image: Required value**
   
<img width="1104" height="382" alt="Screenshot (396)" src="https://github.com/user-attachments/assets/7f32aae2-0302-4dca-ba1a-d6acc3a1ef5d" />

---
### Task 5: Pod Labels and Filtering
Labels are how Kubernetes organizes and selects resources. You added labels in your manifests — now use them:

```bash
# List all pods with their labels
kubectl get pods --show-labels

# Filter pods by label
kubectl get pods -l app=nginx
kubectl get pods -l environment=dev

# Add a label to an existing pod
kubectl label pod nginx-pod environment=production

# Verify
kubectl get pods --show-labels

# Remove a label
kubectl label pod nginx-pod environment-
```
<img width="1920" height="941" alt="Screenshot (399)" src="https://github.com/user-attachments/assets/a8ff0a4f-3821-4f52-87e3-9f74685dc42e" />


Write a manifest for a third pod with at least 3 labels (app, environment, team). Apply it and practice filtering.
<img width="1827" height="661" alt="Screenshot (400)" src="https://github.com/user-attachments/assets/5d9a48a1-9e28-4cd0-8b2d-ee0b85a725cc" />

---

### Task 6: Clean Up
Delete all the pods you created:

```bash
# Delete by name
kubectl delete pod nginx-pod
kubectl delete pod busybox-pod
kubectl delete pod redis-pod

# Or delete using the manifest file
kubectl delete -f nginx-pod.yaml

# Verify everything is gone
kubectl get pods
```

Notice that when you delete a standalone Pod, it is gone forever. There is no controller to recreate it. This is why in production you use Deployments (coming on Day 52) instead of bare Pods.
<img width="1920" height="653" alt="Screenshot (402)" src="https://github.com/user-attachments/assets/e54780c2-d80f-4584-8cfc-664ad08fe868" />

---
