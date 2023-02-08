resource "aws_vpc" "this" {
  cidr_block       = var.vpc_cidr
  enable_dns_hostnames = true
  tags = {
    Name = "${var.name} VPC"
  }
}

# The cidr block is dynamically built by passing in the prefix (VPC cidr), newbits, netnum
# newbits will add 8 to the VPC cidr resulting in /24 subnets, the netnum will count the second octet by 1
resource "aws_subnet" "public_subnet" {
    count = local.az_count
    vpc_id = aws_vpc.this.id
    cidr_block = "${cidrsubnet(var.vpc_cidr, 8, count.index)}"
    availability_zone = local.availability_zones[count.index]
    map_public_ip_on_launch = true
    tags = {
        Name = "${var.name} Public Subnet ${count.index + 1}"
    }
}

# netnum factors in that the first few subnets (based off AZ count for that region) are utilized for Public
resource "aws_subnet" "private_subnet" {
    count = local.az_count
    vpc_id = aws_vpc.this.id
    cidr_block = "${cidrsubnet(var.vpc_cidr, 8, tonumber(local.az_count + count.index))}"
    availability_zone = local.availability_zones[count.index]
    map_public_ip_on_launch = false
    tags = {
        Name = "${var.name} Private Subnet ${count.index + 1}"
    }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.name}"
  }
}

resource "aws_eip" "nat_ip" {
    count = var.create_ngw ? 1 : 0
    vpc = true
    depends_on = [aws_internet_gateway.igw]
    tags = {
      Name = "${var.name} NAT Gateway IP"
  }
}

resource "aws_nat_gateway" "ngw" {
    count = var.create_ngw ? 1 : 0
    allocation_id = aws_eip.nat_ip[count.index].id
    subnet_id     = aws_subnet.public_subnet[count.index].id
    tags = {
      Name = "${var.name} NAT Gateway"
    }
}

resource "aws_route_table" "public_router" {
    vpc_id = aws_vpc.this.id
    tags = {
      Name = "${var.name} Public Routes"
    }
}

resource "aws_route" "ipv4_pub_internet" {
    route_table_id = aws_route_table.public_router.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
}

resource "aws_route_table" "private_router" {
    vpc_id = aws_vpc.this.id
    count = var.create_ngw ? 1 : 0
    tags = {
      Name = "${var.name} Private Routes"
    }
}

resource "aws_route" "ipv4_prv_internet" {
    count = var.create_ngw ? 1 : 0
    route_table_id = aws_route_table.private_router[count.index].id
    destination_cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ngw[count.index].id
}

resource "aws_route_table_association" "public_route_table" {
    count = length(aws_subnet.public_subnet)
    subnet_id = aws_subnet.public_subnet[count.index].id
    route_table_id = aws_route_table.public_router.id
}

resource "aws_route_table_association" "private_route_table" {
    count = var.create_ngw ? length(aws_subnet.private_subnet) : 0
    subnet_id = aws_subnet.private_subnet[count.index].id
    route_table_id = aws_route_table.private_router[0].id
}

