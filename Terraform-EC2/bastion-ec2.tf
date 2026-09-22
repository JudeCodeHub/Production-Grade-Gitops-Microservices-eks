resource "tls_private_key" "bastion_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "bastion_keypair" {
  key_name   = "mj-bastion-key"
  public_key = tls_private_key.bastion_key.public_key_openssh
}



resource "local_file" "bastion_private_key" {
  content         = tls_private_key.bastion_key.private_key_pem
  filename        = "mj-bastion-key.pem"
  file_permission = "0400"
}


resource "aws_security_group" "bastion_sg" {
  name   = "mj-bastion-sg"
  vpc_id = module.vpc.vpc_id

  ingress {
    description = "SSH from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.my_ip.response_body)}/32"]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "mj-bastion-sg"
  }
}



module "bastion_host" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name          = "mj-bastion-host"
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  key_name      = aws_key_pair.bastion_keypair.key_name
  monitoring    = true

  subnet_id              = element(module.vpc.public_subnets, 0)
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]

  associate_public_ip_address = true

  tags = {
    Terraform   = "true"
    Environment = "dev"
    Role        = "bastion"
  }
}
