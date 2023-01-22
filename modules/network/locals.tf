locals {
    create_nat = var.private_subnets && var.enable_nat_gateway
    availability_zones = data.aws_availability_zones.available.names
    az_count = length(local.availability_zones)
}