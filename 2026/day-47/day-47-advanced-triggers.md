# Day 47 – Advanced Triggers: PR Events, Cron Schedules & Event-Driven Pipelines
## Task 1: Pull Request Event Types

+ Create .github/workflows/pr-lifecycle.yml that triggers on pull_request with specific activity types:
```
   Trigger on: opened, synchronize, reopened, closed
  Add steps that:
        Print which event type fired: ${{ github.event.action }}
        Print the PR title: ${{ github.event.pull_request.title }}
        Print the PR author: ${{ github.event.pull_request.user.login }}
        Print the source branch and target branch
    Add a conditional step that only runs when the PR is merged (closed + merged = true)

Test it: create a PR, push an update to it, then merge it. Watch the workflow fire each time with a different event type.

```
<img width="1920" height="894" alt="Screenshot (350)" src="https://github.com/user-attachments/assets/12b14dfb-0876-42f9-95ae-a3b08801ea47" />


---

## ask 2: PR Validation Workflow

+ Create .github/workflows/pr-checks.yml — a real-world PR gate:
```
    Trigger on pull_request to main
    Add a job file-size-check that:
        Checks out the code
        Fails if any file in the PR is larger than 1 MB
    Add a job branch-name-check that:
        Reads the branch name from ${{ github.head_ref }}
        Fails if it doesn't follow the pattern feature/*, fix/*, or docs/*
    Add a job pr-body-check that:
        Reads the PR body: ${{ github.event.pull_request.body }}
        Warns (but doesn't fail) if the PR description is empty
```
Verify: Open a PR from a badly named branch — does the check fail?

no its not check badly named branch...

<img width="1920" height="913" alt="Screenshot (352)" src="https://github.com/user-attachments/assets/73196e55-5b39-4ee1-a4be-cc4c1096b560" />
<img width="1920" height="769" alt="Screenshot (353)" src="https://github.com/user-attachments/assets/d3e3eb43-1028-4293-90c6-d13866908653" />

---

## Task 3: Scheduled Workflows (Cron Deep Dive)

Create .github/workflows/scheduled-tasks.yml:
```
    Add a schedule trigger with cron: '30 2 * * 1' (every Monday at 2:30 AM UTC)
    Add another cron entry: '0 */6 * * *' (every 6 hours)
    In the job, print which schedule triggered using ${{ github.event.schedule }}
    Add a step that acts as a health check — curl a URL and check the response code
    Important: Also add workflow_dispatch so you can test it manually without waiting for the schedule.
```
Write in your notes:

  + The cron expression for: every weekday at 9 AM IST
     + 30 3 * * 1-5
     
  + The cron expression for: first day of every month at midnight

    + 0 0 1 * *
    
  +  Why GitHub says scheduled workflows may be delayed or skipped on inactive repos
   +  GitHub warns about this because:
+  Shared runners are limited
+  If many workflows run simultaneously, ours may queue


<img width="1920" height="845" alt="Screenshot (354)" src="https://github.com/user-attachments/assets/018e1842-8ac0-4d34-b36e-eb1dad6ccfd8" />

---

## Task 4: Path & Branch Filters
Create `.github/workflows/smart-triggers.yml`:
1. Trigger on push but **only** when files in `src/` or `app/` change:
   ```yaml
   on:
     push:
       paths:
         - 'src/**'
         - 'app/**'
   ```
2. Add `paths-ignore` in a second workflow that skips runs when only docs change:
   ```yaml
   paths-ignore:
     - '*.md'
     - 'docs/**'
   ```
3. Add branch filters to only trigger on `main` and `release/*` branches
4. Test it: push a change to a `.md` file — does the workflow skip?

Write in your notes: When would you use `paths` vs `paths-ignore`?
+ paths:-
   + Use paths when we want the workflow to run only for specific files or directories.
+ paths-ignore:-
   + Use paths-ignore when we want the workflow to run for everything except certain files.   

<img width="1920" height="895" alt="Screenshot (356)" src="https://github.com/user-attachments/assets/679cd2e1-13c0-4799-90af-79824fc2e3d9" />
<img width="1920" height="718" alt="Screenshot (357)" src="https://github.com/user-attachments/assets/8053a487-37e7-4227-ade3-492dd04e2679" />

---


 ## Task 5: `workflow_run` — Chain Workflows Together
Create two workflows:
1. `.github/workflows/tests.yml` — runs tests on every push
2. `.github/workflows/deploy-after-tests.yml` — triggers **only after** `tests.yml` completes successfully:
   ```yaml
   on:
     workflow_run:
       workflows: ["Run Tests"]
       types: [completed]
   ```
3. In the deploy workflow, add a conditional:
   - Only proceed if the triggering workflow **succeeded** (`${{ github.event.workflow_run.conclusion == 'success' }}`)
   - Print a warning and exit if it failed

**Verify:** Push a commit — does the test workflow run first, then trigger the deploy workflow?



<img width="1920" height="855" alt="Screenshot (358)" src="https://github.com/user-attachments/assets/4bb6b9ad-b9fd-4798-8968-7c10ff76b6a8" />
<img width="1920" height="729" alt="Screenshot (359)" src="https://github.com/user-attachments/assets/78f3e423-debf-4374-af53-d9ae66681bec" />

---

## Task 6: `repository_dispatch` — External Event Triggers
1. Create `.github/workflows/external-trigger.yml` with trigger `repository_dispatch`
2. Set it to respond to event type: `deploy-request`
3. Print the client payload: `${{ github.event.client_payload.environment }}`
4. Trigger it using `curl` or `gh`:
   ```bash
   gh api repos/<owner>/<repo>/dispatches \
     -f event_type=deploy-request \
     -f client_payload='{"environment":"production"}'
   ```

Write in your notes: When would an external system (like a Slack bot or monitoring tool) trigger a pipeline?
   + External systems trigger pipelines when automation needs to start CI/CD from outside GitHub.
   + A Slack command can trigger deployment by this  /deploy production CI systems integration
Another system might build code and then trigger GitHub deployment.

<img width="1920" height="732" alt="Screenshot (360)" src="https://github.com/user-attachments/assets/cf737ccd-1f11-4d11-81d8-5abeacf1cfe5" />

---
