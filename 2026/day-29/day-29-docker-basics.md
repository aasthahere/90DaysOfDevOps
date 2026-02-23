# Day 29 – Introduction to Docker
## Task 1: What is Docker?
  ### Docker is contenarization tool used to build, package, and run applications in containers.
  
### Research and write short notes on:

  + What is a container and why do we need them?
      + A container is a lightweight package that contains an application and all its dependencies so it can run consistently on any system.
  + Containers vs Virtual Machines — what's the real difference?
      + A Virtual Machine is like running a full computer inside another computer.
      + it has its own OS
      + its own memory
      + its own CPU slice Heavy, but very isolated.
  + What is the Docker architecture? (daemon, client, images, containers, registry)
      + docker client :- This is the user interface this take cammand from user
           + docker build
           + docker run
           + docker pull
      + docker daemon :- barin of the docker
           + build images
           + runs cantainer
           + manages network & volumes
      + docker images:- are the blueprint
           + application code
           + libraries
           + dependencies
           + instruction
      + docker containarization:- the running instance of image
           + executes the application
           + lightweight and fast
           + can be start/stop
      + docker registry :- where the images are stored
           + docker hub
           + stores images
           + share images 
      + Draw or describe the Docker architecture in your own words
           + type a command -> Docker Client
           + Client sends request -> Docker Daemon
           + Daemon:- pulls image from Registry creates Container from Image
           + Container runs the app


  

-----------------------------------------------------------------------------------------------------------------------------

 # Task 2: Install Docker
 
  + Install Docker on your machine (or use a cloud instance)
  + Verify the installation
  + Run the hello-world container
     ```+ docker run hello-world ```
  + Read the output carefully — it explains what just happened


<img width="1920" height="1012" alt="Screenshot (180)" src="https://github.com/user-attachments/assets/ce8193be-d187-4037-b0d8-ea4048bed63b" />

-------------------------------------------------------------------------------------------------------------------------------

Task 3: Run Real Containers

+ Run an Nginx container and access it in your browser
    + ``` docker run -d -p 8080:80 nginx```
    + ``` http://localhost:8080/```
+ Run an Ubuntu container in interactive mode — explore it like a mini Linux machine
   +``` docker exec -it <id> bash ```
+ List all running containers
   + ``` docker ps```
+ List all containers (including stopped ones)
   + ``` docker ps -a ``` 
+ Stop and remove a container
  + ``` docker start <id>```
  + ``` docker rm <id> ```
<img width="1920" height="970" alt="Screenshot (182)" src="https://github.com/user-attachments/assets/6014f773-6214-4fbf-ba45-08d0d8ad1a10" />

<img width="1485" height="382" alt="Screenshot (184)" src="https://github.com/user-attachments/assets/9c509657-6714-4113-8301-af27f9b81c6d" />

-------------------------------------------------------------------------------------------------------------------------------


# Task 4: Explore

+  Run a container in detached mode — what's different?
    + when we run in container in detach mode it  run in the background ,and we can use terminal 
+   Give a container a custom name
    + ``` docker run --name <container_name> <image_name>```
+   Map a port from the container to your host
    + ```docker run -d -p 8080:80 nginx```
+   Check logs of a running container
    + ``` docker logs```
+   Run a command inside a running container
    + ``` docker exec -it <id> bash```
<img width="1920" height="1025" alt="Screenshot (183)" src="https://github.com/user-attachments/assets/727527fc-829c-4c6b-964a-9049d267d38a" />



-------------------------------------------------------------------------------------------------------------------------------
      

    
