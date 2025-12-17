module "vpc" {
  source              = "./modules/vpc"
  vpc_cidr            = var.vpc_cidr
  region              = var.region
  public_subnet_cidr  = var.public_subnet_cidr
  private_subnet_cidr = var.private_subnet_cidr
  cluster_name        = var.cluster_name
  availability_zones  = var.availability_zones
}

module "eks" {
  source             = "./modules/eks"
  cluster_name       = var.cluster_name
  cluster_version    = var.cluster_version
  cluster_vpc_id     = module.vpc.vpc_details[0]
  node_groups        = var.node_groups
  cluster_subnet_ids = module.vpc.private_subnet_details[0]
}