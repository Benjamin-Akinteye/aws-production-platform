resource "aws_launch_template" "app" {
  name = "${var.project_name}-app"

  image_id = data.aws_ssm_parameter.amazon_linux_2023.value

  instance_type = "t3.micro"

  vpc_security_group_ids = [
    aws_security_group.app.id
  ]

  user_data = base64encode(
    file("${path.root}/../../../scripts/app-user-data.sh")
  )

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = 8
      volume_type           = "gp3"
      encrypted             = true
      delete_on_termination = true
    }
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "${var.project_name}-app"
      Tier = "application"
    }
  }

  tags = {
    Name = "${var.project_name}-app-launch-template"
    Tier = "application"
  }
}

resource "aws_autoscaling_group" "app" {
  name = "${var.project_name}-app-asg"

  min_size         = 2
  max_size         = 2
  desired_capacity = 2

  vpc_zone_identifier = aws_subnet.app[*].id

  target_group_arns = [
    aws_lb_target_group.app.arn
  ]

  health_check_type         = "ELB"
  health_check_grace_period = 120

  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }

  instance_refresh {
    strategy = "Rolling"

    preferences {
      min_healthy_percentage = 50
      instance_warmup        = 120
    }
  }

  tag {
    key                 = "Name"
    value               = "${var.project_name}-app"
    propagate_at_launch = true
  }

  tag {
    key                 = "Tier"
    value               = "application"
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = var.environment
    propagate_at_launch = true
  }
}



