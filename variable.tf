variable "access_key" {}

variable "secret_key" {}

variable "aws_region" {
  default = "us-west-2"
}

variable "environment" {
  default = "dev"
}

variable "tags" {
  type = map(string)
  default = {
    "tmna:terraform:ver"  = "0.12"
    "tmna:terraform:repo" = "Terraform repo"
    "tmna:project:type"   = "type of the project"
    "tmna:bu"             = "bussiness"
    "tmna:team"           = "team"
  }
}
