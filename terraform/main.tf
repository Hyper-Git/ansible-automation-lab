# VPC for ansible servers
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name       = "main"
    Managed_by = "Terraform"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "ansible-lab-igw" }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = true

  tags = { Name = "ansible-lab public-subnet" }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "Public Route Table"
  }
}

resource "aws_route" "internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id

}
resource "aws_route_table_association" "public" {
  route_table_id = aws_route_table.public.id
  subnet_id      = aws_subnet.public.id
}

resource "aws_security_group" "server" {
  name        = "ansible-lab-servers"
  description = "Ansible control node and managed hosts"
  vpc_id      = aws_vpc.main.id
}

#SSH from my IP only
resource "aws_vpc_security_group_ingress_rule" "ssh-from-my-ip" {
  security_group_id = aws_security_group.server.id
  cidr_ipv4         = var.my_ip
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"


}

resource "aws_vpc_security_group_ingress_rule" "ssh_internal" {
  security_group_id            = aws_security_group.server.id
  referenced_security_group_id = aws_security_group.server.id
  from_port                    = 22
  to_port                      = 22
  ip_protocol                  = "tcp"

}


resource "aws_vpc_security_group_egress_rule" "all_out" {
  security_group_id = aws_security_group.server.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"

}


data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]


  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-resolute-26.04-amd64-server-*"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

resource "aws_key_pair" "lab" {
  public_key = file(pathexpand("~/.ssh/ansible-lab.pub"))

}

resource "aws_instance" "web-01" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.server.id]
  key_name               = aws_key_pair.lab.key_name

  tags = {
    Name = "ansible-control"
  }
}
