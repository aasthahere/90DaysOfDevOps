## Real Issue Faced During Setup

### Problem:
While setting up Prometheus with the Django app, the `/metrics` 
endpoint was not working.
Prometheus was showing the target as DOWN instead of UP.

### Symptoms:
- Django app was running correctly
- API endpoints were working fine
- But `http://localhost:8000/metrics` was returning 404
- Prometheus target status was showing DOWN

### Root Cause:
The Django app was missing the Prometheus integration setup.
Three things were missing:

| Missing Part | Why it is needed |
|-------------|-----------------|
| `django-prometheus` package | Adds metrics collection to Django |
| Middleware configuration | Tracks every request automatically |
| `/metrics` URL endpoint | Exposes metrics for Prometheus to scrape |


---

### If you face the same issue, check this repo:
  + you can take help from this repo

https://github.com/srdangat/90DaysOfDevOps/blob/master/2026/day-73/observability-stack/FIx.md

### Important Note:
> If you change requirements.txt or any Python file,
> you must rebuild the Docker image.
> Just restarting the container will NOT apply the changes.
> Use `docker compose up --build` to rebuild.
