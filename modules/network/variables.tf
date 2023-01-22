variable "name" {
    description = "Provide the name of the project"
}

variable "vpc_cidr" {
    description = "Provide the /16 CIDR for the VPC"
}

variable "private_subnets" {
    default = false
}

variable "enable_nat_gateway" {
    default = false
}


