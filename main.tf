module "network" {
    source = "./modules/network"
    name = "Jad Slots Game"
    vpc_cidr = "10.0.0.0/16"
}

#module "ec2" {
#    source = "./modules/ec2"
#    public_subnets = module.network.public_subnets[0].id
#}


