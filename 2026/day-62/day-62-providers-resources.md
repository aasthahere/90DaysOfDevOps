# Day 62 -- Providers, Resources and Dependencies

### Task 1: Explore the AWS Provider
1. Create a new project directory: `terraform-aws-infra`

   ```mkdir terraform-aws-infra```

   
2. Write a `providers.tf` file:
   - Define the `terraform` block with `required_providers` pinning the AWS provider to version `~> 5.0`
   - Define the `provider "aws"` block with your region
  
     ```vim provider.tf```
 ```hcl
     terraform{
    required_providers{
        aws = {
        source = "hashicorp/aws"
        version = "~> 5.0"
        }
    }
}
provider "aws" {
      region = "us-west-2"

}
```


3. Run `terraform init` and check the output -- what version was installed?
    
5. Read the provider lock file `.terraform.lock.hcl` -- what does it do?

**Document:** What does `~> 5.0` mean? How is it different from `>= 5.0` and `= 5.0.0`?
  - ~> 5.0` 
        + Allow versions starting from 5.0
        + But restrict to the same major version

 - >= 5.0`
       + Any version greater than or equal to 5.0
       + No upper limit

- = 5.0.0
      + Only exactly this version

  ---

  
   <img width="1920" height="514" alt="Screenshot (596)" src="https://github.com/user-attachments/assets/7fb53902-3195-432c-a94c-25db03d2050e" />

---

### Task 2: Build a VPC from Scratch
Create a `main.tf` and define these resources one by one:

1. `aws_vpc` -- CIDR block `10.0.0.0/16`, tag it `"TerraWeek-VPC"`
2. `aws_subnet` -- CIDR block `10.0.1.0/24`, reference the VPC ID from step 1, enable public IP on launch, tag it `"TerraWeek-Public-Subnet"`
3. `aws_internet_gateway` -- attach it to the VPC
4. `aws_route_table` -- create it in the VPC, add a route for `0.0.0.0/0` pointing to the internet gateway
5. `aws_route_table_association` -- associate the route table with the subnet

Run `terraform plan` -- you should see 5 resources to create.

**Verify:** Apply and check the AWS VPC console. Can you see all five resources connected?
   ```hcl
    resource "aws_vpc" "vpc_main" {
  cidr_block       = "10.0.0.0/16"
  
  tags = {
    Name = "TerraWeek-VPC"
  }
}

# terraform aws subnet creating

resource "aws_subnet" "subnet_main" {
  vpc_id     = aws_vpc.vpc_main.id
  cidr_block = "10.0.1.0/24"


  tags = {
    Name = "TerraWeek-Public-Subnet"
  }
}

# terraform creating aws_internet_gateway and connecting with vpc
resource "aws_internet_gateway" "internet_gateway_main" {
  vpc_id = aws_vpc.vpc_main.id

  tags = {
    Name = "TerraWeek-Internet-Gateway"
  }
}

# connecting route table with to vpc
resource "aws_route_table" "public_route_main" {
    vpc_id = aws_vpc.vpc_main.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.internet_gateway_main.id
    }
    tags = {
        Name = "TerraWeek-Public-Route-Table"
    }
  
}

# route_table_association creating 
resource "aws_route_table_association" "public_route_association_main" {
    subnet_id = aws_subnet.subnet_main.id
    route_table_id = aws_route_table.public_route_main.id
}
```
<img width="1920" height="945" alt="Screenshot (599)" src="https://github.com/user-attachments/assets/e95910b8-1bab-4223-8f6a-79196f274e6d" />


### Task 3: Understand Implicit Dependencies
Look at your `main.tf` carefully:

1. The subnet references `aws_vpc.main.id` -- this is an implicit dependency
2. The internet gateway references the VPC ID -- another implicit dependency
3. The route table association references both the route table and the subnet

Answer these questions:
- How does Terraform know to create the VPC before the subnet?
    + Terraform builds a dependency graph (DAG) internally.
    + It detects dependencies using references inside your code.
  
- What would happen if you tried to create the subnet before the VPC existed?
    + terraform apply will fail
    + Infrastructure is incomplete That’s why Terraform Builds dependency graph first Executes in correct order automatically
      
- Find all implicit dependencies in your config and list them
   + Any time one resource references another= implicit dependency..

## 🔗 Implicit Dependencies in Terraform Configuration

| Resource | Depends On | Reason (Reference Used) |
|---------|-----------|--------------------------|
| aws_subnet.subnet_main | aws_vpc.vpc_main | `vpc_id = aws_vpc.vpc_main.id` |
| aws_internet_gateway.internet_gateway_main | aws_vpc.vpc_main | `vpc_id = aws_vpc.vpc_main.id` |
| aws_route_table.public_route_main | aws_vpc.vpc_main | `vpc_id = aws_vpc.vpc_main.id` |
| aws_route_table.public_route_main | aws_internet_gateway.internet_gateway_main | `gateway_id = aws_internet_gateway.internet_gateway_main.id` |
| aws_route_table_association.public_route_association_main | aws_subnet.subnet_main | `subnet_id = aws_subnet.subnet_main.id` |
| aws_route_table_association.public_route_association_main | aws_route_table.public_route_main | `route_table_id = aws_route_table.public_route_main.id` |
| aws_security_group.sg_main | aws_vpc.vpc_main | `vpc_id = aws_vpc.vpc_main.id` |
| aws_instance.my_instance | aws_security_group.sg_main | `vpc_security_group_ids = [aws_security_group.sg_main.id]` |
| aws_instance.my_instance | aws_subnet.subnet_main | `subnet_id = aws_subnet.subnet_main.id` | 
---

### Task 4: Add a Security Group and EC2 Instance
Add to your config:

1. `aws_security_group` in the VPC:
   - Ingress rule: allow SSH (port 22) from `0.0.0.0/0`
   - Ingress rule: allow HTTP (port 80) from `0.0.0.0/0`
   - Egress rule: allow all outbound traffic
   - Tag: `"TerraWeek-SG"`

2. `aws_instance` in the subnet:
   - Use Amazon Linux 2 AMI for your region
   - Instance type: `t2.micro`
   - Associate the security group
   - Set `associate_public_ip_address = true`
   - Tag: `"TerraWeek-Server"`

Apply and verify -- your EC2 instance should have a public IP and be reachable.
         
<img width="1920" height="1002" alt="Screenshot (613)" src="https://github.com/user-attachments/assets/64fac0e4-fd9b-4faf-9f80-244166a19913" />
<img width="1920" height="995" alt="Screenshot (611)" src="https://github.com/user-attachments/assets/b647c2aa-c0e2-42c6-a9fc-eb50d4aa1076" />

<img width="1920" height="995" alt="Screenshot (607)" src="https://github.com/user-attachments/assets/2c7d5229-5e4e-4b1b-8196-c831d54a40f8" />


```hcl
 resource "aws_security_group" "sg_main" {
    name = "TerraWeek-Security-Group"
    description = "Allow HTTP and SSH traffic"
    vpc_id = aws_vpc.vpc_main.id

    ingress {
        description = "Allow HTTP traffic"
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        description = "Allow SSH traffic"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        description = "Allow all outbound traffic"
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags = {
        Name = "TerraWeek-SG"
    }
}
```

### Task 5: Explicit Dependencies with depends_on
Sometimes Terraform cannot detect a dependency automatically.

1. Add a second `aws_s3_bucket` resource for application logs
2. Add `depends_on = [aws_instance.main]` to the S3 bucket -- even though there is no direct reference, you want the bucket created only after the instance
3. Run `terraform plan` and observe the order

Now visualize the entire dependency tree:
```bash
terraform graph | dot -Tpng > graph.png
```
If you don't have `dot` (Graphviz) installed, use:
```bash
terraform graph
```
and paste the output into an online Graphviz viewer.

**Document:** When would you use `depends_on` in real projects? Give two examples.
      + Use depends_on only when implicit dependency is NOT possible
      + i want to create an S3 bucket after EC2 is ready, but there is no attribute reference between them.
      + Running a script after EC2 is created that depends on another resource (like IAM role or DB)
    
---

<img width="1300" height="510" alt="Screenshot (598)" src="https://github.com/user-attachments/assets/d3aa95df-1f7a-428d-ab33-e4a1e241ece1" />

---

### Task 6: Lifecycle Rules and Destroy
1. Add a `lifecycle` block to your EC2 instance:
```hcl
lifecycle {
  create_before_destroy = true
}
```
2. Change the AMI ID to a different one and run `terraform plan` -- observe that Terraform plans to create the new instance before destroying the old one

<img width="1920" height="804" alt="Screenshot (614)" src="https://github.com/user-attachments/assets/ed51cc23-e35d-4aa3-9561-c720a1ecc571" />
<img width="1920" height="644" alt="Screenshot (617)" src="https://github.com/user-attachments/assets/edd623dc-236e-439b-9260-0aa5008b1557" />



3. Destroy everything:
```bash
terraform destroy
```
4. Watch the destroy order -- Terraform destroys in reverse dependency order. Verify in the AWS console that everything is cleaned up.

**Document:** What are the three lifecycle arguments (`create_before_destroy`, `prevent_destroy`, `ignore_changes`) and when would you use each?

+ create_before_destroy -
     + Creates new resource before deleting old one
        + EC2 instances
        + Load balancers
        + Zero downtime deployments
    + prevent_destroy
     + Blocks accidental deletion
       + Databases (RDS)
       + S3 buckets with important data
       + Production infrastructure
    + ignore_changes 
     + Ignores changes in specified attributes
       + When values are modified outside Terraform
       + Auto-scaling / dynamic values
       + Tags managed by another system   
---

## Documentation

- Explanation of implicit vs explicit dependencies in your own words
     + Implicit dependency means Terraform automatically understands the order when one resource uses another resource’s value.
     + Explicit dependency means we manually tell Terraform that one resource depends on another using depends_on, even if there is no direct reference.
       
---
