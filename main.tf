module "network" {
    source = "./modules/network"
    name = "Jad Slots Game"
    vpc_cidr = "10.0.0.0/16"
}

