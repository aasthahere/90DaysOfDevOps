# Day 46 – Reusable Workflows & Composite Actions
## Task 1: Understand workflow_call
+ Before writing any code, research and answer in your notes:
 ---
+ What is a reusable workflow?
   + A reusable workflow is a workflow that is written once and can be called by other workflows,
   +  so we don’t need to repeat the same steps again and again.
 
---
---
+ What is the workflow_call trigger?
   + workflow_call is a trigger that allows a workflow to be called and reused by another workflow.
   +  ./.github/workflows/docker-build.yml
---
---
+ How is calling a reusable workflow different from using a regular action (uses:)?
   + A reusable workflow is a full workflow with jobs that can be called by other workflows
   + while a regular action (uses:) is a single reusable step used inside a job.
---
---
+ Where must a reusable workflow file live?
   + A reusable workflow must be stored inside the
   + .github/workflows/ directory so GitHub Actions can detect and call it.
---

## Task 2: Create Your First Reusable Workflow
 + Create .github/workflows/reusable-build.yml:
```
 Set the trigger to workflow_call
 Add an inputs: section with:
 app_name (string, required)
environment (string, required, default: staging)
Add a secrets: section with:
docker_token (required)
Create a job that:
Checks out the code
Prints Building <app_name> for <environment>
Prints Docker token is set: true (never print the actual secret)
Verify: This file alone won't run — it needs a caller. That's next.
```

