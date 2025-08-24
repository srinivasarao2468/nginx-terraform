provider "aws" {
  region = var.region
}

module "network" {
  source        = "./modules/network"
  vpc_cidr      = "10.0.0.0/16"
  public_cidrs  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_cidrs = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
}

module "ec2" {
  source             = "./modules/ec2"
  private_subnets    = module.network.private_subnets
  name_prefix = "nginx"
  vpc_id             = module.network.vpc_id
  instance_type      = "t3.micro"
  instance_count     = 3
  min_instance_count = 1
  max_instance_count = 3
  alb_sg_id          = module.alb.alb_sg_id
}

module "alb" {
  source           = "./modules/alb"
  alb_name         = "nginx-alb"
  vpc_id           = module.network.vpc_id
  public_subnets   = module.network.public_subnets
  target_group_arn = module.ec2.target_group_arn
  enable_https     = var.enable_https
  certificate_arn  = var.certificate_arn
}


# module "acm_cert" {
#   source      = "./modules/acm"
#   domain_name = "example.com"
#   san_domains = ["www.example.com"]
#   zone_id     = "Z123456789ABC"  # Replace with your Route53 zone ID

#   tags = {
#     Environment = "prod"
#     Project     = "web"
#   }
# }
