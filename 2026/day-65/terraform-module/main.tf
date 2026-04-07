
# creating AMI

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}


# VPC

# resource "aws_vpc" "main" {
#   cidr_block = "10.0.0.0/16"

#   tags = {
#     Name = "terraweek-vpc"
#   }
# }

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "terraweek-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-west-2a", "us-west-2b"]
  public_subnets  = ["10.0.10.0/24", "10.0.20.0/24"]
  private_subnets = ["10.0.30.0/24", "10.0.40.0/24"]

  enable_nat_gateway   = false
  enable_dns_hostnames = true

  tags = local.common_tags
}


# SUBNET

resource "aws_subnet" "public" {
  vpc_id                  = module.vpc.vpc_id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "terraweek-public-subnet"
  }
}


# SECURITY GROUP MODULE

# module "web_sg" {
#   source        = "./modules/security-group"
#   vpc_id = module.vpc.vpc_id
#   sg_name       = "terraweek-web-sg"
#   ingress_ports = [22, 80, 443]
#   tags          = local.common_tags
# }

module "web_sg" {
  source        = "./modules/security-group"
  vpc_id        = module.vpc.vpc_id
  sg_name       = "terraweek-web-sg"
  ingress_ports = [22, 80, 443]
  tags          = local.common_tags
}


# EC2 MODULE (WEB)

# module "web_server" {
#   source             = "./modules/ec2-instance"
#   ami_id             = data.aws_ami.amazon_linux.id
#   instance_type      = "t3.micro"
#   subnet_id          = aws_subnet.public.id
#   security_group_ids = [module.web_sg.sg_id]
#   instance_name      = "terraweek-web"
#   tags               = local.common_tags
# }

module "web_server" {
  source             = "./modules/ec2-instance"
  ami_id             = data.aws_ami.amazon_linux.id
  instance_type      = "t3.micro"
  subnet_id          = module.vpc.public_subnets[0]
  security_group_ids = [module.web_sg.sg_id]
  instance_name      = "terraweek-web"
  tags               = local.common_tags
}


# EC2 MODULE (API)

# module "api_server" {
#   source             = "./modules/ec2-instance"
#   ami_id             = data.aws_ami.amazon_linux.id
#   instance_type      = "t3.micro"
#   subnet_id          = aws_subnet.public.id
#   security_group_ids = [module.web_sg.sg_id]
#   instance_name      = "terraweek-api"
#   tags               = local.common_tags
# }
module "api_server" {
  source             = "./modules/ec2-instance"
  ami_id             = data.aws_ami.amazon_linux.id
  instance_type      = "t3.micro"
  subnet_id          = module.vpc.public_subnets[0]
  security_group_ids = [module.web_sg.sg_id]
  instance_name      = "terraweek-api"
  tags               = local.common_tags
}

locals {
  common_tags = {
    Project     = "terraweek"
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}
