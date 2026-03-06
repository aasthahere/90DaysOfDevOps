# Day 41 – Triggers & Matrix Builds
## Task 1: Trigger on Pull Request

+ Create .github/workflows/pr-check.yml
+ Trigger it only when a pull request is opened or updated against main
   ```YML
     types: [opened, synchronize]
   ```
+ Add a step that prints: PR check running for branch: <branch name>
```YML
- name: check PR running branch
  run: echo " PR running branch is: ${{ github.head_ref }}" 
```
 
+ Create a new branch, push a commit, and open a PR
   + git checkout -b feature
   + created pull request
     
+ Watch the workflow run automatically
   + yes the pull request automatically run
     
+ Verify: Does it show up on the PR page?
   + Yes, after creating a Pull Request
   + it appears on the Pull Requests page

<img width="1920" height="802" alt="Screenshot (287)" src="https://github.com/user-attachments/assets/6855a583-3797-48dd-a077-02ddab32bf38" />

 
---
## Task 2: Scheduled Trigger
+ Add a schedule: trigger to any workflow using cron syntax
  ```YML
     schedule:
        - cron: 
     ```
+ Set it to run every day at midnight UTC
   ```
   "0 0 * * *"
   ```
+ Write in your notes: What is the cron expression for every Monday at 9 AM?
   ```
  0 9 * * 1
   ```

  <img width="1920" height="918" alt="Screenshot (296)" src="https://github.com/user-attachments/assets/09bc0d07-5c66-476d-913c-c29ce0127d99" />


---

## Task 3: Manual Trigger
+ Create .github/workflows/manual.yml with a workflow_dispatch: trigger
+ Add an input that asks for an environment name (staging/production)
   ```YML
   inputs:
            environment: # Input name
                description: "Select the environment" # Description for the input
                required: true # Make it required
                default: "staging" # Default value
   ```
+ Print the input value in a step
```YML
- name: print the selected environment
              run: |
                  echo "Selected environment: ${{ github.event.inputs.environment }}" # github variable to get the input value
```
    
+ Go to the Actions tab → find the workflow → click Run workflow
+ Verify: Can you trigger it manually and see your input printed?
   + yes the input is printed


<img width="1920" height="782" alt="Screenshot (289)" src="https://github.com/user-attachments/assets/60ff3e82-4b2d-4309-b816-c54dc6650df0" />


---

## Task 4: Matrix Builds
+ Create .github/workflows/matrix.yml that:

+ Uses a matrix strategy to run the same job across:
  + Python versions: 3.10, 3.11, 3.12
```YML
    strategy:
            matrix:
                python-version: [3.10, 3.11, 3.12] # Define the matrix with different Python versions
```

+ Each job installs Python and prints the version
   ```YML
   - name: print python version from matrix
              run: |
                  echo "Testing with Python current version: ${{ matrix.python-version }}" # Print the current Python version from the matrix
  ```
+ Watch all 3 run in parallel


<img width="1920" height="893" alt="Screenshot (290)" src="https://github.com/user-attachments/assets/7c4f6352-2e6c-4f4e-b576-4b0fd8eded8f" />

---

## Task 5: Exclude & Fail-Fast
+ In your matrix, exclude one specific combination (e.g., Python 3.10 on Windows)
    ```YML
    exclude:
                    - os: windows-latest
                      python-version: 3.10 
    ```
+ Set fail-fast: false — trigger a failure in one job and observe what happens to the rest
   + When one matrix job fails and fail-fast is set to false, the remaining matrix jobs continue running instead of being cancelled.
  ```YML
   name: Force failure for one job
              if: matrix.os == 'ubuntu-latest' && matrix.python-version == '3.10'
              run: exit 1
  ```
  + added this if condition to check whather the fail-fast: false work or not 
+ Write in your notes: What does fail-fast: true (the default) do vs false?
    + fail-fast: true (default)
        + If one job in the matrix fails, all the remaining running or pending jobs are cancelled immediately.

    + fail-fast: false
        + If one job in the matrix fails, the other jobs continue running and are not cancelled.

<img width="1920" height="862" alt="Screenshot (294)" src="https://github.com/user-attachments/assets/e7de0d65-5bbd-45c6-ab9d-f85ec87c9f27" />


   
