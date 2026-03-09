# Day 44 – Secrets, Artifacts & Running Real Tests in CI
## Task 1: GitHub Secrets

+    Go to your repo → Settings → Secrets and Variables → Actions
+    Create a secret called MY_SECRET_MESSAGE
+    Create a workflow that reads it and prints: The secret is set: true (never print the actual value)
+    Try to print ${{ secrets.MY_SECRET_MESSAGE }} directly — what does GitHub show?
      + github shows the stars *** like this to hide the creditials or informations..

+  Write in your notes: Why should you never print secrets in CI logs?
    + should never print secrets in CI logs because the logs can be seen by other people, and your sensitive information can get stolen.
 
<img width="1920" height="591" alt="Screenshot (325)" src="https://github.com/user-attachments/assets/8f40188c-c81c-4b61-a386-ce01f8ba2a0a" />

---

## Task 2: Use Secrets as Environment Variables

  +  Pass a secret to a step as an environment variable
  +  Use it in a shell command without ever hardcoding it
  +  Add DOCKER_USERNAME and DOCKER_TOKEN as secrets (you'll need these on Day 45)


<img width="1920" height="697" alt="Screenshot (326)" src="https://github.com/user-attachments/assets/32392576-5b9d-4421-be23-33810c5a6be2" />

---

## Task 3: Upload Artifacts

  + Create a step that generates a file — e.g., a test report or a log file
  +  Use actions/upload-artifact to save it
  +  After the workflow runs, download the artifact from the Actions tab

+ Verify: Can you see and download it from GitHub?
  + yes i can download it from github
 
<img width="1920" height="934" alt="Screenshot (327)" src="https://github.com/user-attachments/assets/4d98e9fa-a9a1-4547-9050-3bfd8d9a41e0" />
<img width="1920" height="757" alt="Screenshot (329)" src="https://github.com/user-attachments/assets/082bc34f-0fc4-4f8a-86d3-421ef32c805e" />
<img width="1920" height="886" alt="Screenshot (328)" src="https://github.com/user-attachments/assets/befc5702-520f-479e-a5b7-fde4214a05d5" />

  ---

  ## Task 4: Download Artifacts Between Jobs

  +  Job 1: generate a file and upload it as an artifact
  +  Job 2: download the artifact from Job 1 and use it (print its contents)

+ Write in your notes: When would you use artifacts in a real pipeline?

  + Artifacts are used in a pipeline to store and share files generated during a job, such as test reports, build outputs, or logs.

<img width="1920" height="870" alt="Screenshot (330)" src="https://github.com/user-attachments/assets/495a3ec2-c10a-4452-ab0a-7a1f61682bc2" />

---

## Task 5: Run Real Tests in CI

Take any script from your earlier days (Python or Shell) and run it in CI:

+  Add your script to the github-actions-practice repo
+    Write a workflow that:
       + Checks out the code
      +  Installs any dependencies needed
      + Runs the script
      + Fails the pipeline if the script exits with a non-zero code
    + Intentionally break the script — verify the pipeline goes red
    + Fix it — verify it goes green again

  ---<img width="1920" height="919" alt="Screenshot (332)" src="https://github.com/user-attachments/assets/b8fe6fc6-9193-48d0-a98a-ecefcf2abe59" />

  ## Task 6: Caching

  +  Add actions/cache to a workflow that installs dependencies
  +  Run it twice — observe the time difference
  +   Write in your notes: What is being cached and where is it stored?
    + Python dependencies installed from requirements.txt
    + In the ~/.cache/pip directory and this stored in GitHub Actions cache storage
<img width="1920" height="831" alt="Screenshot (334)" src="https://github.com/user-attachments/assets/d5195692-310a-41a9-b41b-2f2d587b88a3" />
<img width="1920" height="674" alt="Screenshot (333)" src="https://github.com/user-attachments/assets/4261d6a9-7bc0-4be8-87a9-27e4e0ec435f" />

---
      


