terraform {
  backend "s3" {
    profile        = "ipfs"
    region         = "us-west-2"
    bucket         = "management-ipfs-elastic-provider"
    dynamodb_table = "management-ipfs-elastic-provider-lock"
    key            = "management-ipfs-elastic-provider.tfstate"
    encrypt        = true
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.38"
    }
  }

  required_version = ">= 1.0.0"
}

provider "aws" {
  profile = var.profile
  region  = var.region
  default_tags {
    tags = {
      Team        = "NearForm"
      Project     = "AWS-IPFS"
      Environment = "Prod"
      Subsystem   = "Management"
      ManagedBy   = "Terraform"
    }
  }
}

data "aws_availability_zones" "available" {
}

resource "aws_eip" "nat_eip" {
  vpc = true

  # lifecycle {
  #   prevent_destroy = true
  # }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name                 = var.vpc.name
  cidr                 = "10.10.0.0/16"
  azs                  = data.aws_availability_zones.available.names
  private_subnets      = ["10.10.1.0/24", "10.10.2.0/24"] # EC2
  public_subnets       = ["10.10.3.0/24", "10.10.4.0/24"] # NAT
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true
  ## Fixed external Nat IP
  reuse_nat_ips       = true
  external_nat_ip_ids = [aws_eip.nat_eip.id]
  ##  
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

data "template_file" "runner_server" {
  template = file("agent.sh")
  vars = {
    repo           = var.repo
    token          = var.token
    runner_name    = var.runner_name
    runner_version = "2.295.0"
  }
}

resource "aws_instance" "self_runner" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.medium"
  subnet_id     = module.vpc.private_subnets[0]
  user_data     = data.template_file.runner_server.rendered # TODO: Replace installs by a packer generated AMI
  tags = {
    Name = "GitHubActionsSelfRunnerIPFSAwsInfra"
  }
}

#########  Just for troubleshoot (Accessible SSH instance)
# resource "aws_instance" "self_runner" {
#   ami           = data.aws_ami.ubuntu.id
#   instance_type = "t2.medium"
#   subnet_id     = module.vpc.public_subnets[0]

#   tags = {
#     Name = "GitHubActionsSelfRunnerIPFSAwsInfra"
#   }
#   user_data              = data.template_file.runner_server.rendered
#   vpc_security_group_ids = ["sg-052cf424f9878f8f8"]
#   key_name               = "management-ipfs-elastic"
# }
########
