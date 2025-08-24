resource "aws_security_group" "ec2_sg" {
  name        = "${var.name_prefix}-sg"
  vpc_id      = var.vpc_id
  description = "Allow traffic from ALB only"

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [var.alb_sg_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_launch_template" "nginx_lt" {
  name_prefix            = "${var.name_prefix}-template"
  image_id               = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  user_data = base64encode(<<-EOF
    #!/bin/bash
    # Update system
    yum update -y

    # Install Docker
    amazon-linux-extras enable docker
    yum install -y docker
    systemctl enable docker
    systemctl start docker

    # Pull your Docker image
    docker pull srinivasarao2468/nginx-phrase:latest

    # Run container in detached mode
    docker run -d -p 80:80 --name nginx-phrase srinivasarao2468/nginx-phrase:latest
  EOF
  )
}


resource "aws_autoscaling_group" "nginx_asg" {
  name                      = "${var.name_prefix}-asg"
  desired_capacity          = var.instance_count
  max_size                  = var.max_instance_count
  min_size                  = var.min_instance_count
  vpc_zone_identifier       = var.private_subnets
  health_check_type         = "ELB"
  health_check_grace_period = 300
  #target_group_arns   = [aws_lb_target_group.tg.arn]
  default_cooldown = 300

  launch_template {
    id      = aws_launch_template.nginx_lt.id
    version = "$Latest"
  }

  # Rolling update when LT changes
  instance_refresh {
    strategy = "Rolling"

    preferences {
      min_healthy_percentage = 50
    }

  }

  tag {
    key                 = "Name"
    value               = "nginx-instance"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_lb_target_group" "tg" {
  name     = "${var.name_prefix}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/phrase"
    protocol            = "HTTP"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200"
  }
}

resource "aws_autoscaling_attachment" "asg_attach" {
  autoscaling_group_name = aws_autoscaling_group.nginx_asg.name
  lb_target_group_arn    = aws_lb_target_group.tg.arn
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}