data "template_file" "user_data" {
  template = file("${path.module}/start_script.sh.tpl")
  vars = {
    aws_access_key_id = var.credentials["access_key"]
    aws_secret_access_key = var.credentials["secret_key"]
    aws_session_token = var.credentials["token"]
    aws_region = var.aws_region
    secret_name = aws_secretsmanager_secret.db_secret.name
  }
}

resource "aws_key_pair" "guessingAverage_key_pair"{
  key_name = "guessingAverage_key"
  public_key = file(var.credentials["public_key_file"])
}

resource "aws_launch_template" "webserver-lt" {
  name          = "tf-webserver-lt"

  image_id      = "ami-0c7217cdde317cfec"

  instance_type = "t2.micro"

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
    version = "$Latest"
  }
  target_group_arns = [aws_lb_target_group.webserver-tg.arn]

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
      instance_warmup        = 150
    }
  }
  depends_on = [
      aws_db_instance.postgres_instance
    ]
}