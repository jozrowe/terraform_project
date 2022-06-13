#######################################################################
# This Terraform File will create Application Load Balancer
# Which will be as an endpoint for our WordPress deployment
#######################################################################


#######################################################################
# Create an Application Load Balancer Security Group:
#######################################################################

resource "aws_security_group" "alb" {
  name        = "alb_security_group"
  description = "Application Load Balancer Security Group"
  vpc_id      = data.terraform_remote_state.network.outputs.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.env}-ALB-Security-Group"
    Project = "${var.env}-exercise"
  }
}

#######################################################################
# Create an Application Load Balancer:
#######################################################################

resource "aws_alb" "alb" {
  name            = "alb"
  security_groups = ["${aws_security_group.alb.id}"]
  subnets            = [data.terraform_remote_state.network.outputs.public_subnet_1, data.terraform_remote_state.network.outputs.public_subnet_2,]

  tags = {
    Name = "${var.env}-AppLoadBalancer"
    Project = "${var.env}-exercise"
  }
}

#######################################################################
#Create a new target group for the application load balancer. Traffic will be routed to target web server instances on HTTP port 80. 
# We will also define a health check for targets which will expect a "200 OK" response for the login page of our web application:
#######################################################################

resource "aws_alb_target_group" "group" {
  name     = "alb-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.terraform_remote_state.network.outputs.vpc_id
  stickiness {
    type = "lb_cookie"
  }
  # Alter the destination of the health check to be the login page.
  health_check {
    path = "/wp-login.php"
    port = 80
  }
}

#######################################################################
# Create application load balancer listeners which will accept HTTP client connections.
#######################################################################

resource "aws_alb_listener" "listener_http" {
  load_balancer_arn = "${aws_alb.alb.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.group.arn}"
    type             = "forward"
  }
}