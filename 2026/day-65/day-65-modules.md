# Day 65 -- Terraform Modules: Build Reusable Infrastructure

### Task 1: Understand Module Structure
A Terraform module is just a directory with `.tf` files. Create this structure:

```
terraform-modules/
  main.tf                    # Root module -- calls child modules
  variables.tf               # Root variables
  outputs.tf                 # Root outputs
  providers.tf               # Provider config
  modules/
    ec2-instance/
      main.tf                # EC2 resource definition
      variables.tf           # Module inputs
      outputs.tf             # Module outputs
    security-group/
      main.tf                # Security group resource definition
      variables.tf           # Module inputs
      outputs.tf             # Module outputs
```

Create all the directories and empty files. This is the standard layout every Terraform project follows.

**Document:** What is the difference between a "root module" and a "child module"?
   + Root Module: The main Terraform configuration where execution starts.
   + Child Module: A reusable module called by the root module to perform specific tasks.

     
<img width="764" height="1017" alt="Screenshot (679)" src="https://github.com/user-attachments/assets/63ea6c2e-44f5-4b34-a757-66b1d38baf76" />

---

### Task 2: Build a Custom EC2 Module
Create `modules/ec2-instance/`:

1. **`variables.tf`** -- define inputs:
   - `ami_id` (string)
   - `instance_type` (string, default: `"t2.micro"`)
   - `subnet_id` (string)
   - `security_group_ids` (list of strings)
   - `instance_name` (string)
   - `tags` (map of strings, default: `{}`)

2. **`main.tf`** -- define the resource:
   - `aws_instance` using all the variables
   - Merge the Name tag with additional tags

3. **`outputs.tf`** -- expose:
   - `instance_id`
   - `public_ip`
   - `private_ip`

Do NOT apply yet -- just write the module.

---

### Task 3: Build a Custom Security Group Module
Create `modules/security-group/`:

1. **`variables.tf`** -- define inputs:
   - `vpc_id` (string)
   - `sg_name` (string)
   - `ingress_ports` (list of numbers, default: `[22, 80]`)
   - `tags` (map of strings, default: `{}`)

2. **`main.tf`** -- define the resource:
   - `aws_security_group` in the given VPC
   - Use `dynamic "ingress"` block to create rules from the `ingress_ports` list
   - Allow all egress

3. **`outputs.tf`** -- expose:
   - `sg_id`

This is your first time using a `dynamic` block -- it loops over a list to generate repeated nested blocks.


---


### Task 4: Call Your Modules from Root
In the root `main.tf`, wire everything together:

1. Create a VPC and subnet directly (or reuse your Day 62 config)
2. Call the security group module:
```hcl
module "web_sg" {
  source        = "./modules/security-group"
  vpc_id        = aws_vpc.main.id
  sg_name       = "terraweek-web-sg"
  ingress_ports = [22, 80, 443]
  tags          = local.common_tags
}
```
3. Call the EC2 module -- deploy **two instances** with different names using the same module:
```hcl
module "web_server" {
  source             = "./modules/ec2-instance"
  ami_id             = data.aws_ami.amazon_linux.id
  instance_type      = "t2.micro"
  subnet_id          = aws_subnet.public.id
  security_group_ids = [module.web_sg.sg_id]
  instance_name      = "terraweek-web"
  tags               = local.common_tags
}

module "api_server" {
  source             = "./modules/ec2-instance"
  ami_id             = data.aws_ami.amazon_linux.id
  instance_type      = "t2.micro"
  subnet_id          = aws_subnet.public.id
  security_group_ids = [module.web_sg.sg_id]
  instance_name      = "terraweek-api"
  tags               = local.common_tags
}
```

4. Add root outputs that reference module outputs:
```hcl
output "web_server_ip" {
  value = module.web_server.public_ip
}

output "api_server_ip" {
  value = module.api_server.public_ip
}
```

5. Apply:
```bash
terraform init    # Downloads/links the local modules
terraform plan    # Should show all resources from both module calls
terraform apply
```

**Verify:** Two EC2 instances running, same security group, different names. Check the AWS console.
   + 2 EC2 Instances
        - terraweek-web
        - terraweek-api
---
<img width="1920" height="356" alt="Screenshot (667)" src="https://github.com/user-attachments/assets/38814a94-df1d-4720-8d8c-fdb1899ffc7a" />
<img width="1920" height="357" alt="Screenshot (670)" src="https://github.com/user-attachments/assets/9636b422-a58b-4bf5-b556-8871cb908c61" />


### Task 5: Use a Public Registry Module
Instead of building your own VPC from scratch, use the official module from the Terraform Registry.

1. Replace your hand-written VPC resources with:
```hcl
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "terraweek-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["ap-south-1a", "ap-south-1b"]
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.3.0/24", "10.0.4.0/24"]

  enable_nat_gateway = false
  enable_dns_hostnames = true

  tags = local.common_tags
}
```

2. Update your EC2 and SG module calls to reference `module.vpc.vpc_id` and `module.vpc.public_subnets[0]`

3. Run:
```bash
terraform init     # Downloads the registry module
terraform plan
terraform apply
```

4. Compare: how many resources did the VPC module create vs your hand-written VPC from Day 62?
   + 2 Public Subnets
   + 2 Private Subnets

**Document:** Where does Terraform download registry modules to? Check `.terraform/modules/`.
     + Terraform downloads registry modules into `.terraform/modules/`
    
<img width="1920" height="981" alt="Screenshot (674)" src="https://github.com/user-attachments/assets/a5c83a26-86e6-4bb6-b765-4d3a1788f117" />

---
<img width="1920" height="795" alt="Screenshot (676)" src="https://github.com/user-attachments/assets/59a8b582-452f-43e7-b911-3bc4f126dee2" />


### Task 6: Module Versioning and Best Practices
1. Pin your registry module version explicitly:
   - `version = "5.1.0"` -- exact version
   - `version = "~> 5.0"` -- any 5.x version
   - `version = ">= 5.0, < 6.0"` -- range

2. Run `terraform init -upgrade` to check for newer versions

3. Check the state to see how modules appear:
```bash
terraform state list
```
Notice the `module.vpc.`, `module.web_server.`, `module.web_sg.` prefixes.

4. Destroy everything:
```bash
terraform destroy
```

**Document:** Write down five module best practices:
- Always pin versions for registry modules
     - Always specify a version for registry modules to avoid unexpected changes or breaking updates in future.
       
- Keep modules focused -- one concern per module
     - Each module should handle only one task (e.g., EC2, VPC, Security Group) to keep code clean and maintainable.
       
- Use variables for everything, hardcode nothing
     - Define inputs using variables so modules become reusable and flexible across environments.
       
- Always define outputs so callers can reference resources
     - Expose important values (like IDs, IPs) using outputs so other modules or root configurations can reference them.
       
- Add a README.md to every custom module
    - Document inputs, outputs, and usage to make modules easy to understand and use, especially in team environments.

---


