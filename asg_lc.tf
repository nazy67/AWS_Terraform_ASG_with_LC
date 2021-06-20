resource "aws_launch_configuration" "webserver_lc" {
  name_prefix   = "${var.env}-webserve-lc-"
  image_id      = data.aws_ami.amznlinux2.image_id
  instance_type = var.instance_type

  lifecycle {
    create_before_destroy = true
  }

  user_data = data.template_file.user_data.rendered
  security_groups = [aws_security_group.webserver_sg.id]
}

resource "aws_autoscaling_group" "webserver_asg" {
  vpc_zone_identifier = data.aws_subnet_ids.default.ids
  desired_capacity   = 1
  max_size           = 2
  min_size           = 1
  force_delete = true
  launch_configuration = aws_launch_configuration.webserver_lc.name

  tag {
    key                 = "Name"
    value               = "${var.env}-webserver"
    propagate_at_launch = true
  }

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
  }
}
resource "aws_security_group" "webserver_sg" {
  name        = "${var.env}-webserve-sg"
  description = "Allow http inbound traffic"

  tags = {
    Name = "${var.env}-webserve-sg"
  }
}
resource "aws_security_group_rule" "http_from_alb" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id        = aws_security_group.webserver_sg.id
}

resource "aws_security_group_rule" "egress_webserver" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.webserver_sg.id
}
