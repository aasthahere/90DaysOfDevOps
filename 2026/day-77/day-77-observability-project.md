# Day 77 -- Observability Project: Full Stack with Docker Compose

## Task
Four days of building -- Prometheus, Node Exporter, cAdvisor, Grafana, Loki, Promtail, OpenTelemetry Collector, and alerting. Today you put it all together using a production-ready reference architecture.

You will clone the observability-for-devops reference repo, spin up the complete 8-service stack in one command, validate every data flow end to end, build a unified dashboard, and document the entire setup as if you were handing it off to a teammate.

---

### Task 1: Clone and Launch the Reference Stack
Clone the reference repository that contains the complete observability setup:

```bash
git clone https://github.com/LondheShubham153/observability-for-devops.git
cd observability-for-devops
```

Examine the project structure:
```bash
tree -I 'node_modules|build|staticfiles|__pycache__'
```

```
observability-for-devops/
  docker-compose.yml                    # 8 services orchestrated together
  prometheus.yml                        # Prometheus scrape configuration
  alert-rules.yml                       # (you will add this)
  grafana/
    provisioning/
      datasources/datasources.yml       # Auto-provisioned: Prometheus + Loki
      dashboards/dashboards.yml         # Dashboard provisioning config
  loki/
    loki-config.yml                     # Loki storage and schema config
  promtail/
    promtail-config.yml                 # Docker log collection config
  otel-collector/
    otel-collector-config.yml           # OTLP receivers, processors, exporters
  notes-app/                            # Sample Django + React application
```

Launch the entire stack:
```bash
docker compose up -d
```

Wait for all containers to start:
```bash
docker compose ps
```

All 8 services should show as running:

| Service | Port | Check |
|---------|------|-------|
| Prometheus | 9090 | `http://localhost:9090` |
| Node Exporter | 9100 | `curl http://localhost:9100/metrics \| head -5` |
| cAdvisor | 8080 | `http://localhost:8080` |
| Grafana | 3000 | `http://localhost:3000` (admin/admin) |
| Loki | 3100 | `curl http://localhost:3100/ready` |
| Promtail | 9080 | Internal only |
| OTEL Collector | 4317/4318 | `docker logs otel-collector` |
| Notes App | 8000 | `http://localhost:8000` |

---

### Task 2: Validate the Metrics Pipeline
Confirm Prometheus is scraping all targets:

1. Open `http://localhost:9090/targets`
2. Verify all 4 scrape jobs are UP:
   - `prometheus` (self-monitoring)
   - `node-exporter` (host metrics)
   - `docker` / `cadvisor` (container metrics)
   - `otel-collector` (OTLP metrics)

Run these validation queries:
```promql
# All targets are healthy
up

# Host CPU usage
100 - (avg(rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)

# Memory usage
(1 - node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes) * 100

# Container CPU per container
rate(container_cpu_usage_seconds_total{name!=""}[5m]) * 100

# Top 3 memory-hungry containers
topk(3, container_memory_usage_bytes{name!=""})
```
<img width="1920" height="978" alt="Screenshot (937)" src="https://github.com/user-attachments/assets/4929fcb2-485d-482c-88c9-41d43a1befab" />
<img width="1920" height="921" alt="Screenshot (936)" src="https://github.com/user-attachments/assets/2ea90b26-b3f4-4a7e-81ab-5ef066cc17c3" />
<img width="1920" height="960" alt="Screenshot (938)" src="https://github.com/user-attachments/assets/de387023-7eef-470e-b486-b47428629b95" />
Compare the `prometheus.yml` from the reference repo with the one you built over days 73-76. Note the scrape jobs and intervals.
```
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: "prometheus"
    static_configs:
      - targets: ["localhost:9090"]

  - job_name: "docker"
    static_configs:
      - targets: ["cadvisor:8080"]

  - job_name: "node-exporter"
    static_configs:
      - targets: ["node-exporter:9100"]

  - job_name: "otel-collector"
    static_configs:
      - targets: ["otel-collector:8889"]
```
---

### Task 3: Validate the Logs Pipeline
Generate traffic so there are logs to see:

```bash
for i in $(seq 1 50); do
  curl -s http://localhost:8000 > /dev/null

  curl -s http://localhost:8000/api/ > /dev/null
done
```

Open Grafana (`http://localhost:3000`) and go to Explore:

1. Select Loki as the datasource
2. Run these LogQL queries:

```logql
# All container logs
{job="docker"}

# Only notes-app logs
{container_name="notes-app"}

# Errors across all containers
{job="docker"} |= "error"

# HTTP request logs from the app
{container_name="notes-app"} |= "GET"

# Rate of log lines per container
sum by (container_name) (rate({job="docker"}[5m]))
```
<img width="1920" height="966" alt="Screenshot (940)" src="https://github.com/user-attachments/assets/1c726452-d7d0-45a4-924b-dbb34ed48a61" />


Check Promtail's targets to see which log files it is watching:
```bash
curl -s http://localhost:9080/targets | head -30
```
<img width="1920" height="1029" alt="Screenshot (942)" src="https://github.com/user-attachments/assets/7803d392-0761-44e2-934e-d178b8e916df" />

Compare `promtail/p
romtail-config.yml` from the reference repo with yours from Day 75.

---
### Task 4: Validate the Traces Pipeline
Send OTLP traces to the collector:

```bash
curl -X POST http://localhost:4318/v1/traces \
  -H "Content-Type: application/json" \
  -d '{
    "resourceSpans": [{
      "resource": {
        "attributes": [{
          "key": "service.name",
          "value": { "stringValue": "notes-app" }
        }]
      },
      "scopeSpans": [{
        "spans": [{
          "traceId": "aaaabbbbccccdddd1111222233334444",
          "spanId": "1111222233334444",
          "name": "GET /api/notes",
          "kind": 2,
          "startTimeUnixNano": "1700000000000000000",
          "endTimeUnixNano": "1700000000150000000",
          "attributes": [{
            "key": "http.method",
            "value": { "stringValue": "GET" }
          },
          {
            "key": "http.route",
            "value": { "stringValue": "/api/notes" }
          },
          {
            "key": "http.status_code",
            "value": { "intValue": "200" }
          }],
          "status": { "code": 1 }
        },
        {
          "traceId": "aaaabbbbccccdddd1111222233334444",
          "spanId": "5555666677778888",
          "parentSpanId": "1111222233334444",
          "name": "SELECT notes FROM database",
          "kind": 3,
          "startTimeUnixNano": "1700000000020000000",
          "endTimeUnixNano": "1700000000120000000",
          "attributes": [{
            "key": "db.system",
            "value": { "stringValue": "sqlite" }
          },
          {
            "key": "db.statement",
            "value": { "stringValue": "SELECT * FROM notes" }
          }]
        }]
      }]
    }]
  }'
```

This simulates a two-span trace: an HTTP request that calls a database query.

Check the debug output:
```bash
docker logs otel-collector 2>&1 | grep -A 20 "GET /api/notes"
```

You should see both spans with their attributes, the parent-child relationship, and timing data.

Compare `otel-collector/otel-collector-config.yml` from the reference repo with yours from Day 76.

---

### Task 5: Build a Unified "Production Overview" Dashboard
Create a single Grafana dashboard that gives a complete picture of your system.

Go to Dashboards > New Dashboard. Add these panels:

**Row 1 -- System Health (Node Exporter + Prometheus):**

| Panel | Type | Query |
|-------|------|-------|
| CPU Usage | Gauge | `100 - (avg(rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)` |
| Memory Usage | Gauge | `(1 - node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes) * 100` |
| Disk Usage | Gauge | `(1 - node_filesystem_avail_bytes{mountpoint="/"} / node_filesystem_size_bytes{mountpoint="/"}) * 100` |
| Targets Up | Stat | `sum(up)` / `count(up)` |

**Row 2 -- Container Metrics (cAdvisor):**

| Panel | Type | Query |
|-------|------|-------|
| Container CPU | Time series | `rate(container_cpu_usage_seconds_total{name!=""}[5m]) * 100` (legend: `{{name}}`) |
| Container Memory | Bar chart | `container_memory_usage_bytes{name!=""} / 1024 / 1024` (legend: `{{name}}`) |
| Container Count | Stat | `count(container_last_seen{name!=""})` |

**Row 3 -- Application Logs (Loki):**

| Panel | Type | Query (Loki datasource) |
|-------|------|-------|
| App Logs | Logs | `{container_name="notes-app"}` |
| Error Rate | Time series | `sum(rate({job="docker"} \|= "error" [5m]))` |
| Log Volume | Time series | `sum by (container_name) (rate({job="docker"}[5m]))` |

**Row 4 -- Service Overview:**

| Panel | Type | Query |
|-------|------|-------|
| Prometheus Scrape Duration | Time series | `prometheus_target_interval_length_seconds{quantile="0.99"}` |
| OTEL Metrics Received | Stat | `otelcol_receiver_accepted_metric_points` (if available) |

Save the dashboard as "Production Overview -- Observability Stack".

Set the dashboard time range to "Last 30 minutes" and enable auto-refresh (every 10s).
<img width="1920" height="1036" alt="Screenshot (978)" src="https://github.com/user-attachments/assets/0f42a4e7-2a39-4591-bb7c-4dd78bde4cda" />
<img width="1920" height="1019" alt="Screenshot (980)" src="https://github.com/user-attachments/assets/a177c822-8644-4133-9b8d-78dfcccc40d8" />
<img width="1920" height="361" alt="Screenshot (951)" src="https://github.com/user-attachments/assets/20e74d5b-4d8b-4678-9504-74b87abd6a7e" />


---

## Task 6: Compare Your Stack with the Reference and Document

### Comparison of Components

| Component | My Version | Reference Repo | Differences |
|----------|-----------|----------------|-------------|
| prometheus.yml | Day 73-74 | Root directory | Similar scrape jobs, reference has better structured config |
| loki-config.yml | Day 75 | loki/ directory | Reference uses proper storage and indexing setup |
| promtail-config.yml | Day 75 | promtail/ directory | Reference has better log parsing and labeling |
| otel-collector-config.yml | Day 76 | otel-collector/ directory | Reference has clean pipelines and exporters setup |
| datasources.yml | Day 74 | grafana/provisioning/ | Reference auto-configures data sources properly |
| docker-compose.yml | Days 73-76 | Root directory | Reference combines all 8 services in a clean way |

---

### Learning Journey (Day-wise)

| Day | What I Learned |
|-----|--------------|
| Day 73 | Learned Prometheus basics, metrics, and PromQL |
| Day 74 | Added Node Exporter, cAdvisor and created Grafana dashboards |
| Day 75 | Learned Loki, Promtail and how logs work |
| Day 76 | Learned OpenTelemetry, traces, and basic alerting |
| Day 77 | Combined everything into one observability stack and created a dashboard |

---

### What I Would Add for Production

- Alertmanager to send alerts to Slack or email  
- Grafana Tempo to store traces properly  
- HTTPS for secure communication  
- Authentication for Grafana and Prometheus  
- Log retention and storage limits  
- High availability setup (multiple replicas)

---

### Comparison with Managed Tools

| Feature | My Stack | Managed Tools (Datadog, New Relic, CloudWatch) |
|--------|---------|-----------------------------------------------|
| Setup | Manual setup | Easy setup |
| Cost | Free (self-hosted) | Paid |
| Control | Full control | Limited control |
| Maintenance | Need to manage | Managed by provider |
| Scalability | Manual scaling | Auto scaling |

---

### Conclusion

In this task, I built a complete observability stack using Prometheus, Grafana, Loki, and OpenTelemetry.  
I learned how metrics, logs, and traces work together to monitor applications.

---

### Clean Up

To stop and remove everything:

```bash
docker compose down -v
