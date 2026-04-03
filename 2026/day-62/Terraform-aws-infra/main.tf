# key pair creating for ec2 instance

resource aws_key_pair my_key_pair {

key_name="secound_terraform_key_josh"
public_key =file("secound_terraform_key_josh.pub")
}


# terraform creating vpc

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

# security group creating
#task4

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

# creating ec2 instance

resource aws_instance my_instance  {
ami = "ami-043ab4148b7bb33e9"
instance_type = "t3.micro"
key_name = "secound_terraform_key_josh"
vpc_security_group_ids = [aws_security_group.sg_main.id]
subnet_id = aws_subnet.subnet_main.id
associate_public_ip_address = true

tags = {
    Name = "TerraWeek-EC2-Instance"
   }

lifecycle {
  create_before_destroy = true
}
}

# creating s3 bucket this will stores the data of ec2 instance

resource aws_s3_bucket my_bucket {
         bucket = "Aliya-ki-bucket"
         depends_on = [aws_instance.my_instance]
         tags = {
            Name = "TerraWeek-S3-Bucket"
         }
}
