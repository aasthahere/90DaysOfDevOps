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
---

## Task 3: Create a Caller Workflow
Create `.github/workflows/call-build.yml`:
1. Trigger on push to `main`
2. Add a job that uses your reusable workflow:
   ```yaml
   jobs:
     build:
       uses: ./.github/workflows/reusable-build.yml
       with:
         app_name: "my-web-app"
         environment: "production"
       secrets:
         docker_token: ${{ secrets.DOCKER_TOKEN }}
   ```
3. Push to `main` and watch it run

**Verify:** In the Actions tab, do you see the caller triggering the reusable workflow? Click into the job — can you see the inputs printed?
 yes the caller workflow triggering the reusable workflow yes i see the output is printed
 <img width="1920" height="891" alt="Screenshot (344)" src="https://github.com/user-attachments/assets/24712d00-6597-4d15-b6a9-ad072f1c1f80" />

---

## Task 4: Add Outputs to the Reusable Workflow
Extend `reusable-build.yml`:
1. Add an `outputs:` section that exposes a `build_version` value
2. Inside the job, generate a version string (e.g., `v1.0-<short-sha>`) and set it as output
3. In your caller workflow, add a second job that:
   - Depends on the build job (`needs:`)
   - Reads and prints the `build_version` output

**Verify:** Does the second job print the version from the reusable workflow?
     yes it print the reusable workflow

   <img width="1920" height="700" alt="Screenshot (346)" src="https://github.com/user-attachments/assets/c12246ab-8d93-4800-8970-31439933061a" />

---

---
## Task 5: Create a Composite Action
Create a **custom composite action** in your repo at `.github/actions/setup-and-greet/action.yml`:
1. Define inputs: `name` and `language` (default: `en`)
2. Add steps that:
   - Print a greeting in the specified language
   - Print the current date and runner OS
   - Set an output called `greeted` with value `true`
3. Use the composite action in a new workflow with `uses: ./.github/actions/setup-and-greet`

**Verify:** Does your custom action run and print the greeting?
yes it print the greeting
<img width="1920" height="859" alt="Screenshot (348)" src="https://github.com/user-attachments/assets/608c8064-2163-4b79-9fc6-ec866804a029" />
---

## Task 6: Reusable Workflow vs Composite Action
Fill this in your notes:

| | Reusable Workflow | Composite Action |
|---|---|---|
| Triggered by | `workflow_call` | `uses:` in a step |
| Can contain jobs? | yes | no |
| Can contain multiple steps? | yes | yes |
| Lives where? | .github/workflows | .github/actions/setup-greet |
| Can accept secrets directly? | yes | no |
| Best for | A workflow that other workflows can call and reuse to avoid repeating CI/CD logic. | Reusable group of steps used as a single step in workflows |

---

