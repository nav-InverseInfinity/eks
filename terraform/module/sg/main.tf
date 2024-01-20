resource "aws_security_group" "eks-sg" {
  name        = "eks-sg"
  description = "Allow traffic for EKS"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.eks_sg_ingress
    content {
      description = "EKS Ingress"
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = [ingress.value.cidr_block]
    }
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "eks-sg"
  }
}
