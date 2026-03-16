# Day 50 – Kubernetes Architecture and Cluster Setup

### Task 1: Recall the Kubernetes Story
+ Before touching a terminal, write down from memory:

1. Why was Kubernetes created? What problem does it solve that Docker alone cannot?
2. Who created Kubernetes and what was it inspired by?
3. What does the name "Kubernetes" mean?

+ Do not look anything up yet. Write what you remember from the session, then verify against the official docs.
---

  1. Why was Kubernetes created? What problem does it solve that Docker alone cannot?
        + **Kubernetes solves scaling and restarting containers automatically, while earlier engineers had to do it manually.**
        + **so basically kubernetes was created to solve container orchestration problems such as**
            - scalling
            - restarting
            - Managing containers across multiple machines
              

        + **Docker helps to create and run containers, but when run many containers across many servers, Docker alone cannot easily manage them.**
---

  2. Who created Kubernetes and what was it inspired by?
     + **Kubernetes was created by Google in 2014.**
     + **It was inspired Borg tool which was automatically scalling and restarting the cantainer**
     + **later Google donates it to open-source**
     + **Today it is maintained by the Cloud Native Computing Foundation, which is part of the Linux Foundation.**
     + **And they named it as KUBERNETES**

---

 3. What does the name "Kubernetes" mean?
     + **Kubernetes comes from the Greek word meaning**
     + **Helmsman” or “Ship Pilot” (someone who steers a ship).**
     + **which means the cantainers are the ships and the steerign it is kubernetes**
     + **K8s is the short form of Kubernetes**
     + **There are 8 letters between K and S**

---
### Task 2: Draw the Kubernetes Architecture
+ From memory, draw or describe the Kubernetes architecture. Your diagram should include:

**Control Plane (Master Node):**
- API Server — the front door to the cluster, every command goes through it
- etcd — the database that stores all cluster state
- Scheduler — decides which node a new pod should run on
- Controller Manager — watches the cluster and makes sure the desired state matches reality

**Worker Node:**
- kubelet — the agent on each node that talks to the API server and manages pods
- kube-proxy — handles networking rules so pods can communicate
- Container Runtime — the engine that actually runs containers (containerd, CRI-O)

**After drawing, verify your understanding:**
- What happens when you run `kubectl apply -f pod.yaml`? Trace the request through each component.
    + **kubectl sends a request to the API server,**
    + **the API server stores the desired state in etcd,**
    + **the scheduler assigns a node, and the kubelet on that node creates the pod.**
      
- What happens if the API server goes down?
    + **kubectl commands stop working**
    + **Scheduler cannot schedule new pods**
    + **Controllers cannot update state**
    + **Cluster changes cannot happen**
    + **The cluster cannot be managed,**
    + **but already running pods continue working.**
      
- What happens if a worker node goes down?
    +**Worker node stops responding.**
    + **The control plane detects the node failure**
    + **Kubernetes detects the failure and recreates the pods on another healthy node.**
 
      https://github.com/Aliyas-22/90DaysOfDevOps/blob/4cbb6f0901f0eaeb61c003c02144e126b4aedad5/2026/day-50/kubernetes-architechture.jpeg

---
### Task 3: Install kubectl
`kubectl` is the CLI tool you will use to talk to your Kubernetes cluster.

Install it:
```bash
# macOS
brew install kubectl

# Linux (amd64)
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/

# Windows (with chocolatey)
choco install kubernetes-cli
```

Verify:
```bash
kubectl version --client
```

https://github.com/Aliyas-22/90DaysOfDevOps/blob/4cbb6f0901f0eaeb61c003c02144e126b4aedad5/2026/day-50/Screenshot%20(383).png
---

### Task 4: Set Up Your Local Cluster
Choose **one** of the following. Both give you a fully functional Kubernetes cluster on your machine.

**Option A: kind (Kubernetes in Docker)**
```bash
# Install kind
# macOS
brew install kind

# Linux
curl -Lo ./kind https://kind.sigs.k8s.io/dl/latest/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind

# Create a cluster
kind create cluster --name devops-cluster

# Verify
kubectl cluster-info
kubectl get nodes
```

**Option B: minikube**
```bash
# Install minikube
# macOS
brew install minikube

# Linux
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube

# Start a cluster
minikube start

# Verify
kubectl cluster-info
kubectl get nodes
```

Write down: Which one did you choose and why?

+ **i choosed kind (kubernetes in docker)**
+ **I chose KIND because it allows me to run a lightweight Kubernetes cluster locally using Docker containers instead of virtual machines.**
+ **It is fast to set up and ideal for learning and testing Kubernetes configurations.**


---

### Task 5: Explore Your Cluster
Now that your cluster is running, explore it:

```bash
# See cluster info
kubectl cluster-info

# List all nodes
kubectl get nodes

# Get detailed info about your node
kubectl describe node <node-name>

# List all namespaces
kubectl get namespaces

# See ALL pods running in the cluster (across all namespaces)
kubectl get pods -A

```
https://github.com/Aliyas-22/90DaysOfDevOps/blob/4cbb6f0901f0eaeb61c003c02144e126b4aedad5/2026/day-50/Screenshot%20(384).png
Look at the pods running in the `kube-system` namespace:
```bash
kubectl get pods -n kube-system
```

You should see pods like `etcd`, `kube-apiserver`, `kube-scheduler`, `kube-controller-manager`, `coredns`, and `kube-proxy`. These are the architecture components you drew in Task 2 — running as pods inside the cluster.

**Verify:** Can you match each running pod in `kube-system` to a component in your architecture diagram?

---
### Task 6: Practice Cluster Lifecycle
Build muscle memory with cluster operations:

```bash
# Delete your cluster
kind delete cluster --name devops-cluster
# (or: minikube delete)

# Recreate it
kind create cluster --name devops-cluster
# (or: minikube start)

# Verify it is back
kubectl get nodes
```

Try these useful commands:
```bash
# Check which cluster kubectl is connected to
kubectl config current-context
 kind-kind

# List all available contexts (clusters)
kubectl config get-contexts

# See the full kubeconfig
kubectl config view
```

+ Write down: What is a kubeconfig? Where is it stored on your machine?

+ **Kubeconfig is a configuration file used by kubectl to connect to a Kubernetes cluster. It stores cluster details,
 user credentials, and context information required for authentication and communication with the Kubernetes API server.
  By default, it is stored at ~/.kube/config in the user’s home directory.**
