resource "aws_security_group" "this" {
  name   = var.sg_name
  vpc_id = var.vpc_id

  # 🔁 Dynamic ingress rules
  dynamic "ingress" {
    for_each = var.ingress_ports

    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  # 🌍 Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # 🏷️ Tags
  tags = merge(
    {
      Name = var.sg_name
    },
    var.tags
  )
}
