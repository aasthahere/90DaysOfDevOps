# Day 35 – Multi-Stage Builds & Docker Hub
## Task 1: The Problem with Large Images

   + Write a simple Go, Java, or Node.js app (even a "Hello World" is fine)
     <img width="1013" height="269" alt="Screenshot (263)" src="https://github.com/user-attachments/assets/69115074-39eb-456a-a6d2-8b7966b4b653" />

   + Create a Dockerfile that builds and runs it in a single stage
   ```
FROM node:latest
WORKDIR /app    
COPY . .
EXPOSE 3000
CMD ["node", "app.js"]
```
   + Build the image and check its size
      <img width="1423" height="123" alt="Screenshot (262)" src="https://github.com/user-attachments/assets/229f439c-1d09-47a2-9a97-eed4bddae4a3" />

Note down the size — you'll compare it later.

---
## Task 2: Multi-Stage Build

  Rewrite the Dockerfile using multi-stage build:
  ```
# Stage 1 – Install dependencies
FROM node:alpine AS builder
WORKDIR /app
COPY package.json package-lock.json* ./
RUN npm install --production
COPY . .

# Stage 2 – Runtime image
FROM node:alpine
WORKDIR /app
COPY --from=builder /app .
EXPOSE 3000
CMD ["node", "app.js"]
```
  Stage 1: Build the app (install dependencies, compile)
  
  Stage 2: Copy only the built artifact into a minimal base image (alpine, distroless, or scratch)
  
 Build the image and check its size again
 + ``` docker build -f Dockerfile.multistage -t hello-devops-multi .```

Compare the two sizes
<img width="1920" height="165" alt="Screenshot (268)" src="https://github.com/user-attachments/assets/c44f5356-5940-41e4-93ff-7d54ad42bdb9" />


Write in your notes: Why is the multi-stage image so much smaller?
- The final image does NOT inherit the full build environment

---

## Task 3: Push to Docker Hub

  + Create a free account on Docker Hub (if you don't have one)
  +  Log in from your terminal
      + docker login
  +  Tag your image properly: yourusername/image-name:tag
      + docker tag hello-devops aliyafirdous22/hello-devops:v1
  +  Push it to Docker Hub
  +  + docker push hello-devops:v1
  +  Pull it on a different machine (or after removing locally) to verify
     + docker pull aliyafirdous22/hello-devops:v1
<img width="1920" height="210" alt="Screenshot (271)" src="https://github.com/user-attachments/assets/2f9264ee-a3b4-4585-b396-a35562414cd3" />

---

## Task 4: Docker Hub Repository

  + Go to Docker Hub and check your pushed image
     + <img width="1920" height="263" alt="Screenshot (272)" src="https://github.com/user-attachments/assets/47e6eb35-0faf-40ae-9079-ad87dff46993" />

  +  Add a description to the repository
     + <img width="1916" height="534" alt="Screenshot (273)" src="https://github.com/user-attachments/assets/8dcee948-a7bd-453f-a959-207cfb90e2e7" />

  +  Explore the tags tab — understand how versioning works
     + if we give specific version tag like v1 it will pull exact that version
     + if we dont specify that this will pull by default latest
  +  Pull a specific tag vs latest — what happens?
     + latest tag is just by default 


---
## Task 5: Image Best Practices

+ Apply these to one of your images and rebuild:
  
    + Use a minimal base image (alpine vs ubuntu — compare sizes)
        + FROM node:20-alpine
   + Don't run as root — add a non-root USER in your Dockerfile Combine RUN commands to reduce layers
        + ```RUN addgroup -S appgroup && adduser -S appuser -G appgroup```
    Use specific tags for base images (not latest)
         + ```FROM node:20-alpine```
---

