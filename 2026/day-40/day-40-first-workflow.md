
# Day 40 – Your First GitHub Actions Workflow
## Task 1: Set Up
   +  Create a new public GitHub repository called github-actions-practice
   +  Clone it locally
   +  Create the folder structure: .github/workflows/

### link of github-actions-practice: 
https://github.com/Aliyas-22/github-actions-practice

---
## Task 2: Hello Workflow

+ Create .github/workflows/hello.yml with a workflow that:

  +  Triggers on every push
  +  Has one job called greet
  +  Runs on ubuntu-latest
  +  Has two steps:
      +  Step 1: Check out the code using actions/checkout
      +  Step 2: Print Hello from GitHub Actions!

+ Push it. Go to the Actions tab on GitHub and watch it run.

  <img width="1920" height="292" alt="Screenshot (278)" src="https://github.com/user-attachments/assets/bf440974-6936-4286-a79d-c7f1cbdc5b90" />
  <img width="1920" height="466" alt="Screenshot (284)" src="https://github.com/user-attachments/assets/e2c52d7a-8ac0-4083-9219-3d1600bb355d" />
  
 + Verify: Is it green? Click into the job and read every step.
   
<img width="1920" height="818" alt="Screenshot (286)" src="https://github.com/user-attachments/assets/2be8e30b-4d20-473e-a503-58413614a3f7" />

---
## Task 3: Understand the Anatomy

+ Look at your workflow file and write in your notes what each key does:

  +  on: Triggered via push
        +  this workflow have been trigred when i ppush the code 
    
  +  jobs: the jobs is greet
         + this jobs greet will run the steps
     
  +  runs-on: Ubuntu 24.04.3
        + runner the vm helps to run the jobs

  +  steps:
        + this wil List of actions commands inside a job
          
  +  uses:
        + Run actions/checkout@v4 with:repository: Aliyas-22/github-actions-practice  

  +  run: Tells GitHub to run a shell command
       + echo "hello from github Action"
    
  +  name: (on a step)
      + name: Print branch name
      +  name in human readable form to make it readable


 ---
 ## Task 4: Add More Steps

### Update hello.yml to also:

  + Print the current date and time
  + Print the name of the branch that triggered the run (hint: GitHub provides this as a variable)
  + List the files in the repo
  + Print the runner's operating system

+ Push again — watch the new run.
  
 <img width="1920" height="906" alt="Screenshot (280)" src="https://github.com/user-attachments/assets/fd483e49-60ef-45c5-a4ba-2a4029457d88" />

 ---

 ## ask 5: Break It On Purpose

+  Add a step that runs a command that will fail (e.g., exit 1 or a misspelled command)
+  Push and observe what happens in the Actions tab
+  Fix it and push again

 + Write in your notes: What does a failed pipeline look like? How do you read the error?
   + the red cross sign in circle came when the pipline fail
   +  inside the Annotations we can see error
   +  or clicking on  break workflow
     
<img width="1920" height="475" alt="Screenshot (282)" src="https://github.com/user-attachments/assets/6ca087c0-b882-474a-9f70-474177ccf5aa" />
 <img width="1920" height="876" alt="Screenshot (285)" src="https://github.com/user-attachments/assets/5c5c85f9-8dc9-47b6-bcc9-b39cfaf3e61e" />

---
