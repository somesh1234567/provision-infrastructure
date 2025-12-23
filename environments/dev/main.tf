# root

module "vpc" {
    source = "../../modules/vpc"
}

module "ec2" {
    source = "../../modules/web"
    subnet_id = module.vpc.subnet_id
    security_group_id = module.vpc.security_group_id
}