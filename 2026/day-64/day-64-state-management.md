# Day 64 -- Terraform State Management and Remote Backends

### Task 1: Inspect Your Current State
Use your Day 63 config (or create a small config with a VPC and EC2 instance). Apply it and then explore the state:

```bash
terraform show                                    # Full state in human-readable format
terraform state list                              # All resources tracked by Terraform
terraform state show aws_instance.<name>          # Every attribute of the instance
terraform state show aws_vpc.<name>               # Every attribute of the VPC
```

Answer:
1. How many resources does Terraform track?
   - there is 10 resources terraform are tracking...
---

3. What attributes does the state store for an EC2 instance? (hint: way more than what you defined)
     - Terraform state stores many attributes beyond what is defined in the configuration,
     - including instance ID,
     - public and private IPs,
     - AMI ID, instance state,
     - subnet ID,
     - security groups,
     - availability zone,
     - tags,
     - and other computed metadata.

---

5. Open `terraform.tfstate` in an editor -- find the `serial` number. What does it represent?
     - The serial number represents the version of the state file.
     - It increments every time Terraform makes a change, helping track updates and maintain consistency.
   
<img width="1505" height="309" alt="Screenshot (643)" src="https://github.com/user-attachments/assets/57bac3c9-73a4-4e64-90fb-fe772902bc8f" />

---

### Task 2: Set Up S3 Remote Backend
Storing state locally is dangerous -- one deleted file and you lose everything. Time to move it to S3.

1. First, create the backend infrastructure (do this manually or in a separate Terraform config):
```bash
# Create S3 bucket for state storage
aws s3api create-bucket \
  --bucket terraweek-state-<yourname> \
  --region ap-south-1 \
  --create-bucket-configuration LocationConstraint=ap-south-1

# Enable versioning (so you can recover previous state)
aws s3api put-bucket-versioning \
  --bucket terraweek-state-<yourname> \
  --versioning-configuration Status=Enabled

# Create DynamoDB table for state locking
aws dynamodb create-table \
  --table-name terraweek-state-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region ap-south-1
```

<img width="1920" height="248" alt="Screenshot (644)" src="https://github.com/user-attachments/assets/2fea992f-d5cd-4184-91f5-02be1e1230e3" />
<img width="1920" height="937" alt="Screenshot (645)" src="https://github.com/user-attachments/assets/df99aa75-728f-4d57-ad4c-32f5f632050f" />

2. Add the backend block to your Terraform config:
```hcl
terraform {
  backend "s3" {
    bucket         = "terraweek-state-<yourname>"
    key            = "dev/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "terraweek-state-lock"
    encrypt        = true
  }
}
```

3. Run:
```bash
terraform init
```
Terraform will ask: "Do you want to copy existing state to the new backend?" -- say yes.

4. Verify:
   - Check the S3 bucket -- you should see `dev/terraform.tfstate`
   - Your local `terraform.tfstate` should now be empty or gone
   - Run `terraform plan` -- it should show no changes (state migrated correctly)
<img width="1920" height="981" alt="Screenshot (649)" src="https://github.com/user-attachments/assets/dc8e14f9-e277-4554-ae4a-394d612b0548" />
<img width="1920" height="998" alt="Screenshot (647)" src="https://github.com/user-attachments/assets/f731aaf4-8668-4d7d-8396-cce1c611ea0b" />

---

### Task 3: Test State Locking
State locking prevents two people from running `terraform apply` at the same time and corrupting the state.

1. Open **two terminals** in the same project directory
2. In Terminal 1, run:
```bash
terraform apply
```
3. While Terminal 1 is waiting for confirmation, in Terminal 2 run:
```bash
terraform plan
```
4. Terminal 2 should show a **lock error** with a Lock ID

**Document:** What is the error message? Why is locking critical for team environments?
   - Terraform throws an error: “Error acquiring the state lock” with a Lock ID when another operation is already using the state.
   - State locking prevents multiple users from modifying infrastructure at the same time. Without locking,
   - concurrent changes can corrupt the state file and lead to inconsistent or broken infrastructure.

5. After the test, if you get stuck with a stale lock:
```bash
terraform force-unlock <LOCK_ID>
```
<img width="1920" height="1025" alt="Screenshot (650)" src="https://github.com/user-attachments/assets/faeb3a68-1804-4ceb-b7bd-6df75fd22f92" />

---

### Task 4: Import an Existing Resource
Not everything starts with Terraform. Sometimes resources already exist in AWS and you need to bring them under Terraform management.

1. Manually create an S3 bucket in the AWS console -- name it `terraweek-import-test-<yourname>`
2. Write a `resource "aws_s3_bucket"` block in your config for this bucket (just the bucket name, nothing else)
3. Import it:
```bash
terraform import aws_s3_bucket.imported terraweek-import-test-<yourname>
```
4. Run `terraform plan`:
   - If you see "No changes" -- the import was perfect
   - If you see changes -- your config does not match reality. Update your config to match, then plan again until you get "No changes"

5. Run `terraform state list` -- the imported bucket should now appear alongside your other resources

**Document:** What is the difference between `terraform import` and creating a resource from scratch?
     - Terraform import is used to bring existing infrastructure under Terraform management without creating new resources.
     - It only updates the state file.
     - Creating a resource from scratch provisions new infrastructure based on the configuration.
     <img width="1920" height="881" alt="Screenshot (652)" src="https://github.com/user-attachments/assets/1d194a56-c02d-414b-bf0e-4882ce3f67da" />
<img width="1671" height="613" alt="Screenshot (654)" src="https://github.com/user-attachments/assets/870b9f0a-9c68-449a-8f28-6d769070cfdd" />

---
### Task 5: State Surgery -- mv and rm
Sometimes you need to rename a resource or remove it from state without destroying it in AWS.

1. **Rename a resource in state:**
```bash
terraform state list                              # Note the current resource names
terraform state mv aws_s3_bucket.imported aws_s3_bucket.logs_bucket
```
Update your `.tf` file to match the new name. Run `terraform plan` -- it should show no changes.

2. **Remove a resource from state (without destroying it):**
```bash
terraform state rm aws_s3_bucket.logs_bucket
```
Run `terraform plan` -- Terraform no longer knows about the bucket, but it still exists in AWS.

3. **Re-import it** to bring it back:
```bash
terraform import aws_s3_bucket.logs_bucket terraweek-import-test-<yourname>
```

**Document:** When would you use `state mv` in a real project? When would you use `state rm`?
  - terraform state mv is used when renaming or reorganizing resources in Terraform configuration without recreating them.
  -  It helps maintain the same infrastructure while updating its reference in the state.
---
 - terraform state rm is used to remove a resource from Terraform state without deleting it in AWS.
 - This is useful when you want Terraform to stop managing a resource but keep it running.

    <img width="1713" height="628" alt="Screenshot (655)" src="https://github.com/user-attachments/assets/51c0aeaf-05d2-4c7b-b1c0-192eaad088ba" />
    <img width="1920" height="634" alt="Screenshot (657)" src="https://github.com/user-attachments/assets/33e62623-8305-49fb-9ad8-46fdde9bfa15" />

---

### Task 6: Simulate and Fix State Drift
State drift happens when someone changes infrastructure outside of Terraform -- through the AWS console, CLI, or another tool.

1. Apply your full config so everything is in sync
2. Go to the **AWS console** and manually:
   - Change the Name tag of your EC2 instance to `"ManuallyChanged"`
   - Change the instance type if it's stopped (or add a new tag)
3. Run:
```bash
terraform plan
```
You should see a **diff** -- Terraform detects that reality no longer matches the desired state.

4. You have two choices:
   - **Option A:** Run `terraform apply` to force reality back to match your config (reconcile)
   - **Option B:** Update your `.tf` files to match the manual change (accept the drift)

5. Choose Option A -- apply and verify the tags are restored.

6. Run `terraform plan` again -- it should show "No changes." Drift resolved.

**Document:** How do teams prevent state drift in production? (hint: restrict console access, use CI/CD for all changes)
   - Teams prevent state drift by restricting direct access to cloud consoles and ensuring all infrastructure changes are made through Terraform.
   - They use CI/CD pipelines to enforce Infrastructure as Code practices and avoid manual modifications.
   -
  
<img width="1920" height="535" alt="Screenshot (659)" src="https://github.com/user-attachments/assets/2c31e4b0-21c4-4bd8-950b-2b8e808a43b5" />
<img width="1920" height="998" alt="Screenshot (661)" src="https://github.com/user-attachments/assets/9176252c-8280-4e9c-9d55-dc2569a346c2" />

<img width="1920" height="654" alt="Screenshot (658)" src="https://github.com/user-attachments/assets/398f93cb-edb1-4414-8dd8-d55d408bac1a" />
<img width="1920" height="458" alt="Screenshot (662)" src="https://github.com/user-attachments/assets/1b86b851-7249-436b-8b93-1ebf7184b2e8" />

---
## Documentation
Create `day-64-state-management.md` with:

- Diagram: local state vs remote state set

LOCAL STATE
-----------
  Laptop
   ->
terraform.tfstate (stored locally)


REMOTE STATE
------------
 Laptop
   ->
Terraform
   ->
S3 Bucket (stores state)
   ->
DynamoDB (handles locking)


- Explanation of state drift with your real example

  ##  State Drift (Real Example)

State drift happens when the actual infrastructure in AWS is changed manually and no longer matches the Terraform configuration.

###  My Real Example

- I created an EC2 instance using Terraform.
- In my Terraform code, the tag was:


### What I did manually

- I went to the AWS Console.
- Changed the tag to:

Now the Terraform configuration and actual infrastructure were different. This is called **state drift**.

###  How Terraform detected it

I ran:

```bash
terraform plan
```
- When to use: `state mv`, `state rm`, `import`, `force-unlock`, `refresh`
##  When to Use Terraform State Commands

###  `terraform state mv`
Used when you want to rename or move a resource in Terraform without recreating it.

**When to use:**
- Renaming a resource (e.g., `imported` → `logs_bucket`)
- Moving resources between modules
- Refactoring Terraform code

**Key point:**  
Infrastructure stays the same, only the state reference changes.

---

###  `terraform state rm`
Used to remove a resource from Terraform state without deleting it in AWS.

**When to use:**
- Stop managing a resource with Terraform
- Resource should exist but outside Terraform control
- Fixing broken or incorrect state

** Note:**  
Terraform may try to recreate the resource in the next `plan`.

---

###  `terraform import`
Used to bring an existing AWS resource under Terraform management.

**When to use:**
- Infrastructure already exists (created manually or by another tool)
- You want Terraform to start managing it

**Key point:**  
It does NOT create the resource, only adds it to the state.

---

###  `terraform force-unlock`
Used to manually release a stuck state lock.

**When to use:**
- Terraform process crashed
- Network issue interrupted execution
- Lock is not released automatically

**Use carefully:**  
Only use when you are sure no other operation is running.

---

###  `terraform refresh`
Used to update Terraform state with the real infrastructure state.

**When to use:**
- Sync state with actual AWS resources
- Detect manual changes (state drift)
- Before running plan in uncertain situations

**Key point:**  
It does not change infrastructure, only updates the state file.

---






