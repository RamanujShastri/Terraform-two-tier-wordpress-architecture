resource "aws_security_group" "TerraSecGrp"
{
  name        = "Wordpress-Secgrp"
  description = "Allow all inbound traffic"
  vpc_id      = "${aws_vpc.main.id}"
  ingress
  {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress
  {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
 ingress
  {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.20.0.0/16"]
  }

  egress
  {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags
  {
    Name = "CreatedByTerraform"
  }

}

resource "aws_security_group" "ELBSecGrp"
{
  name        = "Wordpresselb-Secgrp"
  description = "Allow  80 traffic"
  vpc_id      = "${aws_vpc.main.id}"
  ingress
  {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress
  {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags
  {
    Name = "WordpressELB-Secgrp"
  }

}

resource "aws_security_group" "DB-Secgroup"
{
  name = "DB-Secgroup"
  description = "for database"
  vpc_id      = "${aws_vpc.main.id}"
  ingress
  {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.20.0.0/16"]
  }
  tags
  {
    Name = "DB-Secgrp"
  }
}

resource "aws_instance" "wordpress"
{
  ami = "ami-8d948ced"
  depends_on = ["aws_security_group.TerraSecGrp","aws_key_pair.wordpress-KP"]
  instance_type = "t2.micro"
  associate_public_ip_address = "true"
  subnet_id = "${aws_subnet.public_subnet.id}"
  vpc_security_group_ids = ["${aws_security_group.TerraSecGrp.id}"]
  key_name = "${aws_key_pair.wordpress-KP.id}"
  tags
  {
    Name = "Wordpress through terrafrom"
    Owner = "Ramanuj Shastri"
    Application = "Wordpress"
    Created = "This instance is created through terraform"
  }
  user_data = "${file("./install.sh")}"

}

resource "aws_key_pair" "wordpress-KP"
  {
    key_name = "wordpress"
    public_key = "${file("${var.ssh_key}")}"

  }

resource "aws_db_subnet_group" "dbsubnet-grp"
{
#  name       = "main"
  subnet_ids = ["${aws_subnet.private_subnet1.id}","${aws_subnet.private_subnet2.id}"]

  tags {
    Name = "My DB subnet group"
  }
}

resource "aws_db_instance" "Wordpress-DB"
{
  depends_on = ["aws_db_subnet_group.dbsubnet-grp"]
  identifier           = "wordpress-db"
  allocated_storage    = 10
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7"
  db_subnet_group_name = "${aws_db_subnet_group.dbsubnet-grp.id}"
  instance_class       = "db.t2.micro"
  name                 = "WordpressDB"
  username             = "wordpress"
  password             = "wordpress"
  parameter_group_name = "default.mysql5.7"
  publicly_accessible = "false"
  vpc_security_group_ids = ["${aws_security_group.DB-Secgroup.id}"]
  skip_final_snapshot = "true"
}

resource "aws_elb" "Wordpress-ELB"
{
  depends_on = ["aws_security_group.ELBSecGrp"]
  name = "wordpress-elb"
  subnets = ["${aws_subnet.public_subnet.id}"]
  security_groups =  ["${aws_security_group.ELBSecGrp.id}"]
  listener
  {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
  health_check {
    healthy_threshold   = 5
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 30
  }
  instances                   = ["${aws_instance.wordpress.id}"]
  cross_zone_load_balancing   = false
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400
  tags {
    Name = "wordpress-elb"
  }
}


