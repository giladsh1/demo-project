
module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = local.cluster_name
  cluster_version = var.cluster_version
  subnets         = module.vpc.private_subnets

  tags = {
    Environment = var.environment
    Region = var.region
  }

  vpc_id = module.vpc.vpc_id

  worker_groups = [
    {
      name                          = "frontend"
      instance_type                 = "t2.small"
      asg_desired_capacity          = 1
      additional_security_group_ids = [aws_security_group.frontend.id]
    },
    {
      name                          = "backend"
      instance_type                 = "t2.small"
      additional_security_group_ids = [aws_security_group.backend.id]
      asg_desired_capacity          = 1
    },
  ]
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}