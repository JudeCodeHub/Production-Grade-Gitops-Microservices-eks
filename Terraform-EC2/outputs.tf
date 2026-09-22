output "vpc_id" {
  value = module.vpc.vpc_id
}

output "private_subnets" {
  value = module.vpc.private_subnets
}

output "bastion_public_ip" {
  value = module.bastion_host.public_ip
}

output "bastion_sg_id" {
  value = aws_security_group.bastion_sg.id
}
