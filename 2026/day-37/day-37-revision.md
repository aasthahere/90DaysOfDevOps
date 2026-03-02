# Day 37 – Docker Revision

## Self-Assessment Checklist

### Mark yourself honestly — can do, shaky, or haven't done:

+ Run a container from Docker Hub (interactive + detached)
+ List, stop, remove containers and images
+ Explain image layers and how caching works
+ Write a Dockerfile from scratch with FROM, RUN, COPY, WORKDIR, CMD
+ Explain CMD vs ENTRYPOINT
+ Build and tag a custom image
+ Create and use named volumes
+ Use bind mounts
+ Create custom networks and connect containers
+ Write a docker-compose.yml for a multi-container app
+ Use environment variables and .env files in Compose
+ Write a multi-stage Dockerfile
+ Push an image to Docker Hub
+ Use healthchecks and depends_on
---
## can do
Run a container from Docker Hub (interactive + detached)
✅ List, stop, remove containers and images

✅ Explain image layers and how caching works

✅ Write a Dockerfile from scratch with FROM, RUN, COPY, WORKDIR, CMD

✅Explain CMD vs ENTRYPOINT

✅ Build and tag a custom image

✅ Create and use named volumes

✅ Use bind mounts

✅Create custom networks and connect containers

✅ Write a multi-stage Dockerfile

✅Push an image to Docker Hub

✅ Use healthchecks and depends_on
---
## shaky
❗ Write a docker-compose.yml for a multi-container app

❗ Use environment variables and .env files in Compose
---
## Quick-Fire Questions
### Answer from memory, then verify:


1) What is the difference between an image and a container?
   + An image is basically a blueprint that contains dependencies.
   +  A container runs with the help of that blueprint.

2) What happens to data inside a container when you remove it?
  + if data is stored inside the container filesystem
   + it is deleted when the container is removed.
   
3) How do two containers on the same custom network communicate?
    + When two containers are on the same custom bridge network:
          + They communicate using container names as hostnames
             + Docker provides automatic DNS resolution
   
4) What does docker compose down -v do differently from docker compose down?
         ```docker compose down ``` Stops and removes containers, networks
   
         ```docker compose down -v ``` Also removes volumes
   
5) Why are multi-stage builds useful?
   + Multi-stage builds is usefull because
     + Build the application in one stage
        + Copy only required things
        + Exclude build tools and dependencies
   
8) What is the difference between COPY and ADD?

  + ``` copy``` Copies files from local system to image
  + ```ADD``` Copies files AND has extra features
  + ``` copy``` is Simple file copy
  +  ```add``` Can extract tar files automatically
    
9) What does -p 8080:80 mean?
    + ```-p``` means port mapping.
   + ``` 8080``` Port oof local machine
    + ```80 ``` Port inside container
    + basically it bind with cantainer port
    
11) How do you check how much disk space Docker is using?
  ```docker system df```

 ---
##  Revisit Weak Spots

### Pick 2 topics you marked as shaky and redo the hands-on tasks from that day.

 ❗ Write a docker-compose.yml for a multi-container app

   ``` 
services:
  db:                                   
    image: mysql:5.7
    container_name: my-mysql
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: rootpassword
      MYSQL_DATABASE: wordpress
      MYSQL_USER: firdous
      MYSQL_PASSWORD: 12345
    volumes:
      - myvol:/var/lib/mysql               
  wordpress:                     
    image: wordpress:latest
    container_name: my-wordpress
    restart: always
    ports:
      - "8080:80"
    environment:
      WORDPRESS_DB_HOST: db:3306
      WORDPRESS_DB_USER: firdous
      WORDPRESS_DB_PASSWORD: 12345
      WORDPRESS_DB_NAME: wordpress
    depends_on:
      - db                               

volumes:
  myvol:   
  ```
❗ Use environment variables and .env files in Compose
```
  services:
  db:
    image: mysql:5.7
    environment:
      MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD}
      MYSQL_DATABASE: ${MYSQL_DATABASE}
      MYSQL_USER: ${MYSQL_USER}
      MYSQL_PASSWORD: ${MYSQL_PASSWORD}
```

      



