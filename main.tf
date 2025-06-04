provider "aws" {
  region = "eu-west-1"
}

module "vpc" {
  source                = "./modules/vpc"
  vpc_cidr              = "10.0.0.0/16"
  public_subnet_1_cidr  = "10.0.1.0/24"
  public_subnet_2_cidr  = "10.0.2.0/24"
  az1                   = "eu-west-1a"
  az2                   = "eu-west-1b"
}

module "sg" {
  source  = "./modules/sg"
  vpc_id  = module.vpc.vpc_id
  ports   = [80, 4000]
}

module "alb" {
  source   = "./modules/alb"
  vpc_id   = module.vpc.vpc_id
  subnets  = [module.vpc.subnet_1_id, module.vpc.subnet_2_id]
  sg_id    = module.sg.sg_id
}

module "ec2" {
  source             = "./modules/ec2"
  ami                = "ami-0df368112825f8d8f"
  instance_type      = var.instance_type
  subnet_1           = module.vpc.subnet_1_id
  subnet_2           = module.vpc.subnet_2_id
  sg_id              = module.sg.sg_id
  tags               = var.tags
  openproject_tg_arn = module.alb.openproject_tg_arn
  devlake_tg_arn     = module.alb.devlake_tg_arn

}
 
