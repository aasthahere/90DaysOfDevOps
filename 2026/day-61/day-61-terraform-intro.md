# Day 61 -- Introduction to Terraform and Your First AWS Infrastructure

### Task 1: Understand Infrastructure as Code
Before touching the terminal, research and write short notes on:

1. What is Infrastructure as Code (IaC)? Why does it matter in DevOps?
   - Instead of manually clicking and setting up resources on AWS,
   - we write a configuration file and with one command everything gets created automatically —
   - saving time, avoiding mistakes, and making it repeatable.
  
   - In DevOps, without using IaC,
   - we have to do steps manually and
   - the chances of human error increase.
   - If it fails or crashes, there is no record of what was done,
   - and it is hard to scale. All these problems are solved by using IaC."

---

  
2. What problems does IaC solve compared to manually creating resources in the AWS console?
   
    - Infrastructure as Code solves the problems that come with doing things manually.
    - Instead of clicking 50 settings manually — which is hard to repeat and hard to scale
    - IaC allows us to write everything in one file and run a single command.
    - This replaces 50 manual clicks with one command.
    - It is also very beneficial because everything is recorded
    - we have logs and a full history of what was done.
  
---
   
5. How is Terraform different from AWS CloudFormation, Ansible, and Pulumi?

    - AWS cloudformation : is work as similar as terraform but it is only used inside the aws server
      
    - ansible: Terraform builds the server Ansible goes inside and configures it
  
    - pulumi: Pulumi is newer and uses normal coding languages such as js,python this is best for developer

---
   
7. What does it mean that Terraform is "declarative" and "cloud-agnostic"?

   - terraform is declarative : meaning I just write what infrastructure I want and Terraform figures out how to create it.
   - It is also cloud-agnostic : meaning the same Terraform code can work on AWS, Azure, or GCP without rewriting everything."
Write this in your own words -- not copy-pasted definitions.

---

### Task 2: Install Terraform and Configure AWS
1. Install Terraform:
```bash
# macOS
brew tap hashicorp/tap
brew install hashicorp/tap/terraform

# Linux (amd64)
wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform

# Windows
choco install terraform
```

2. Verify:
```bash
terraform -version
```
<img width="1920" height="325" alt="Screenshot (572)" src="https://github.com/user-attachments/assets/58f1c62e-f1bd-41aa-95a9-168a988c0b2c" />

---

3. Install and configure the AWS CLI:
   ```
   ssh keygen
   copy the key
   ```

```
$ curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
aws configure
# Enter your Access Key ID, Secret Access Key, default region (e.g., ap-south-1), output format (json)
```

4. Verify AWS access:
```bash
aws sts get-caller-identity
```

You should see your AWS account ID and ARN.
 + yes i an see the account id and arn
   
---


### Task 3: Your First Terraform Config -- Create an S3 Bucket
Create a project directory and write your first Terraform config:

```bash
mkdir terraform-basics && cd terraform-basics
```

Create a file called `main.tf` with:
1. A `terraform` block with `required_providers` specifying the `aws` provider
2. A `provider "aws"` block with your region
3. A `resource "aws_s3_bucket"` that creates a bucket with a globally unique name

```hcl
provider "aws" {
      region = "us-west-2"

}

resource aws_s3_bucket my_bucket {
         bucket = "doremon-ki-bucket"
}
```

Run the Terraform lifecycle:
```bash
terraform init      # Download the AWS provider
terraform plan      # Preview what will be created
terraform apply     # Create the bucket (type 'yes' to confirm)
```

Go to the AWS S3 console and verify your bucket exists.

<img width="1920" height="985" alt="Screenshot (578)" src="https://github.com/user-attachments/assets/f129bffd-20c8-40eb-8199-9ec24d063ff0" />

**Document:** What did `terraform init` download? What does the `.terraform/` directory contain?
    - terraform init is as similar as the git init this will initialize the file 
    - .terraform/ : terrraform create it by own when we run the terraform init 
    - this directory stores working files and depnedencies to run file 
 ---
### Task 4: Add an EC2 Instance
In the same `main.tf`, add:
1. A `resource "aws_instance"` using AMI `ami-0f5ee92e2d63afc18` (Amazon Linux 2 in ap-south-1 -- use the correct AMI for your region)
2. Set instance type to `t2.micro`
3. Add a tag: `Name = "TerraWeek-Day1"`

   ```hcl
   
# create ec2 instance

 resource aws_instance my_instance {

 ami = "ami-080254318c2d8932f"
 instance_type = "t2.micro"

    tags = {
  Name = "TerraWeek-Day1"
  }
}
```

Run:
```bash
terraform plan      # You should see 1 resource to add (bucket already exists)
terraform apply
```

Go to the AWS EC2 console and verify your instance is running with the correct name tag.

<img width="1920" height="500" alt="Screenshot (587)" src="https://github.com/user-attachments/assets/c14cce11-862b-4e8e-9e19-0a13b37f4825" />


**Document:** How does Terraform know the S3 bucket already exists and only the EC2 instance needs to be created?
      - terraform knows what aready exists using the state file 
      - statefile track the changes which is created previously 
      - it compared to desired state with current state if somthing matches or inside the state file it only create the current state

  ---

  ### Task 5: Understand the State File
Terraform tracks everything it creates in a state file. Time to inspect it.

1. Open `terraform.tfstate` in your editor -- read the JSON structure
2. Run these commands and document what each returns:
```bash
terraform show                          # Human-readable view of current state
terraform state list                    # List all resources Terraform manages
terraform state show aws_s3_bucket.<name>   # Detailed view of a specific resource
terraform state show aws_instance.<name>
```

3. Answer these questions in your notes:
   - What information does the state file store about each resource?
       + terraform statefile sotres complete inforamtion about each resource
       + uniques id
       + ami id
       + tags
       + networking
       + provider details
         
     ---    
   - Why should you never manually edit the state file?
       + becuase it is source of truth for terraform any incorrect changes can break the mapping between the configuaration

     ---
     
   - Why should the state file not be committed to Git?
       + state file not be committed to Git becuase its cantain sensitive information accesses keys and passwords and details
         
---

### Task 6: Modify, Plan, and Destroy
1. Change the EC2 instance tag from `"TerraWeek-Day1"` to `"TerraWeek-Modified"` in your `main.tf`
2. Run `terraform plan` and read the output carefully:
   - What do the `~`, `+`, and `-` symbols mean?
   - Is this an in-place update or a destroy-and-recreate?
3. Apply the change
4. Verify the tag changed in the AWS console
   
<img width="1920" height="511" alt="Screenshot (590)" src="https://github.com/user-attachments/assets/17a76d52-419b-4dee-963a-3abbdd4ce717" />

   
6. Finally, destroy everything:
```bash
terraform destroy
```
6. Verify in the AWS console -- both the S3 bucket and EC2 instance should be gone
<img width="1920" height="631" alt="Screenshot (591)" src="https://github.com/user-attachments/assets/b6231b41-1a1f-4f35-ab00-9dc027234e58" />
<img width="1920" height="930" alt="Screenshot (592)" src="https://github.com/user-attachments/assets/d169c907-0305-49ff-b58b-32f4bfff6345" />

---

## Documentation

- IaC explanation in your own words (3-4 sentences)
   +  suppose i want to create one instance i can create easily but when it comes to creating 20 or 30 instance
   +  it will take time and definatly human error chances so for that IaC is usefull
   +  With IaC i only need to create one file and with just one command ```terraform apply```
   +  everything became easy
   +  so basically instead of clicking
 
---

- What each Terraform command does (init, plan, apply, destroy, show, state list)
    + terraform plan-
        + create the execution plan by comparing the state code with current state and it shows what changes will be made
          (this will preview only not apply changes)
---
   + terraform init-
         + terraform init initializes a Terraform working directory by downloading required providers,
         + setting up the backend, and preparing the environment to run Terraform commands.
---
   + terraform destroy-
         + delete all the resource managed by terraform in current configuaration (completely)
---
   + terraform apply-
        + executes the changes matches to desire state means it accually modifies infrastructure
---
   + terraform show-
        + Displays the current state or a saved plan in a human-readable format
---
   + terraform state list-
       + Lists all resources currently tracked in the Terraform state file.       
    
---  
- What the state file contains and why it matters
    + the Terraform state file contains the current state of infrastructure, including resource IDs,
    + attributes, metadata, and dependencies. It acts as a source of truth that Terraform uses to compare the desired configuration with
    + the actual infrastructure, allowing it to plan and apply only the necessary changes

---

---
