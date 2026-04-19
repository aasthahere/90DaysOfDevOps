# Day 74 -- Node Exporter, cAdvisor, and Grafana Dashboards

## Challenge Tasks

### Task 1: Add Node Exporter for Host Metrics
Node Exporter exposes Linux system metrics (CPU, memory, disk, filesystem, network) in Prometheus format.

Update your `docker-compose.yml` from Day 73 -- add the Node Exporter service:
```yaml
  node-exporter:
    image: prom/node-exporter:latest
    container_name: node-exporter
    ports:
      - "9100:9100"
    volumes:
      - /proc:/host/proc:ro
      - /sys:/host/sys:ro
      - /:/rootfs:ro
    command:
      - '--path.procfs=/host/proc'
      - '--path.sysfs=/host/sys'
      - '--path.rootfs=/rootfs'
      - '--collector.filesystem.mount-points-exclude=^/(sys|proc|dev|host|etc)($$|/)'
    restart: unless-stopped
```

**Why these volume mounts?**
- `/proc` -- kernel and process information (CPU stats, memory info)
- `/sys` -- hardware and driver details
- `/` -- filesystem usage (disk space)

All mounted read-only (`ro`) -- Node Exporter only reads, never modifies.

Add it as a scrape target in `prometheus.yml`:
```yaml
scrape_configs:
  - job_name: "prometheus"
    static_configs:
      - targets: ["localhost:9090"]

  - job_name: "node-exporter"
    static_configs:
      - targets: ["node-exporter:9100"]
```

Restart the stack:
```bash
docker compose up -d
```

Verify Node Exporter is healthy:
```bash
curl http://localhost:9100/metrics | head -20
```

Check Prometheus Targets page -- `node-exporter` should show as `UP`.
<img width="1920" height="944" alt="Screenshot (847)" src="https://github.com/user-attachments/assets/7f4a22c9-2a2a-47fb-8a41-deeba08e9f99" />


Run these queries in Prometheus to see host metrics:
```promql
# CPU: percentage of time spent idle (per core)
node_cpu_seconds_total{mode="idle"}

<img width="1920" height="976" alt="Screenshot (848)" src="https://github.com/user-attachments/assets/32cdec95-f895-49c6-ac66-e9574e56cda1" />
<img width="1920" height="961" alt="Screenshot (849)" src="https://github.com/user-attachments/assets/d49b217d-a109-4d7c-9753-e464ba9b3b1c" />


# Memory: total vs available
node_memory_MemTotal_bytes
node_memory_MemAvailable_bytes
<img width="1920" height="966" alt="Screenshot (850)" src="https://github.com/user-attachments/assets/6d66b9f3-63ff-4d6c-9ee1-b02eb393f449" />


# Memory usage percentage
(1 - node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes) * 100

<img width="1920" height="980" alt="Screenshot (853)" src="https://github.com/user-attachments/assets/60f93df8-7829-43ef-8d18-937366fa8da1" />


# Disk: filesystem usage percentage
(1 - node_filesystem_avail_bytes / node_filesystem_size_bytes) * 100

<img width="1920" height="968" alt="Screenshot (854)" src="https://github.com/user-attachments/assets/b40e5473-5f9a-41ca-b4c5-7a2107eb7aad" />


# Network: bytes received per second
rate(node_network_receive_bytes_total[5m])
<img width="1920" height="957" alt="Screenshot (855)" src="https://github.com/user-attachments/assets/6ce653ae-c551-4092-8fca-1653ecd62539" />

```

### Task 2: Add cAdvisor for Container Metrics
cAdvisor (Container Advisor) monitors resource usage and performance of running Docker containers.

Add it to your `docker-compose.yml`:
```yaml
  cadvisor:
    image: gcr.io/cadvisor/cadvisor:latest
    container_name: cadvisor
    ports:
      - "8080:8080"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - /sys:/sys:ro
      - /var/lib/docker/:/var/lib/docker:ro
    restart: unless-stopped
```

**Why these volume mounts?**
- Docker socket (`docker.sock`) -- lets cAdvisor discover and query running containers
- `/sys` -- kernel-level container stats (cgroups)
- `/var/lib/docker/` -- container filesystem information

Add cAdvisor as a Prometheus scrape target:
```yaml
  - job_name: "cadvisor"
    static_configs:
      - targets: ["cadvisor:8080"]
```

Restart and verify:
```bash
docker compose up -d
```

Open `http://localhost:8080` to see the cAdvisor web UI. Click on Docker Containers to see per-container stats.

<img width="1920" height="969" alt="Screenshot (856)" src="https://github.com/user-attachments/assets/1daa9ed5-ef80-433f-92bf-128f4dd62081" />
<img width="1920" height="954" alt="Screenshot (865)" src="https://github.com/user-attachments/assets/426e5cea-194e-4a5a-ad1b-9555ef773a6c" />


Run these queries in Prometheus:
```promql
# CPU usage per container (in seconds)
rate(container_cpu_usage_seconds_total{name!=""}[5m])

<img width="1920" height="964" alt="Screenshot (867)" src="https://github.com/user-attachments/assets/f5f32beb-325e-4782-8184-7c9e72d62391" />


# Memory usage per container
container_memory_usage_bytes{name!=""}

<img width="1920" height="970" alt="Screenshot (871)" src="https://github.com/user-attachments/assets/fb822f41-030d-4069-8151-bceb7f6b2739" />


# Network received bytes per container
rate(container_network_receive_bytes_total{name!=""}[5m])
<img width="1920" height="971" alt="Screenshot (869)" src="https://github.com/user-attachments/assets/9b06555e-3aa7-42f6-9231-4494b4fad89f" />


# Which container is using the most memory?
topk(3, container_memory_usage_bytes{name!=""})


```

The `{name!=""}` filter removes aggregated/system-level entries and shows only named containers.

**Document:** What is the difference between Node Exporter and cAdvisor? When would you use each?

## 📊 Difference Between Node Exporter and cAdvisor

| Feature          | Node Exporter          | cAdvisor 📦         | 
|------------------|------------------------|----------------------|
| Monitoring Level | Host / System          | Container            |
| Focus            | Entire machine         | Individual containers|
| Metrics Type     | CPU, Memory, Disk, Network (system-wide) | CPU, Memory, Network (per container) |
| Use Case         | Server health monitoring | Container performance monitoring |
| Works With       | VMs, Bare Metal        | Docker, Kubernetes   |
| Scope            | Global (whole node)    | Granular (per container) |
| Example          | Overall CPU usage of server | CPU usage of a specific container |

---

### Task 3: Set Up Grafana
Grafana is the visualization layer. It connects to Prometheus (and later Loki) and lets you build dashboards, set alerts, and share views with your team.

Add Grafana to your `docker-compose.yml`:
```yaml
  grafana:
    image: grafana/grafana-enterprise:latest
    container_name: grafana
    ports:
      - "3000:3000"
    volumes:
      - grafana_data:/var/lib/grafana
    environment:
      - GF_SECURITY_ADMIN_USER=admin
      - GF_SECURITY_ADMIN_PASSWORD=admin123
    restart: unless-stopped
```

Add the volume at the bottom of your compose file:
```yaml
volumes:
  prometheus_data:
  grafana_data:
```

Restart:
```bash
docker compose up -d
```

Open `http://localhost:3000`. Log in with `admin` / `admin123`.

**Add Prometheus as a datasource:**
1. Go to Connections > Data Sources > Add data source
2. Select Prometheus
3. Set URL to `http://prometheus:9090` (use the container name, not localhost -- they are on the same Docker network)
4. Click Save & Test -- you should see "Successfully queried the Prometheus API"
<img width="1920" height="981" alt="Screenshot (874)" src="https://github.com/user-attachments/assets/f048595d-2588-472e-b39a-86a7ebfa409a" />


---

### Task 4: Build Your First Dashboard
Create a dashboard that shows the health of your system at a glance.

1. Go to Dashboards > New Dashboard > Add Visualization
2. Select Prometheus as the datasource

**Panel 1 -- CPU Usage (Gauge):**
```promql
100 - (avg(rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)
```
- Visualization: Gauge
- Title: "CPU Usage %"
- Set thresholds: green < 60, yellow < 80, red >= 80

**Panel 2 -- Memory Usage (Gauge):**
```promql
(1 - node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes) * 100
```
- Visualization: Gauge
- Title: "Memory Usage %"

**Panel 3 -- Container CPU Usage (Time Series):**
```promql
rate(container_cpu_usage_seconds_total{name!=""}[5m]) * 100
```
- Visualization: Time series
- Title: "Container CPU Usage"
- Legend: `{{name}}`

**Panel 4 -- Container Memory Usage (Bar Chart):**
```promql
container_memory_usage_bytes{name!=""} / 1024 / 1024
```
- Visualization: Bar chart
- Title: "Container Memory (MB)"
- Legend: `{{name}}`

**Panel 5 -- Disk Usage (Stat):**
```promql
(1 - node_filesystem_avail_bytes{mountpoint="/"} / node_filesystem_size_bytes{mountpoint="/"}) * 100
```
- Visualization: Stat
- Title: "Disk Usage %"

Save the dashboard as "DevOps Observability Overview".
<img width="1920" height="965" alt="Screenshot (882)" src="https://github.com/user-attachments/assets/175718a2-964d-4b0c-b380-12f24c04852c" />


---
<img width="1920" height="991" alt="Screenshot (881)" src="https://github.com/user-attachments/assets/964279ff-5a4f-4ca3-9e92-e4c1701ee005" />

### Task 5: Auto-Provision Datasources with YAML
In production, you do not click through the UI to add datasources. You provision them with configuration files so the setup is repeatable.

Create the provisioning directory structure:
```bash
mkdir -p grafana/provisioning/datasources
mkdir -p grafana/provisioning/dashboards
```

Create `grafana/provisioning/datasources/datasources.yml`:
```yaml
apiVersion: 1

datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://prometheus:9090
    isDefault: true
    editable: false
```

Update the Grafana service in `docker-compose.yml` to mount the provisioning directory:
```yaml
  grafana:
    image: grafana/grafana-enterprise:latest
    container_name: grafana
    ports:
      - "3000:3000"
    volumes:
      - grafana_data:/var/lib/grafana
      - ./grafana/provisioning:/etc/grafana/provisioning
    environment:
      - GF_SECURITY_ADMIN_USER=admin
      - GF_SECURITY_ADMIN_PASSWORD=admin123
    restart: unless-stopped
```

Restart Grafana:
```bash
docker compose up -d grafana
```

Check Connections > Data Sources -- Prometheus should already be there without any manual setup.

<img width="1920" height="968" alt="Screenshot (886)" src="https://github.com/user-attachments/assets/f5b42f37-d7b6-4c16-9c0a-9ea873fb366b" />


**Document:** Why is provisioning datasources via YAML better than configuring them manually through the UI?


| Aspect             | YAML Provisioning                     | Manual UI Configuration          |
|--------------------|----------------------------------------|----------------------------------|
| Automation         | Fully automated setup                  | Manual, repetitive steps         |
| Consistency        | Same config across all environments    | Risk of human error              |
| Version Control    | Can be stored in Git                   | No version tracking              |
| Reproducibility    | Easy to recreate setup anytime         | Hard to replicate exactly        |
| Scalability        | Works well for large environments      | Not practical at scale           |
| CI/CD Integration  | Can be integrated into pipelines       | Cannot be automated easily       |
| Speed              | Fast deployment                        | Time-consuming                   |
| Reliability        | Predictable and stable                 | Prone to misconfiguration        |

> YAML provisioning enables **automation, consistency, and scalability**, making it ideal for DevOps workflows, while manual UI setup is slower and error-prone.

---

### Task 6: Import a Community Dashboard
The Grafana community maintains thousands of pre-built dashboards. Import one for Node Exporter:

1. Go to Dashboards > New > Import
2. Enter dashboard ID: **1860** (Node Exporter Full)
3. Select your Prometheus datasource
4. Click Import

Explore the imported dashboard. It has dozens of panels covering CPU, memory, disk, network, and more -- all built on the same Node Exporter metrics you queried manually.

**Try another one:** Import dashboard ID **193** (Docker monitoring via cAdvisor). Select Prometheus as the datasource and explore container-level stats.

**Your full `docker-compose.yml` should now have these services:**
- `prometheus`
- `node-exporter`
- `cadvisor`
- `grafana`
- `notes-app` (from Day 73)

Verify all are running:
```bash
docker compose ps
```
<img width="1920" height="984" alt="Screenshot (888)" src="https://github.com/user-attachments/assets/87b26e13-62c6-4097-9923-ef92fd9751a4" />
<img width="1920" height="971" alt="Screenshot (887)" src="https://github.com/user-attachments/assets/2c1317bd-3ca8-4358-88af-8590a688a4a5" />
<img width="1638" height="475" alt="Screenshot (889)" src="https://github.com/user-attachments/assets/ccf32c1a-673c-4726-87d0-65ece09cdf3c" />

---





