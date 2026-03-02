# Day 36 – Docker Project: Dockerize a Full Application

## Task 1: Pick Your App

- Choose one of these (or use your own project):

- A Python Flask/Django app with a database
- A Node.js Express app with MongoDB
- A static website served by Nginx with a backend API
- Any app from your GitHub that doesn't have Docker yet
- If you don't have an app, clone a simple open-source one and Dockerize it.

  ## Task 2: Write the Dockerfile
- Create a Dockerfile for your application
- Use a multi-stage build if applicable
- Use a non-root user
- Keep the image small — use alpine or slim base images
- Add a .dockerignore file
- Build and test it locally.

    -> system-health-monitor: https://github.com/Aliyas-22/Health-monitor-app
  ---
## Task 3: Add Docker Compose
Write a docker-compose.yml that includes:

Your app service (built from Dockerfile)

+ A database service (Postgres, MySQL, MongoDB — whatever your app needs)
  ```image: postgres:15-alpine```
+ Volumes for database persistence
 ```
volumes:
      - postgres_data:/var/lib/postgresql/data
```
Environment variables for configuration (use .env file)
Healthchecks on the database
Run docker compose up and verify everything works together.
  ---
## Task 4: Ship It
+ Tag your app image
   ```docker tag health-app aliyafirdous22/health-monitor```
  
+ Push it to Docker Hub
 ``` docker push aliyafirdous22/health-monitor```

Share the Docker Hub link
```docker pulls (https://hub.docker.com/repository/docker/aliyafirdous22/health-monitor/general)```
Write a README.md in your project with:

What the app does

How to run it with Docker Compose

Any environment variables needed
```markdown
readme.md :- https://github.com/Aliyas-22/Health-monitor-app/blob/32d8d9ca8fc13e923406a41ccdf8246227bb949b/README.md
```
---
# Task 5: Test the Whole Flow
+ Remove all local images and containers
+ Pull from Docker Hub and run using only your compose file
  ```
  images: aliyafirdous22/health-monitor
+ Does it work fresh? If not — fix it until it does
  ---
  
  <img width="1920" height="971" alt="Screenshot (275)" src="https://github.com/user-attachments/assets/f908e3ae-cd47-4264-b6ee-56d6b1036661" />





  
    
