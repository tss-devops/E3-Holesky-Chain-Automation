variable "vpc_cidr" {
  default = "10.0.0.0/16"
  type = string
}

variable "public_subnet_cidr" {
  type = string
  default = "10.0.1.0/24"
}

variable "availability_zone_1" {
  default = "us-east-1a"
}

variable "private_subnet_count" {
  type = number
  default = 2
}