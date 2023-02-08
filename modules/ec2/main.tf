# Still work in process - testing something new
/*
resource "aws_network_interface" "net_int" {
  subnet_id   = var.public_subnets
  tags = {
    Name = "primary_network_interface"
  }
}

resource aws_instance "cluster" {
    for_each = var.basic_cluster
    ami = data.aws_ami.amzn_linux.id
    instance_type = "t2.micro"
    network_interface {
    network_interface_id = aws_network_interface.net_int.id
    device_index         = 0
  }    
}
*/