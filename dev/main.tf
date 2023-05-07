####### main.tf ########

########### VPC creation

resource "aws_vpc" "main" {
  cidr_block           = var.vpcidr
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project}-vpc-${var.env}"
  }
}


############## creating public subnet 1

resource "aws_subnet" "pub1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpcidr, 3, 0)
  availability_zone       = "${var.az}a"
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.project}-pub1-${var.env}"
  }
}

############## creating public subnet 2

resource "aws_subnet" "pub2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpcidr, 3, 1)
  availability_zone       = "${var.az}b"
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.project}-pub2-${var.env}"
  }
}

############## creating public subnet 3

resource "aws_subnet" "pub3" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpcidr, 3, 2)
  availability_zone       = "${var.az}c"
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.project}-pub3-${var.env}"
  }
}


############## IGW for public subnets

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project}-igw-${var.env}"
  }
}


######### elastic ip for Nat gateway

resource "aws_eip" "eip" {
  vpc = true
  tags = {
    Name = "${var.project}-eip-${var.env}"
  }
}


########### Nat gw for private subnet

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.pub1.id

  tags = {
    Name = "${var.project}-nat-${var.env}"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.


  depends_on = [aws_internet_gateway.igw]
}

############## creating private subnet 1

resource "aws_subnet" "pri1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpcidr, 3, 3)
  availability_zone       = "${var.az}a"
  map_public_ip_on_launch = false
  tags = {
    Name = "${var.project}-pri1-${var.env}"
  }
}

############## creating private subnet 2

resource "aws_subnet" "pri2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpcidr, 3, 4)
  availability_zone       = "${var.az}b"
  map_public_ip_on_launch = false
  tags = {
    Name = "${var.project}-pri2-${var.env}"
  }
}

############## creating private subnet 3

resource "aws_subnet" "pri3" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpcidr, 3, 5)
  availability_zone       = "${var.az}c"
  map_public_ip_on_launch = false
  tags = {
    Name = "${var.project}-pri3-${var.env}"
  }
}

############ Route table creation for public subnets


resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.project}-public_rt-${var.env}"
  }
}

############ Route table creation for private subnets

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  route {
        cidr_block = "10.1.0.0/16"
        vpc_peering_connection_id = "pcx-015867611bb342ddb"
  }


  tags = {
    Name = "${var.project}-private_rt-${var.env}"
  }
}

######### Route table association for public subnets

resource "aws_route_table_association" "pub1" {
  subnet_id      = aws_subnet.pub1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "pub2" {
  subnet_id      = aws_subnet.pub2.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "pub3" {
  subnet_id      = aws_subnet.pub3.id
  route_table_id = aws_route_table.public_rt.id
}

######### Route table association for private subnets

resource "aws_route_table_association" "pri1" {
  subnet_id      = aws_subnet.pri1.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "pri2" {
  subnet_id      = aws_subnet.pri2.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "pri3" {
  subnet_id      = aws_subnet.pri3.id
  route_table_id = aws_route_table.private_rt.id
}


################# SG for bastion

resource "aws_security_group" "bastion" {
  name_prefix = "${var.project}-${var.env}-bastion-"
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description      = "SSH from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${var.project}-${var.env}-bastion"
  }
}


################# SG for frontend

resource "aws_security_group" "frontend" {
  name_prefix = "${var.project}-${var.env}-frontend-"
  description = "Allow HTTP, HTTPS and SSH from bastion"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "SSH from VPC"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]
  }

  ingress {
    description      = "HTTP from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }


  ingress {
    description      = "HTTPS from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${var.project}-${var.env}-frontend"
  }
}


################# SG for backend

resource "aws_security_group" "backend" {
  name_prefix = "${var.project}-${var.env}-backend-"
  description = "Allow HTTP, HTTPS and SSH from bastion"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "SSH from VPC"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]
  }

  ingress {
    description     = "SSH from prod VPC"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    cidr_blocks     = ["10.1.32.0/19"]

  }


  ingress {
    description     = "SQL from VPC"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.frontend.id]
  }

  ingress {
    description      = "HTTP from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }


  ingress {
    description      = "HTTPS from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${var.project}-${var.env}-backend"
  }
}


################# KEYPAIR CREATION ####################

resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "mykey" {

  key_name   = "key-${var.project}-zomatodev-${var.env}"
  public_key = tls_private_key.rsa.public_key_openssh
  tags = {
    "Name" = "key-${var.project}-zomatodev-${var.env}",
  }

}
resource "local_file" "tf-key" {
  content  = tls_private_key.rsa.private_key_pem
  filename = "key-${var.project}-zomatodev-${var.env}.pem"
}


################### EC2 Creation ######################

######## frontend

resource "aws_instance" "frontend" {
  ami                    = var.ami
  instance_type          = var.type
  availability_zone      = "${var.az}a"
  key_name               = aws_key_pair.mykey.key_name
  vpc_security_group_ids = [aws_security_group.frontend.id]
  subnet_id              = aws_subnet.pub1.id
  user_data              = file("frontend.sh")
  tags = {
    "Name" = "${var.project}-frontend-${var.env}"
  }
}

######## backend

resource "aws_instance" "backend" {
  ami           = var.ami
  instance_type = var.type

  key_name               = aws_key_pair.mykey.key_name
  vpc_security_group_ids = [aws_security_group.backend.id]
  subnet_id              = aws_subnet.pri1.id
  user_data              = file("backend.sh")
  tags = {
    "Name" = "${var.project}-backend-${var.env}"
  }
}

######## bastion

resource "aws_instance" "bastion" {
  ami                    = var.ami
  instance_type          = var.type
  key_name               = aws_key_pair.mykey.key_name
  vpc_security_group_ids = [aws_security_group.bastion.id]
  subnet_id              = aws_subnet.pub2.id
  tags = {
    "Name" = "${var.project}-bastion-${var.env}"
  }
}
