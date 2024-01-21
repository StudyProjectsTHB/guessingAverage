data "template_file" "ami_user_data" {
  template = file("${path.module}/user_data_files/start_script_ami.sh.tpl")
  vars = {
    docker_repository = var.docker_credentials["docker_repository"]
  }
}

data "template_file" "launch_template_user_data" {
  template = file("${path.module}/user_data_files/start_script_launch_template.sh.tpl")
  vars = {
    aws_region = var.aws_region
    secret_name = aws_secretsmanager_secret.db_secret.name
    docker_repository = var.docker_credentials["docker_repository"]
  }
}

data "aws_iam_instance_profile" "vocareum_lab_instance_profile" {
  name = "LabInstanceProfile"
}

resource "aws_key_pair" "guessingAverage_key_pair"{
  key_name = "guessingAverage_key"
  public_key = var.aws_credentials["aws_ec2_public_key"]
}

resource "aws_launch_template" "webserver-lt" {
  name          = "tf-webserver-lt"

  image_id      = data.aws_ami.webserver_ami.id

  instance_type = "t2.micro"

  iam_instance_profile {
    name = data.aws_iam_instance_profile.vocareum_lab_instance_profile.name
  }

  vpc_security_group_ids = [aws_security_group.webserver_w_lb.id]
  key_name = aws_key_pair.guessingAverage_key_pair.key_name
  user_data = base64encode(data.template_file.launch_template_user_data.rendered)
}

resource "aws_autoscaling_group" "webserver-asg" {
  name                 = "tf-webserver-asg"
#  desired_capacity     = 3
  max_size             = 5
  min_size             = 1
  vpc_zone_identifier  = [for i in range(var.num_public_subnets) : aws_subnet.public_subnet[i].id]
  default_cooldown = 150


  launch_template {
    id      = aws_launch_template.webserver-lt.id
    version = aws_launch_template.webserver-lt.latest_version
#    version = "$Latest"
  }
  target_group_arns = [aws_lb_target_group.webserver-tg.arn]

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 100
      max_healthy_percentage = 200
      instance_warmup        = 60
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

resource "aws_instance" "ec2_instance_for_ami" {
  ami           = "ami-0c7217cdde317cfec"
  instance_type = "t2.micro"
  key_name = aws_key_pair.guessingAverage_key_pair.key_name
  user_data = base64encode(data.template_file.ami_user_data.rendered)
  iam_instance_profile = data.aws_iam_instance_profile.vocareum_lab_instance_profile.name
  vpc_security_group_ids = [aws_security_group.webserver_w_lb.id]
  subnet_id = aws_subnet.public_subnet[0].id

  tags = {
    Name = "webserver-ami"
  }


}

resource "null_resource" "delay_for_ami" {
  depends_on = [aws_instance.ec2_instance_for_ami]
  provisioner "local-exec" {
    command = var.operating_system == "windows" ? "powershell Start-Sleep -Seconds 300" : "sleep 300"

  }
}

resource "aws_ami_from_instance" "instance_ami" {
  depends_on = [null_resource.delay_for_ami]
  name                = "webserver-ami"
  source_instance_id  = aws_instance.ec2_instance_for_ami.id
  tags = {
    "guessingAverage" = "webserver-ami"
    "created_by"      = "terraform"
  }

}



data "aws_ami" "webserver_ami" {
  most_recent = true
  owners = ["self"]
  filter {
    name = "tag:guessingAverage"
    values = ["webserver-ami"]
  }
  depends_on = [
    aws_ami_from_instance.instance_ami
  ]
}
