###  AWS globals ###
variable "region" {
  description = "AWS region"
}

variable "environment" {
    description = "environment tag name"
}

### AWS VPC ###
variable "vpc_name" {
  description = "AWS vpc name"
}

### AWS EKS ###
variable "cluster_name" {
  description = "EKS cluster name"
}

variable "cluster_version" {
  description = "EKS cluster version"
}

locals {
  cluster_name = "${var.cluster_name}-${random_string.suffix.result}"
}

resource "random_string" "suffix" {
  length  = 4
  special = false
}