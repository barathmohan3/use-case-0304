output "vpc_id" {

  value = module.vpc.vpc_id

}

output "subnet_1_id" {

  value = module.vpc.subnet_1_id

}

output "subnet_2_id" {

  value = module.vpc.subnet_2_id

}

output "ec2_security_group" {

  value = module.sg.sg_id

}
 