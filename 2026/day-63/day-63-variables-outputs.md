# Day 63 -- Variables, Outputs, Data Sources and Expressions

### Task 1: Extract Variables
Take your Day 62 infrastructure config and refactor it:

1. Create a `variables.tf` file with input variables for:
   - `region` (string, default: your preferred region)
   - `vpc_cidr` (string, default: `"10.0.0.0/16"`)
   - `subnet_cidr` (string, default: `"10.0.1.0/24"`)
   - `instance_type` (string, default: `"t2.micro"`)
   - `project_name` (string, no default -- force the user to provide it)
   - `environment` (string, default: `"dev"`)
   - `allowed_ports` (list of numbers, default: `[22, 80, 443]`)
   - `extra_tags` (map of strings, default: `{}`)

2. Replace every hardcoded value in `main.tf` with `var.<name>` references
3. Run `terraform plan` -- it should prompt you for `project_name` since it has no default

**Document:** What are the five variable types in Terraform? (`string`, `number`, `bool`, `list`, `map`)


+ String

```A string is used to store text values such as names, IDs, or file paths.
It is the most commonly used variable type in Terraform.
Example: "t3.micro", "my-key-pair"
```

+ Number
```
A number is used to store numeric values like counts or sizes.
It supports both integers and floating-point numbers.
Example: 1, 100, 0.5
```


+ Bool
```
A bool (boolean) stores true or false values.
It is used for enabling or disabling features.
Example: true, false
```

+ List
```
A list is an ordered collection of values of the same type.
It is useful when you need multiple values in a sequence.
Example: ["subnet-1", "subnet-2"]
```

+ Map
```
A map is a collection of key-value pairs.
It is used to store structured data like tags or configurations.
Example: { Name = "Aliya", Env = "Dev" }
```

---
### Task 2: Variable Files and Precedence
1. Create `terraform.tfvars`:
```hcl
project_name = "terraweek"
environment  = "dev"
instance_type = "t2.micro"
```

2. Create `prod.tfvars`:
```hcl
project_name = "terraweek"
environment  = "prod"
instance_type = "t3.small"
vpc_cidr     = "10.1.0.0/16"
subnet_cidr  = "10.1.1.0/24"
```

3. Apply with the default file:
```bash
terraform plan                              # Uses terraform.tfvars automatically
```

4. Apply with the prod file:
```bash
terraform plan -var-file="prod.tfvars"      # Uses prod.tfvars
```

5. Override with CLI:
```bash
terraform plan -var="instance_type=t2.nano"  # CLI overrides everything
```

6. Set an environment variable:
```bash
export TF_VAR_environment="staging"
terraform plan                              # env var overrides default but not tfvars
```

**Document:** Write the variable precedence order from lowest to highest priority.
<img width="1920" height="987" alt="Screenshot (622)" src="https://github.com/user-attachments/assets/2f0ad4c6-24e9-4f0b-a62e-f5f02167df3a" />
<img width="1920" height="699" alt="Screenshot (621)" src="https://github.com/user-attachments/assets/d3711d11-7f2f-4c49-87ac-c5f8d44660cb" />


+ Variable Precedence (Low → High)
   + Default values (defined in variables.tf)
   + Environment variables (TF_VAR_name)
   + terraform.tfvars file
   + .auto.tfvars files
   + Command-line -var and -var-file options (highest priority)

---

### Task 3: Add Outputs
Create an `outputs.tf` file with outputs for:

1. `vpc_id` -- the VPC ID
2. `subnet_id` -- the public subnet ID
3. `instance_id` -- the EC2 instance ID
4. `instance_public_ip` -- the public IP of the EC2 instance
5. `instance_public_dns` -- the public DNS name
6. `security_group_id` -- the security group ID

Apply your config and verify the outputs are printed at the end:
```bash
terraform apply

# After apply, you can also run:
terraform output                          # Show all outputs
terraform output instance_public_ip       # Show a specific output
terraform output -json                    # JSON format for scripting
```

**Verify:** Does `terraform output instance_public_ip` return the correct IP?


---
<img width="1920" height="999" alt="Screenshot (623)" src="https://github.com/user-attachments/assets/6ec95c50-8415-4413-b02f-6df216f5d195" />

### Task 3: Add Outputs
Create an `outputs.tf` file with outputs for:

1. `vpc_id` -- the VPC ID
2. `subnet_id` -- the public subnet ID
3. `instance_id` -- the EC2 instance ID
4. `instance_public_ip` -- the public IP of the EC2 instance
5. `instance_public_dns` -- the public DNS name
6. `security_group_id` -- the security group ID

Apply your config and verify the outputs are printed at the end:
```bash
terraform apply

# After apply, you can also run:
terraform output                          # Show all outputs
terraform output instance_public_ip       # Show a specific output
terraform output -json                    # JSON format for scripting
```

**Verify:** Does `terraform output instance_public_ip` return the correct IP?
yes it return correct ip 

---
<img width="1920" height="583" alt="Screenshot (624)" src="https://github.com/user-attachments/assets/0311865e-1e2a-4cd5-9726-e74d6d0f81ac" />


### Task 4: Use Data Sources
Stop hardcoding the AMI ID. Use a data source to fetch it dynamically.

1. Add a `data "aws_ami"` block that:
   - Filters for Amazon Linux 2 images
   - Filters for `hvm` virtualization and `gp2` root device
   - Uses `owners = ["amazon"]`
   - Sets `most_recent = true`

2. Replace the hardcoded AMI in your `aws_instance` with `data.aws_ami.amazon_linux.id`

3. Add a `data "aws_availability_zones"` block to fetch available AZs in your region

4. Use the first AZ in your subnet: `data.aws_availability_zones.available.names[0]`

Apply and verify -- your config now works in any region without changing the AMI.

**Document:** What is the difference between a `resource` and a `data` source?

+ Difference between resource and data source
```
A resource is used to create, update, or delete infrastructure in Terraform.
A data source is used to fetch or read existing infrastructure without creating it.
In short, resource manages infrastructure, while data only retrieves information.
```
---

<img width="1920" height="1005" alt="Screenshot (625)" src="https://github.com/user-attachments/assets/136768cc-bae7-4f68-aef3-4ade21a10122" />

<img width="1920" height="1029" alt="Screenshot (626)" src="https://github.com/user-attachments/assets/55132a82-eb71-4e5a-87e6-9c8efda9571d" />

### Task 4: Use Data Sources
Stop hardcoding the AMI ID. Use a data source to fetch it dynamically.

1. Add a `data "aws_ami"` block that:
   - Filters for Amazon Linux 2 images
   - Filters for `hvm` virtualization and `gp2` root device
   - Uses `owners = ["amazon"]`
   - Sets `most_recent = true`

2. Replace the hardcoded AMI in your `aws_instance` with `data.aws_ami.amazon_linux.id`

3. Add a `data "aws_availability_zones"` block to fetch available AZs in your region

4. Use the first AZ in your subnet: `data.aws_availability_zones.available.names[0]`

Apply and verify -- your config now works in any region without changing the AMI.

**Document:** What is the difference between a `resource` and a `data` source?
      
---
<img width="1920" height="1029" alt="Screenshot (627)" src="https://github.com/user-attachments/assets/99a45e51-cb5e-459b-a8f0-a407a89b0fb6" />


### Task 5: Use Locals for Dynamic Values
1. Add a `locals` block:
```hcl
locals {
  name_prefix = "${var.project_name}-${var.environment}"
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
```

2. Replace all Name tags with `local.name_prefix`:
   - VPC: `"${local.name_prefix}-vpc"`
   - Subnet: `"${local.name_prefix}-subnet"`
   - Instance: `"${local.name_prefix}-server"`

3. Merge common tags with resource-specific tags:
```hcl
tags = merge(local.common_tags, {
  Name = "${local.name_prefix}-server"
})
```

Apply and check the tags in the AWS console -- every resource should have consistent tagging.
<img width="1920" height="1029" alt="Screenshot (632)" src="https://github.com/user-attachments/assets/0ea36874-00aa-4d6a-b425-3caf8e96b515" />
<img width="1920" height="1029" alt="Screenshot (631)" src="https://github.com/user-attachments/assets/33bc7570-db23-4526-a085-ee9cddd1c2dd" />

---

### Task 6: Built-in Functions and Conditional Expressions
Practice these in `terraform console`:
```bash
terraform console
```

1. **String functions:**
   - `upper("terraweek")` -> `"TERRAWEEK"`
   - `join("-", ["terra", "week", "2026"])` -> `"terra-week-2026"`
   - `format("arn:aws:s3:::%s", "my-bucket")`

2. **Collection functions:**
   - `length(["a", "b", "c"])` -> `3`
   - `lookup({dev = "t2.micro", prod = "t3.small"}, "dev")` -> `"t2.micro"`
   - `toset(["a", "b", "a"])` -> removes duplicates

3. **Networking function:**
   - `cidrsubnet("10.0.0.0/16", 8, 1)` -> `"10.0.1.0/24"`

4. **Conditional expression** -- add this to your config:
```hcl
instance_type = var.environment == "prod" ? "t3.small" : "t2.micro"
```

Apply with `environment = "prod"` and verify the instance type changes.

**Document:** Pick five functions you find most useful and explain what each does.

###  `upper()`
Converts a string to uppercase.  
Useful for standardizing naming conventions.  
Example: `upper("terraweek") → "TERRAWEEK"`  

---

###  `join()`
Combines multiple strings into one using a separator.  
Helpful for creating names, tags, or IDs.  
Example: `join("-", ["terra", "week"]) → "terra-week"`  

---

###  `length()`
Returns the number of elements in a list or characters in a string.  
Useful for validations and dynamic configurations.  
Example: `length(["a", "b", "c"]) → 3`  

---

###  `lookup()`
Fetches a value from a map using a key.  
Helpful for environment-based configurations.  
Example: `lookup({dev="t2.micro"}, "dev") → "t2.micro"`  

---

###  `cidrsubnet()`
Creates smaller subnets from a larger CIDR block.  
Commonly used in VPC and networking setups.  
Example: `cidrsubnet("10.0.0.0/16", 8, 1) → "10.0.1.0/24"`  

---

## Documentation

- Explanation of variable precedence with examples
  ##  Variable Precedence (with Example)

Terraform follows a priority order when assigning variable values (low-high):

1. Default values (`variables.tf`)
2. Environment variables (`TF_VAR_name`)
3. `terraform.tfvars`
4. `.auto.tfvars`
5. CLI flags (`-var`, `-var-file`)  highest priority

###  Example

```hcl
variable "instance_type" {
  default = "t2.micro"
}
```
- The difference between `variable`, `local`, `output`, and `data`
  ##  Difference: `variable` vs `local` vs `output` vs `data`

| Type       | Purpose                                      | Creates Resource? | Usage Example                  |
|------------|----------------------------------------------|------------------|--------------------------------|
| `variable` | Accepts input values                         |  No            | `var.instance_type`           |
| `local`    | Stores reusable internal values              |  No            | `local.common_tags`           |
| `output`   | Displays values after execution              |  No            | `output "ip"`                 |
| `data`     | Fetches existing infrastructure information  |  No            | `data.aws_ami.latest`         |

---







