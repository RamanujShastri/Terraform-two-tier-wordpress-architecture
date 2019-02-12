output "rds_endpoint"
{
  value = "${aws_db_instance.Wordpress-DB.endpoint}" 
}

output "rds_DBname"
{
  value = "${aws_db_instance.Wordpress-DB.name}"
}

output "rds_username"
{
  value = "${aws_db_instance.Wordpress-DB.username}"
}

output "rds_password"
{
  value = "${aws_db_instance.Wordpress-DB.password}"
}

