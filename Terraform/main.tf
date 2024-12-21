module "vpc" {
  source = "./modules/vpc"
}

module "launch_instances" {
  source = "./modules/Instances"
  vpc_id = module.vpc.vpc_id
  public_subnet_cidr = module.vpc.public_subnet_cidr
  private_subnet_cidrs = module.vpc.private_subnet_cidrs
  private_subnet_ids = module.vpc.private_subnet_ids
  public_subnet_id = module.vpc.public_subnet_id
}