variable "aws_region" {
    description = "The AWS region to deploy resources in"
    type        = string
    default     = "us-east-1"
}
variable "vpc_cidr_block" {
    description = "The CIDR block for the VPC"
    type        = string
    default    = "10.0.0.0/16"
}
variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet (the street-facing floor)"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR block for the private subnet (the internal floor)"
  type        = string
  default     = "10.0.2.0/24"
}
# variables.tf — add this
variable "private_subnet2_cidr" {
  description = "CIDR block for the second private subnet (different AZ)"
  type        = string
  default     = "10.0.3.0/24"
}