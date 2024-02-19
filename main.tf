terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.12.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.25.2"
    }

  }
}
provider "aws" {
  region = "us-east-1"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

module "eks_fargate" {
  source        = "./modules/eks_cluster"
  cluster_name  = "sins-cluster"
  az1           = "us-east-1a"
  az2           = "us-east-1b"
  region        = "us-east-1"
  replica_count = 1
}
