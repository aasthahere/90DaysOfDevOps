# Day 43 – Jobs, Steps, Env Vars & Conditionals
## Task 1: Multi-Job Workflow
+ Create .github/workflows/multi-job.yml with 3 jobs:

+ build — prints "Building the app"
+ test — prints "Running tests"
+ deploy — prints "Deploying"
+ Make test run only after build succeeds. Make deploy run only after test succeeds.

+ Verify: Check the workflow graph in the Actions tab — does it show the dependency chain?
   ``` yes it shows dependency chain ```

<img width="1920" height="672" alt="Screenshot (311)" src="https://github.com/user-attachments/assets/3b3f23d3-563a-45b4-9a23-9fabf3ae3f6b" />


---
## Task 2: Environment Variables
+ In a new workflow, use environment variables at 3 levels:

+ Workflow level — APP_NAME: myapp
+ Job level — ENVIRONMENT: staging
+ Step level — VERSION: 1.0.0
+ Print all three in a single step and verify each is accessible.

+ Then use a GitHub context variable — print the commit SHA and the actor (who triggered the run).


<img width="1920" height="855" alt="Screenshot (312)" src="https://github.com/user-attachments/assets/b8b76a8e-d33a-4061-bce3-010eef9145d5" />

---
## Task 3: Job Outputs
+ Create a job that sets an output — e.g., today's date as a string
+ Create a second job that reads that output and prints it
+ Pass the value using outputs: and needs.<job>.outputs.<name>
+ Write in your notes: Why would you pass outputs between jobs?
  + Each job in GitHub Actions runs on a separate machine. So if Job 1 creates something important 
  + like a version number or a build result — Job 2 cannot see it automatically.
  + We pass outputs so Job 2 can use Job 1's result without doing the same work again!

<img width="1920" height="673" alt="Screenshot (313)" src="https://github.com/user-attachments/assets/9bbe8004-ce75-4e5f-9805-0d1766db8d3b" />

---

## Task 4: Conditionals
+ In a workflow, add:

+ A step that only runs when the branch is main
+ A step that only runs when the previous step failed
+ A job that only runs on push events, not on pull requests
+ A step with continue-on-error: true — what does this do?
  + Even if this step fails 
  + don't stop
  + Keep running the next steps

<img width="1920" height="867" alt="Screenshot (314)" src="https://github.com/user-attachments/assets/e7567156-5289-4780-883d-abfd8732cc68" />
<img width="1920" height="870" alt="Screenshot (315)" src="https://github.com/user-attachments/assets/79af607a-7eac-4acc-b3d7-8dcaaee87268" />


---

## Task 5: Putting It Together
+ Create .github/workflows/smart-pipeline.yml that:

+ Triggers on push to any branch
+ Has a lint job and a test job running in parallel
+ Has a summary job that runs after both, prints whether it's a main branch push or a feature branch push, and prints the commit message


<img width="1920" height="800" alt="Screenshot (316)" src="https://github.com/user-attachments/assets/584e3c10-770a-42ca-81b5-e45d4762bfc6" />
<img width="1920" height="841" alt="Screenshot (317)" src="https://github.com/user-attachments/assets/47c629b2-a96d-4435-b55b-0f0f2d1d024a" />

---



