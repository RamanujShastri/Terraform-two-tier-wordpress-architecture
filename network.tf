

provider "aws" {

  region = "us-west-1"
  shared_credentials_file = "/root/.aws/credentials"

}

resource "aws_vpc" "main"
{
  cidr_block = "${var.vpc_cidr}"
  enable_dns_hostnames = "true"
  tags
  {
    Name = "TerraformVPC"
  }
}

resource "aws_subnet" "private_subnet1"
{
  vpc_id = "${aws_vpc.main.id}"
  cidr_block = "${var.private_subnet1_cidr}"
  availability_zone = "us-west-1a"
  tags
  {
    Name = "private_subnet-1"
  }
}

resource "aws_subnet" "private_subnet2"
{
  vpc_id = "${aws_vpc.main.id}"
  cidr_block = "${var.private_subnet2_cidr}"
  availability_zone = "us-west-1c"
  tags
  {
    Name = "private_subnet-2"
  }
}

resource "aws_subnet" "public_subnet"
{
  vpc_id = "${aws_vpc.main.id}"
  cidr_block = "${var.public_subnet_cidr}"
  availability_zone = "us-west-1a"
  tags
  {
    Name = "public_subnet-1"
  }

}
resource "aws_subnet" "public_subnet2"
{
  vpc_id = "${aws_vpc.main.id}"
  cidr_block = "${var.public_subnet2_cidr}"
  availability_zone = "us-west-1c"
  tags
  {
    Name = "public_subnet-2"
  }

}

resource "aws_internet_gateway" "igw1"
{
  vpc_id = "${aws_vpc.main.id}"
  tags
  {
    Name = "Main"
  }
}

resource "aws_route_table" "rt-main"
{
  vpc_id = "${aws_vpc.main.id}"
  route
  {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw1.id}"

  }
  tags
  {
    Name = "Public MainRT"
  }
}

resource "aws_route_table_association" "rt_association"
{
  subnet_id = "${aws_subnet.public_subnet.id}"
  route_table_id = "${aws_route_table.rt-main.id}"
}

