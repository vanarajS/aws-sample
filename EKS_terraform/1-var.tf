variable "region" {
  type = string
  default = "us-east-1"
}

variable "vpc_cidr" {
    default = "10.0.0.0/16"
  
}

variable "tags" {
    type = map(string)
    default = {
      "terraform" = "true"
      "kubernetes" = "eks-demo"
      "Name" = "eks-vpc"
    }
  
}