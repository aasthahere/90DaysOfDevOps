# Day 34 – Docker Compose: Real-World Multi-Container App

---

## Task 1: Build Your Own App Stack

### Create a docker-compose.yml for a 3-service stack:
```
    A web app (use Python Flask, Node.js, or any language you know)
    A database (Postgres or MySQL)
     A cache (Redis)
```
### Write a simple Dockerfile for the web app. The app doesn't need to be complex — even a "Hello World" that connects to the database is enough.
<img width="1920" height="1002" alt="Screenshot (255)" src="https://github.com/user-attachments/assets/e3112068-e12a-4c3d-8386-2d56d1c90121" />


https://github.com/Aliyas-22/stack-project

---

## Task 2: depends_on & Healthchecks

   1) Add depends_on to your compose file so the app starts after the database
      
   2) Add a healthcheck on the database service
      
   3) Use depends_on with condition: service_healthy so the app waits for the database to be truly ready, not just started

### Test: Bring everything down and up — does the app wait for the DB?
     + yes its wait for db


<img width="1369" height="145" alt="Screenshot (248)" src="https://github.com/user-attachments/assets/4dac1a1b-16e0-4ef5-909b-1baefd0cad04" />
<img width="1216" height="116" alt="Screenshot (247)" src="https://github.com/user-attachments/assets/f199f942-aaf0-4b2d-b257-9f888a924719" />

---

## Task 3: Restart Policies

   1) Add restart: always to your database service
   2) Manually kill the database container — does it come back?
      ``` docker kill app-db-1```

<img width="997" height="394" alt="Screenshot (250)" src="https://github.com/user-attachments/assets/2f1fac2f-3f9b-4c8c-b66e-97112680a132" />
<img width="983" height="85" alt="Screenshot (249)" src="https://github.com/user-attachments/assets/af7ee1a6-5a36-4116-97ec-81fbf09dd851" />


   4) Try restart: on-failure — how is it different?
      
      + not restarted becuase nothing crash
   5) Write in your notes: When would you use each restart policy?
      
      + on-failure = auto-restart only on crash
      + unless-stopped = auto-restart unless tell it to stop
      + always = auto-restart no matter what




---

## Task 4: Custom Dockerfiles in Compose

  1) Instead of using a pre-built image for your app, use build: in your compose file to build from a Dockerfile
  ```
       web:
    build: . 
  ```
  2) Make a code change in your app
  3) Rebuild and restart with one command
      ``` docker compose up --build -d ```



---

## Task 5: Named Networks & Volumes

   1) Define explicit networks in your compose file instead of relying on the default
    
   2) Define named volumes for database data
    
   3) Add labels to your services for better organization
    
<img width="1475" height="252" alt="Screenshot (252)" src="https://github.com/user-attachments/assets/9b749d9c-1426-4c0d-80d8-2fe128b3da31" />
<img width="1194" height="282" alt="Screenshot (251)" src="https://github.com/user-attachments/assets/1b45a889-2875-4d0a-9df8-2b6eb53d6b9f" />

---

## Task 6: Scaling (Bonus)

 1) Try scaling your web app to 3 replicas using
 2) ```docker compose up --scale```
  
 3) What happens? What breaks?

<img width="1061" height="432" alt="Screenshot (254)" src="https://github.com/user-attachments/assets/801d36e6-8bef-4491-a492-949fa831cd82" />

    
 4) Write in your notes: Why doesn't simple scaling work with port mapping?
    + When we do scaling containers
    + each replica tries to bind to the same host port 5000
    + so the 5000 port can only be used by one container at a time
    + multiple replicas cannot share the same mapped port

---
