resource "aws_security_group" "add_sg_eks" {
  name   = "mj-additional-eks-sg"
  vpc_id = data.terraform_remote_state.ec2.outputs.vpc_id
  ingress {
    description     = "HTTPS from bastion host"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [data.terraform_remote_state.ec2.outputs.bastion_sg_id]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "mj-additional-eks-sg"
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = "mj-cluster"
  kubernetes_version = "1.34"

  addons = {
    coredns = {}
    eks-pod-identity-agent = {
      before_compute = true
    }
    kube-proxy = {}
    vpc-cni = {
      before_compute = true
    }
  }

  endpoint_public_access = false

  enable_cluster_creator_admin_permissions = true


  vpc_id                        = data.terraform_remote_state.ec2.outputs.vpc_id
  subnet_ids                    = data.terraform_remote_state.ec2.outputs.private_subnets
  additional_security_group_ids = [aws_security_group.add_sg_eks.id]

  eks_managed_node_groups = {
    mj-nodes = {
      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = ["c7i-flex.large"]

      min_size     = 2
      max_size     = 10
      desired_size = 2
    }
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}
