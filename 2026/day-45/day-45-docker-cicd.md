# Day 45 – Docker Build & Push in GitHub Actions

## Task 1: Prepare
+ Use the app you Dockerized on Day 36 (or any simple Dockerfile)

  https://github.com/Aliyas-22/github-actions-practice-2/tree/main

  
+ Add the Dockerfile to your github-actions-practice repo (or create a minimal one)
  
+ Make sure DOCKER_USERNAME and DOCKER_TOKEN

  ---

  ## Task 2: Build the Docker Image in CI
+ Create .github/workflows/docker-publish.yml that:

+ Triggers on push to main
+ Checks out the code
+ Builds the Docker image and tags it
+ Verify: Check the build step logs — does the image build successfully?
   + yes : image is build successfully

  ---

  ## Task 3: Push to Docker Hub

+ Add steps to:

+ Log in to Docker Hub using your secrets
    + ```YML
       username: ${{vars.DOCKERHUB_USERNAME}}
       password: ${{secrets.DOCKERHUB_TOKEN}}
      ```
      
  
+ Tag the image as username/repo:latest and also username/repo:sha-<short-commit-hash>

  ```YML
    ${{vars.DOCKERHUB_USERNAME}}/github-action-practice-2:latest
    ${{vars.DOCKERHUB_USERNAME}}/github-action-practice-2:${{ github.sha }}
  ```

+ Push both tags
+ Verify: Go to Docker Hub — is your image there with both tags?
+ yes my image is there!
<img width="1920" height="913" alt="Screenshot (336)" src="https://github.com/user-attachments/assets/1e6c73b8-6506-459f-8c07-0430d3a2b845" />
<img width="1920" height="610" alt="Screenshot (337)" src="https://github.com/user-attachments/assets/8dea2d1f-37df-447f-b8ac-2fafb5bd5863" />


  ---

  ## ask 4: Only Push on Main
  + Add a condition so the push step only runs on the main branch — not on feature branches or PRs.
 
    ```YML
  
      if: github.ref == 'refs/heads/mai
      push: false
    ```

  + Test it: push to a feature branch and verify the image is built but NOT pushed.
         + my image is build but not push to dockerHub

<img width="1920" height="818" alt="Screenshot (338)" src="https://github.com/user-attachments/assets/aae7040b-ff4f-40a9-ba4a-6b8b0797cb10" />


    ---

    ## Task 5: Add a Status Badge
 + Get the badge URL for your docker-publish workflow from the Actions tab
 + Add it to your README.md
 + Push — the badge should show green

   

    <img width="1920" height="873" alt="Screenshot (335)" src="https://github.com/user-attachments/assets/c8a78cd5-8445-4d36-8e39-0f960bb2b0c1" />

    ---

   ## Task 6: Pull and Run It
+ On your local machine (or a cloud server), pull the image you just pushed
+ Run it
+ Confirm it works
+ Write in your notes: What is the full journey from git push to a running container?
```
1.  i write code on my laptop
        ↓
2. git push → goes to GitHub
        ↓
3. GitHub Actions workflow triggers automatically
        ↓
4. Runner checks out my code
        ↓
5. Runner logs in to DockerHub
        ↓
6. Runner builds my Docker image
        ↓
7. Runner pushes image to DockerHub
        ↓
8. i pulls the image from DockerHub
        ↓
9. docker-compose up → container is running

```

  <img width="1171" height="248" alt="Screenshot (341)" src="https://github.com/user-attachments/assets/4154c07c-2357-43b5-bf01-41d81e8df233" />
<img width="1920" height="918" alt="Screenshot (340)" src="https://github.com/user-attachments/assets/f2875029-ea0d-460a-92bd-87cd15a9d1b5" />




