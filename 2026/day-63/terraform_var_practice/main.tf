# key pair creating for ec2 instance

resource "aws_key_pair" "my_key_pair" {
  key_name   = var.key_name
  public_key = file(var.public_key_path)
}


data "aws_ami" "amazon_linux_2_gp3" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

# Data source to get available AZs
data "aws_availability_zones" "available" {
  state = "available"
}


# Locals for common values and tags
locals {
  name_prefix = "${var.project_name}-${var.environment}"
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}



# terraform creating vpc

resource "aws_vpc" "vpc_main" {
  cidr_block       = var.vpc_cidr
   enable_dns_support   = true
   enable_dns_hostnames = true

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-VPC"
  })
  }

# terraform aws subnet creating

resource "aws_subnet" "subnet_main" {
  vpc_id     = aws_vpc.vpc_main.id
  cidr_block =  var.subnet_cidr
  availability_zone = data.aws_availability_zones.available.names[0]
    tags = merge(local.common_tags, {
      Name = "${local.name_prefix}-Public-Subnet"
    })
}


# terraform creating aws_internet_gateway and connecting with vpc
resource "aws_internet_gateway" "internet_gateway_main" {
  vpc_id = aws_vpc.vpc_main.id

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-Internet-Gateway"
  })
}

# connecting route table with to vpc
resource "aws_route_table" "public_route_main" {
    vpc_id = aws_vpc.vpc_main.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.internet_gateway_main.id
    }
    tags = merge(local.common_tags, {
        Name = "${local.name_prefix}-Public-Route-Table"
    })

}

# route_table_association creating
resource "aws_route_table_association" "public_route_association_main" {
    subnet_id = aws_subnet.subnet_main.id
    route_table_id = aws_route_table.public_route_main.id
}

# security group creating
#task4

resource "aws_security_group" "sg_main" {
    name = "${var.project_name}-${var.environment}-sg"
    description = "Allow HTTP and SSH traffic"
    vpc_id = aws_vpc.vpc_main.id

    dynamic "ingress" {
        for_each = var.allowed_ports
        content {
            from_port   = ingress.value
            to_port     = ingress.value
            protocol    = "tcp"
            cidr_blocks = ["0.0.0.0/0"]
    }
    }
    egress {
        description = "Allow all outbound traffic"
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags = merge(local.common_tags, {
        Name = "${local.name_prefix}-Security-Group"
    })
}

# creating ec2 instance

resource aws_instance my_instance  {
ami = data.aws_ami.amazon_linux_2_gp3.id
instance_type = var.instance_type
key_name = var.key_name
vpc_security_group_ids = [aws_security_group.sg_main.id]
subnet_id = aws_subnet.subnet_main.id
associate_public_ip_address = true

tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-EC2-Instance"
   })

lifecycle {
  create_before_destroy = true
}
}

