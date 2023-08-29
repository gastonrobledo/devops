variable "aws_access_key" {
  description = "Access-key-for-AWS"
  default = "no_access_key_value_found"
}
 
variable "aws_secret_key" {
  description = "Secret-key-for-AWS"
  default = "no_secret_key_value_found"
}

variable "aws_region" {
    type = string
    default = "us-east-1"
}

variable "instance_type" {
    type = string
    default = "t2.micro"
}

variable "project" {
  type = string
  description = "Project name or application"
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default = {
    "Project"     = "TerraformEKSMundoesE"
    "Environment" = "Development"
    "Owner"       = "Gaston Robledo"
  }
}

variable "kube_version" {
  type = string
  default = "1.27"
}

variable "namespace" {
  type    = string
  default = "monitoring"
}

variable "kube_config" {
  type    = string
  default = "~/.kube/config"
}

variable "arn_account"  {
  type = string
}

variable "arn_username" {
  type = string
}