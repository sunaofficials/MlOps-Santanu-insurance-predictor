variable "region" {
  default = "us-east-1"
}

variable "cluster_name" {
  default = "ml-insurance-eks"
}

variable "node_instance_type" {
  default = "t3.medium"
}

variable "desired_size" {
  default = 1
}
