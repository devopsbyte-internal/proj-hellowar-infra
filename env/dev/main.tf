
# Find latest Amazon Linux 2023 AMI

# data = read existing stuff from AWS
# resource = create new stuff in AWS


data "aws_ami" "al2023" {
  most_recent = true

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }


  filter {
    name   = "architecture"
    values = ["x86_64"]
  }


  owners = ["137112412989"] # Amazon
}


# Using default VPC
data "aws_vpc" "default" {
  default = true
}


data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# User data script: download & run bootstrap-tomcat.sh
locals {
  be_bootstrap_url = "https://raw.githubusercontent.com/devopsbyte-internal/proj-hellowar-java-service/refs/heads/main/infra/tomcat/bootstrap-tomcat.sh"
}



module "be_app" {
  count = var.en_be ? 1 : 0
  source = "../../modules/ec2-app"

  name          = "hellowar-tomcat-be"
  role          = "backend"
  vpc_id        = data.aws_vpc.default.id
  subnet_id     = data.aws_subnets.default.ids[0]
  ami_id        = data.aws_ami.al2023.id
  instance_type = var.instance_type
  key_name      = var.key_name

  ssh_cidr = var.my_ip_cidr
  app_port = 8080

  user_data = templatefile("${path.module}/userdata-tomcat.sh.tpl", {
    bootstrap_url = local.be_bootstrap_url
  })

  extra_tags = {
    Environment = "dev"
    Project     = "hellowar"
  }
}


module "fe_app" {
  count = var.en_fe ? 1 : 0
  source = "../../modules/ec2-app"

  name          = "hellowar-tomcat-fe"
  role          = "frontend"
  vpc_id        = data.aws_vpc.default.id
  subnet_id     = data.aws_subnets.default.ids[0]
  ami_id        = data.aws_ami.al2023.id
  instance_type = var.instance_type
  key_name      = var.key_name

  ssh_cidr = var.my_ip_cidr
  app_port = 80

#########
  user_data = templatefile("${path.module}/userdata-tomcat.sh.tpl", {
    bootstrap_url = "https://raw.githubusercontent.com/devopsbyte-internal/proj-hellowar-java-service/refs/heads/main/infra/tomcat/bootstrap-tomcat.sh"
  })

  extra_tags = {
    Environment = "dev"
    Project     = "hellowar"
  }
}