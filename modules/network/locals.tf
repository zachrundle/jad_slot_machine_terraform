locals {
    availability_zones = data.aws_availability_zones.available.names
    az_count = length(local.availability_zones)
}