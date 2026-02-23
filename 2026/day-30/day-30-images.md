# Day 30 – Docker Images & Container Lifecycle
## Task 1: Docker Images

+   Pull the nginx, ubuntu, and alpine images from Docker Hub
      + ```docker pull nginx```
      + ```docker pull ubuntu```
      + ``` docker pull alpine``` 
+   List all images on your machine — note the sizes
      + ``` docker images```
+   Compare ubuntu vs alpine — why is one much smaller?
      + ubuntu image size is - 119MB
      + alpine image size is - 13.1MB
      + why??
           + because alpine is minimal and it only have basic Linux tools inside while ubuntu have many packages ,system utilities.
+   Inspect an image — what information can you see?
      + i can see so many information such as
           + id
           + env
           + cmd
           + labels
           + sizze layers
           + meta data
           + discriptor
           + pull
+   Remove an image you no longer need
      + ``` docker rmi <image name>```
 
<img width="1413" height="123" alt="Screenshot (186)" src="https://github.com/user-attachments/assets/eee0ee27-a8e7-4d28-a384-65a78cf3ee21" />


------------------------------------------------------------------------------------------------------------------------
#  Task 2: Image Layers

  + Run docker image history nginx — what do you see?
      + ```docker history nginx```
      + what i see is IMAGE history,
      + CREATED,
      + CREATED BY and
      + SIZE ,
      + COMMENT
  + Each line is a layer. Note how some layers show sizes and some show 0B
      + 341bf0f3ce6c   2 weeks ago   CMD ["nginx" "-g" "daemon off;"]                0B        b
  + Write in your notes: What are layers and why does Docker use them?
     + layers are the read only files that only shows the how the image is building


<img width="1262" height="419" alt="Screenshot (194)" src="https://github.com/user-attachments/assets/cc072059-eaa6-47a8-8729-393f68aed5d5" />

-------------------------------------------------------------------------------------------------------------------------------

# ask 3: Container Lifecycle

## Practice the full lifecycle on one container:

  + Create a container (without starting it)
    + ```docker create --name my_container ubuntu```
  +  Start the container
     + ```docker start <id>```
  +  Pause it and check status
     + ```docker pause <id>```
     + ```docker ps -a```
  +  Unpause it
     + ```docker unpused <id>```
  +  Stop it
     + ``` docker stop <id>```
  +  Restart it
     + ```docker resatrt <id>```
  +  Kill it
     + ```docker kill <id>```
   + Remove it
     + ```docker rm <id>```
+ Check docker ps -a after each step — observe the state changes.


<img width="1466" height="521" alt="Screenshot (189)" src="https://github.com/user-attachments/assets/2e7c09c8-728c-4cb5-9621-65d367b68c5d" />
-----------------------------------------------------------------------------------------------------------------------------------

 # ask 4: Working with Running Containers

  +  Run an Nginx container in detached mode
     + ```docker run -d nginx```
  +  View its logs
     + ``` docker logs <id>```
  +  View real-time logs (follow mode)
     + ```docker logs -f <id>```
  +  Exec into the container and look around the filesystem
     + ```docker exec -it <id> bash```
     + pwd
     + ls
     + cd /bin
  +  Run a single command inside the container without entering it
     + ```docker exec -it <id> sh-c <command>```
     + ```docker exec -it d22 sh -c "cd /bin && ls"```
  +  Inspect the container — find its IP address, port mappings, and mounts
     + ```docker inspect --format='{{.NetworkSettings.IPAddress}}' <id>```
     + ```docker inspect --format='{{.NetworkSettings.Ports}}' <id>```
     + ```docker inspect --format= '{{.Mounts}}' <id> ```
<img width="1373" height="523" alt="Screenshot (193)" src="https://github.com/user-attachments/assets/5ea87c97-0269-4779-af8e-9b21968556f5" />

<img width="1181" height="350" alt="Screenshot (190)" src="https://github.com/user-attachments/assets/481d7478-6038-4adf-98b9-3ae3d98d4779" />


     <img width="1477" height="451" alt="Screenshot (188)" src="https://github.com/user-attachments/assets/acc65d96-0255-4df2-bb93-9cbe75bcaa2b" />

-------------------------------------------------------------------------------------------------------------------------------------


# Task 5: Cleanup

 + Stop all running containers in one command
      + ```docker rm -f container_name_1 container_name_2 container_name_3```
 + Remove all stopped containers in one command
      + ```docker container prune ```
 + Remove unused images
     + ```docker image prune ```
 + Check how much disk space Docker is using
     + ```docker systemdf```

      <img width="1920" height="991" alt="Screenshot (192)" src="https://github.com/user-attachments/assets/211997c5-0943-4a6e-939c-c4ceef9ffe46" />

----------------------------------------------------------------------------------------------------------------------------------

