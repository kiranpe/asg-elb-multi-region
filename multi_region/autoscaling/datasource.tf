
#########################
#EC2 Image
#########################

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-20190722.1"]
  }

  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }
}

############################
#Sec Grp && VPC
############################

data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "private" {
  vpc_id = data.aws_vpc.default.id
  
  tags = {
    Name = "*${var.subnet_type}*"
  }
}

data "aws_subnet" "selected" {
  count = length(data.aws_subnet_ids.private.ids)
  id    = tolist(data.aws_subnet_ids.private.ids)[count.index]
}

data "aws_security_group" "default" {
  vpc_id = data.aws_vpc.default.id
  name   = "default"
}
