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
