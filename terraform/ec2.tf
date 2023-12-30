data "template_file" "user_data" {
  template = file("${path.module}/user_data_files/start_script.sh.tpl")
  vars = {
    aws_region = var.aws_region
    secret_name = aws_secretsmanager_secret.db_secret.name
  }
}

data "aws_iam_instance_profile" "vocareum_lab_instance_profile" {
  name = "LabInstanceProfile"
}

resource "aws_key_pair" "guessingAverage_key_pair"{
  key_name = "guessingAverage_key"
#  public_key = file(var.credentials["public_key_file"])
  public_key = var.aws_credentials["aws_ec2_public_key"]
}

resource "aws_launch_template" "webserver-lt" {
  name          = "tf-webserver-lt"

  image_id      = "ami-0c7217cdde317cfec"

  instance_type = "t2.micro"

  iam_instance_profile {
    name = data.aws_iam_instance_profile.vocareum_lab_instance_profile.name
  }

  vpc_security_group_ids = [aws_security_group.webserver_w_lb.id]
  key_name = aws_key_pair.guessingAverage_key_pair.key_name
  user_data = base64encode(data.template_file.user_data.rendered)
}

resource "aws_autoscaling_group" "webserver-asg" {
  name                 = "tf-webserver-asg"
  desired_capacity     = 3
  max_size             = 3
  min_size             = 1
  vpc_zone_identifier  = [for i in range(var.num_public_subnets) : aws_subnet.public_subnet[i].id]
  default_cooldown = 150


  launch_template {
    id      = aws_launch_template.webserver-lt.id
#    version = "$Latest"
    version = aws_launch_template.webserver-lt.latest_version
  }
  target_group_arns = [aws_lb_target_group.webserver-tg.arn]

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 30
      instance_warmup        = 150
    }
  }
  depends_on = [
      aws_db_instance.postgres_instance
    ]
}

resource "aws_autoscaling_policy" "scale_up" {
  name                   = "scale_up"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.webserver-asg.name
}

resource "aws_autoscaling_policy" "scale_down" {
  name                   = "scale_down"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.webserver-asg.name
}

resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "high-cpu-usage"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 75
  alarm_actions       = [aws_autoscaling_policy.scale_up.arn]
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.webserver-asg.name
  }
  treat_missing_data = "ignore"
}

resource "aws_cloudwatch_metric_alarm" "low_cpu" {
  alarm_name          = "low-cpu-usage"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 25
  alarm_actions       = [aws_autoscaling_policy.scale_down.arn]
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.webserver-asg.name
  }
  treat_missing_data = "ignore"
}