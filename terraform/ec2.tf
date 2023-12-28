data "template_file" "user_data" {
  template = file("${path.module}/start_script.sh.tpl")
  vars = {
    db_host = aws_db_instance.postgres_instance.address
    db_password = var.credentials["db_password"]
  }
}

resource "aws_key_pair" "guessingAverage_key_pair"{
  key_name = "guessingAverage_key"
    public_key = var.credentials["public_key"]
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

  launch_template {
    id      = aws_launch_template.webserver-lt.id
    version = "$Latest"
  }
  target_group_arns = [aws_lb_target_group.webserver-tg.arn]

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
  }
}