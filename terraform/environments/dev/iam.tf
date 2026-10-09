
resource "aws_iam_role" "app_ssm" {
  name = "${var.project_name}-app-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-app-ssm-role"
    Tier = "application"
  }
}

resource "aws_iam_role_policy_attachment" "app_ssm" {
  role = aws_iam_role.app_ssm.name

  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "app" {
  name = "${var.project_name}-app-instance-profile"
  role = aws_iam_role.app_ssm.name

  tags = {
    Name = "${var.project_name}-app-instance-profile"
  }
}