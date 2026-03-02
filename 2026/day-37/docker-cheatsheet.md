# Day-37 Cheat Sheet
## Build Your Docker Cheat Sheet
---
### Container commands — 

+ run : Creates and starts a new container from an image.
  
                                                           ```docker run nginx```
  
+ ps:  Shows running containers
   
                                                               ```docker ps ```
+ ps -a:
  
                                                             ```  docker ps -a```
  
+ stop:Stops a running container
  
                                                            ```docker stop <container id>```
  
+ rm: Removes a container
  
                                                             ``` docker rm <container id>```
  
+ exec: Executes command inside running container
  
                                                           ```docker exec -it <container_id> bash```
  
+ logs: Shows container logs
  
                                                              ``` docker logs <containerid>```
     

---
---
### Image commands —
+ build: Build image from Dockerfile
  
                                                                 ```docker build -t new-app . ```
  
 + pull: Pull image from Docker Hub
   
                                                                      ``` docker pull nginx```

   
+ push:Push image to Docker Hu
  
                                                                     ``` docker push aliyafirdous22/image```

+ tag: Add tag to image
  
                                                                   ``` docker tag myimage username/myimage:latest```
  
+ ls: List images
  
                                                                              ```docker images```
  
+ rmi: remove image
  
                                                                           ``` docker rmi image```

---
### Volume commands —

+ create: Create volume
  
                                                                           ```docker volume create myvolume```
  
+ ls:List volumes
  
                                                                                 ```docker volume ls```
  
+ inspect: Inspect volume details
  
                                                                               ```docker volume inspect```
  
+ rm:Remove volume
  
                                                                                    ```docker volume rm```
  

---
---
###  Network commands —
+ create: Create network
  
                                                                                    ``` docker network create```
  
+ ls: List networks
  
                                                                                     ```docker network ls```
  
+ inspect: Inspect network
  
                                                                                     ```docker network inspect```
  
+ connect: Connect container to network
  
                                                                                    ```docker network connect mynetwork mycontainer```
  
---
---
### Compose commands — 
+ up: Create and start containers
  
                                                                                        ```docker compose up -d```
  
+ down: Stop and remove containers & networks
  
                                                                                          ```docker compose down```
  
+ ps:List compose containers
  
                                                                                              ```docker compose ps```
  
+ logs:View logs
  
                                                                                              ```docker compose logs```
  
+ build: Build images defined in compose file
  
                                                                                                 ```docker compose build```
  

---
### Cleanup commands — 
+ prune: Remove unused:Containers,Networks, Images ,Cache
  
                                                                                                  ```docker system prune```

+ system df: Show Docker disk usage
  
                                                                                                     ```docker system df```

---
---
### Dockerfile instructions — 

+ FROM: Defines base image
   
                                                                                                   ```FROM python:3.10```
  

+ RUN: Executes command during image build
  
                                                                                                        ```RUN apt update```

  
+ COPY: Copies files from local = image
  
+ WORKDIR: Sets working directory inside container
  
                                                                                                          ```WORKDIR /app```
  
+ EXPOSE: Documents which port container uses
  
                                                                                                            ``` 8080:80```
  
+ CMD: Default command to run when container starts
  
                                                                                                          ```CMD ["python", "app.py"]```
  
+ ENTRYPOINT: Sets main command that always runs.
  

---
Keep it short — one line per command, something you'd actually reference on the job.

---
