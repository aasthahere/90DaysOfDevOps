# Day 31 – Dockerfile: Build Your Own Images
## Task 1: Your First Dockerfile
  + Create a folder called my-first-image
     + mkdir my-first-image
  + Inside it, create a Dockerfile that:
     + vim Dockerfile
      + Uses ubuntu as the base image
          + FROM ubuntu
      + Installs curl
          + RUN apt-update && apt install curl
            
     + Sets a default command to print "Hello from my custom image!"
          + CMD ["echo" "hello from my custom image"]
  + Build the image and tag it my-ubuntu:v1
    
    + docker build -it my-ubuntu:v1 .
  + Run a container from your image
    
      + docker run -it --name  echo my-ubuntu:v1


<img width="1704" height="147" alt="Screenshot (197)" src="https://github.com/user-attachments/assets/202dd05a-bf0b-483f-98a9-eb4a7cc77c07" />

 
  ## Task 2: Dockerfile Instructions
  
  # Create a new Dockerfile that uses all of these instructions:

FROM — base image

RUN — execute commands during build

COPY — copy files from host to image

WORKDIR — set working directory 

EXPOSE — document the port

CMD — default command

```
FROM python:3.14

WORKDIR /project

COPY . /project

RUN pip install -r requirement.txt

EXPOSE 8000

CMD ["uvicorn","app.api:app", "--host", "0.0.0.0", "--port", "8000"]
```
+ Build and run it.
  
    + ```docker build -t capstone-project```
    + ```docker run -d -p 8000:8000 capstone-project```

+  Understand what each line does.
  
  + FROM python:3.14 :- this will pull the image from docker-hub
    
  + WORKDIR /project :- this will create the directory by the name of project ,this is as same as mkdir
      
  + COPY . /project :- this will copy everything from source to destination like , (.) present direcotry and /project is destination
    
  + RUN pip install - r requirement.txt :- this will install the libraries/dependencies inside
    
  + EXPOSE 8000 :- this is not neccessary but this will give hint to docker which port cantainer to use
    
  + CMD ["uvicorn","app.api:app", "--host", "0.0.0.0", "--port", "8000"] :- in this we basically pass the cammand that run the application



--------------------------------------------------------------------------------------------------------------------------------------------

# Task 3: CMD vs ENTRYPOINT
+ Create an image with CMD ["echo", "hello"] — run it, then run it with a custom command.
  
    + mkdir learning-docker -> vim Dockerfile ->
     ```
     FROM ubuntu
     CMD ["echo" , "hello"]
    ```
   + docker build -t let-ubuntu .
   + docker echo  hi let-ubuntu

     
+ What happens?
   + using custom command it completely replaces the CMD written in the Dockerfile.
     + output ```hi```

      
+ Create an image with ENTRYPOINT ["echo"] — run it, then run it with additional arguments. What happens?
    + mkdir learning-docker2 -> vim docker ->
      ```
      FROM ubuntu
      ENTRYPOINT ["echo"]
      ```
   + docker build -t lets-ubuntu .
   + docker run lets-ubuntu hello world

     
+ What happens?
   + i see the passes argument are added to the ENTRYPOINT command
   +  so whatever argument I pass appears exactly in the output.
     + output ``` hello world```   
+ Write in your notes: When would you use CMD vs ENTRYPOINT?
  
  ### CMD
  + CMD is used when we want to set a default command in the Dockerfile
  + If the user does not pass anything while running the container
  +  Docker executes the CMD
  +  But if the user passes a command CMD gets overridden



  ### ENTRYPOINT
  + ENTRYPOINT is used when we want a fixed command that always runs
  +  Whatever arguments we pass while running the container are added to the ENTRYPOINT command


<img width="1920" height="165" alt="Screenshot (198)" src="https://github.com/user-attachments/assets/129e5823-02d1-4ae7-bcf7-b79d69af0a97" />
<img width="1755" height="194" alt="Screenshot (199)" src="https://github.com/user-attachments/assets/21911bca-fa09-4f91-9eec-bbbae796a2b1" />


----------------------------------------------------------------------------------------------------------------------------------------
# Task 4: Build a Simple Web App Image
+ Create a small static HTML file (index.html) with any content
   + created devops-portfolio website
+ Write a Dockerfile that:
   + Uses nginx:alpine as base
   + Copies your index.html to the Nginx web directory
     ```
          FROM nginx:alpine
          WORKDIR /app
          COPY index.html /usr/share/nginx/html
          EXPOSE 80
     ```
   + Build and tag it my-website:v1
      + docker build -t my-website:v1 .
+ run it with port mapping and access it in your browser
  
  + docker run -d -p 80:8000 my-website:v1


<img width="1920" height="1002" alt="Screenshot (195)" src="https://github.com/user-attachments/assets/5d53410f-3864-45f5-89e0-1752fca16f57" />

 - `````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````

 # Task 5: .dockerignore
 + Create a .dockerignore file in one of your project folders
+ Add entries for: node_modules, .git, *.md, .env
    + + .evn
    + .*.md
    + .git
+ Build the image — verify that ignored files are not included
   + docker build -t 
   + docker run -d -p 8000:8000 capstone-project
   + docker exec -it capstone-project sh
   + cd /
   + ls
   + there readme.md file is not included
     
<img width="1097" height="194" alt="Screenshot (202)" src="https://github.com/user-attachments/assets/fff3769f-3d22-4fcb-98e6-ae47d307ae58" />
<img width="1061" height="345" alt="Screenshot (200)" src="https://github.com/user-attachments/assets/bdad9d54-0f42-403b-9227-2b6e2c540b82" />

----------------------------------------------------------------------------------------------------------------------------------------

# Task 6: Build Optimization

   + Build an image, then change one line and rebuild — notice how Docker uses cache
      + created file first
        ```
        FROM ubuntu
        RUN apt-get update
        RUN apt-get install -y curl
        CMD ["echo", "hello"]
        ```
     + All steps are running normally
        + then change one on line
       ### what i see is
            ```
              CACHED [2/3] RUN apt-get update                                                                                                         0.0s
            => CACHED [3/3] RUN apt-get install -y curl              
            ```
      ###  because:-    
        + Docker builds an image step by step, and each instruction in a Dockerfile creates a layer
        + When we rebuild an image Docker checks each instruction from top
        + If instruction has not changed and its previous layer already there
        + Docker reuses the cached layer instead of running that instruction again
  + Reorder your Dockerfile so that frequently changing lines come last
    
    + created dockerfile
    + change from the last and added changes in dockerfile
    ### what i see is
    + when i make changes from the container use cache
    + so things will run fast
       
   + Write in your notes: Why does layer order matter for build speed?
     
     + Docker builds images layer by layer from top to bottom so 
     + If a layer changes Docker use the cache for that layer and rebuilds all layers after it
     + This reduces rebuild time and improves build speed
       
<img width="1300" height="470" alt="Screenshot (201)" src="https://github.com/user-attachments/assets/667c74ed-3bcc-4522-9139-1f6c1f04d953" />


------------------------------------------------------------------------------------------------------------------
  
  
