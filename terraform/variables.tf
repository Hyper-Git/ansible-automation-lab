variable "my_ip" {
  description = "my IP for SSH in to EC2"
  type        = string
}

variable "region" {
  description = "Region for the VPC"
  default     = "eu-west-2"
}
