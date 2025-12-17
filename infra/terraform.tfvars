vpc_cidr            = "10.0.0.0/16"
region              = "ap-south-2"
public_subnet_cidr  = ["10.0.3.0/24", "10.0.4.0/24"]
private_subnet_cidr = ["10.0.1.0/24", "10.0.2.0/24"]
cluster_name        = "my-eks-cluster"
availability_zones  = ["ap-south-2a", "ap-south-2b"]
cluster_version     = "1.28"

node_groups = {
  general = {
    capacity_type = "ON_DEMAND"
    instance_type = ["t3.medium"]
    scaling_config = {
      desired_size = 2
      max_size     = 4
      min_size     = 1
    }
  }
}
