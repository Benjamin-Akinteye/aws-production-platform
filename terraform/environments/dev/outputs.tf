output "vpc_id" {
  description = "ID of the project VPC"
  value       = aws_vpc.main.id
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.main.dns_name
}

output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = aws_lb.main.arn
}

output "app_target_group_arn" {
  description = "ARN of the application target group"
  value       = aws_lb_target_group.app.arn
}

output "autoscaling_group_name" {
  description = "Name of the application Auto Scaling Group"
  value       = aws_autoscaling_group.app.name
}

output "launch_template_id" {
  description = "ID of the application launch template"
  value       = aws_launch_template.app.id
}


output "rds_identifier" {
  description = "Identifier of the RDS database"
  value       = aws_db_instance.main.identifier
}

output "rds_endpoint" {
  description = "Network endpoint of the private RDS database"
  value       = aws_db_instance.main.endpoint
}

output "rds_port" {
  description = "Port used by the RDS database"
  value       = aws_db_instance.main.port
}