# Day 32 – Docker Volumes & Networking
## Task 1: The Problem
  + Run a Postgres or MySQL container
      + ```docker -d -e MYSQL_PASSWORD=root mysql:latest```
  + Create some data inside it (a table, a few rows — anything)
      + ``` docker exec -it <id> bash```
      + ```mysql -u root -p```
      + ```SHOW DATABASES;```
      + ```CREATE DATABASES learning-data```
  + Stop and remove the container
      + ```docker stop <id>```
      + ```dcoker rm <id>```
  + Run a new one — is your data still there?
      + ```docker -d -e MYSQL_PASSWORD=root mysql:latest```
      + checked !!! the created database is not there
  + Write what happened 
      + the created database is not there means its deleted
      + if we delete the continer we loss the data
        ## why
        + because the contianer have there own storage so if we remove the container we loss the both store data and container.

<img width="1920" height="457" alt="Screenshot (207)" src="https://github.com/user-attachments/assets/14f11da5-39fc-4fa5-8cc3-36b80cf2eb26" />
<img width="1826" height="421" alt="Screenshot (206)" src="https://github.com/user-attachments/assets/c181fb0a-6782-4078-86e2-08bf6d97ad70" />

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Task 2: Named Volumes
+ Create a named volume
   + ```docker volume create learning-mysql```
+ Run the same database container, but this time attach the volume to it
   + ```docker -d -v learnig-mysql-data:/var/lib/mysql -e MYSQL_PASSWORD=root mysql:latest```
+ Add some data, stop and remove the container
   + ``` CREATE DATABASES Learning-data```
   + ``` docker stop <id>```
   +``` docker rm <id>``` 
+ Run a brand new container with the same volume
  +```docker -d -v learnig-mysql-data:/var/lib/mysql -e MYSQL_PASSWORD=root mysql:latest```
+ Is the data still there?
  ## yes the data is there!!!
+ Verify: docker volume ls, docker volume inspect
  + ```docker volume ls```
  + ``` docker volume inspect learning-msql```

<img width="1920" height="165" alt="Screenshot (217)" src="https://github.com/user-attachments/assets/b174d72c-554d-4b5b-81a5-7b50a81b5921" />
<img width="1401" height="446" alt="Screenshot (213)" src="https://github.com/user-attachments/assets/2fdf2a50-bf6b-427f-b645-3b6cbe23590e" />
<img width="1211" height="203" alt="Screenshot (218)" src="https://github.com/user-attachments/assets/711a57fd-b357-44f4-8e88-027e985b26f1" />


----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Task 3: Bind Mounts
+ Create a folder on your host machine with an index.html file
   + vim index.html
+ Run an Nginx container and bind mount your folder to the Nginx web directory
   + ``` docker run -d --name nginx-bind-test -p 8080:80 -v .:/usr/share/nginx/html nginx```

<img width="1337" height="352" alt="Screenshot (223)" src="https://github.com/user-attachments/assets/24ec2cba-dd2d-4e0e-9495-9a32c1771334" />

+ Access the page in your browser

<img width="1920" height="291" alt="Screenshot (221)" src="https://github.com/user-attachments/assets/699e5125-3457-4d56-80bc-01d4b9d51b64" />

  
+ Edit the index.html on your host — refresh the browser
  + inside the heading i edit (i updated it )

    
 <img width="1920" height="264" alt="Screenshot (222)" src="https://github.com/user-attachments/assets/20efa0a8-54fb-485f-9b75-4f2122f05c4d" />

  
+ Write in your notes: What is the difference between a named volume and a bind mount?
   + A bind mount directly links a folder from host to a container so if any file change is seen immediately.
   + A named volume is stored and managed by Docker separately and is not directly tied to host machine folder.



------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Task 4: Docker Networking Basics
+ List all Docker networks on your machine
   + ```docker network ls```
+ Inspect the default bridge network
   + ```docker network inspect bridge```
+ Run two containers on the default bridge — 
   + ```docker run -d --name mysql_db4 -e MYSQL_PASSWORD=root mysql:latest```
   + ```docker run -it --name app-container1 ubuntu```
   + ```docker exec -it app-container1 bash```
   + ``` ping msql_db4 ```
 ## can they ping each other by name?
   ### NO they DONT ping each other by the name 
+ Run two containers on the default bridge — 
   + ``` docker run -d --name mysql_db4 -e MYSQL_PASSWORD=root mysql:latest```
   + ```docker run -it --name app-container1 ubuntu```
   + ```docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' app-container1```
   + ```we will get the ip ```
   + ```docker exec -it mysql_db4 bash```
   + ``` ping <ip>```
 ## can they ping each other by IP?
   ### yes the ping each other by the ip..


<img width="1270" height="233" alt="Screenshot (214)" src="https://github.com/user-attachments/assets/7bd08b6c-8e61-4d1c-955c-caddfd648465" />

  -----------------------------------------------------------------------------------------------------------------------------------------------------------------------   

  # Task 5: Custom Networks
+ Create a custom bridge network called my-app-net
   + ```docker run -it --name try-container --network my-app-nett ubuntu```
+ Run two containers on my-app-net
   + ```docker run -it --name try2-container --network my-app-nett mongo```
+ Can they ping each other by name now?
   + ```ping try-container```
     ### YES they ping each other by name 
+ Write in your notes: Why does custom networking allow name-based communication but the default bridge doesn't?
     + The default bridge network does not include Docker’s built-in DNS, so container names are not automatically resolved.
        + A custom bridge network enables Docker’s internal DNS, which maps container names to their IP addresses.
          + Therefore, name-based communication works only on custom networks, while the default bridge supports IP-based communication only.

<img width="1695" height="264" alt="Screenshot (220)" src="https://github.com/user-attachments/assets/8c33252f-bdc4-431d-b77e-c75481dd49da" />

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Task 6: Put It Together
+ Create a custom network
   + ```docker network create my-app-net```
+ Run a database container (MySQL/Postgres) on that network with a volume for data
   + ```docker -d  -v learnig-mysql-data:/var/lib/mysql -e MYSQL_PASSWORD=root mysql:latest```
+ Run an app container (use any image) on the same network
   + ```docker run -it --name app-container1 --network my-app-net ubuntu```
     
+ Verify the app container can reach the database by container name
   +```docker exec -it < id > mysql -u root -p```
   + ```ping app-contsiner1```
   + YES the cantainer reach to database by its name
 
     
     <img width="1401" height="345" alt="Screenshot (216)" src="https://github.com/user-attachments/assets/2f2bcc56-ec17-49b3-9fa2-54a632800833" />


---------------------------------------------------------------------------------------------------------------------------------------------------------
     
