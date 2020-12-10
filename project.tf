################################################################
# Provider Configuration
################################################################

provider "aws"  {
  region     = "us-east-1"
  access_key = "AKIA557QHV5OONVVAIQL"
  secret_key = "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"
}

################################################################
# vpc variable declaration
################################################################

variable "vpc" {
        type = map
        default = {
        "name" = "vpc_alb"
	"cidr" = "172.18.0.0/16"
        }
}

################################################################
# vpc creation
################################################################

resource "aws_vpc" "vpc1" {
  cidr_block       = var.vpc.cidr
  instance_tenancy = "default"
  enable_dns_hostnames = true

  tags = {
    Name = var.vpc.name
  }
}

################################################################
# subnet variable declaration
################################################################

variable "subnet" {
        type = map
        default = {
        "name1" = "alb-public1"
	"name2" = "alb-public2"
	"name3" = "alb-public3"
	"name4" = "alb-public4"
	"name5" = "alb-private1"
       	"name6" = "alb-private2"
	"name7" = "alb-private3"
       	"name8" = "alb-private4"
        "cidr1" = "172.18.0.0/19"
	"cidr2" = "172.18.32.0/19"
	"cidr3" = "172.18.64.0/19"
	"cidr4" = "172.18.96.0/19"
	"cidr5" = "172.18.128.0/19"
	"cidr6" = "172.18.160.0/19"
	"cidr7" = "172.18.192.0/19"
	"cidr8" = "172.18.224.0/19"
        "zone1" = "us-east-1a"
	"zone2" = "us-east-1b"
	"zone3" = "us-east-1c"
	"zone4" = "us-east-1d"
	"zone5" = "us-east-1e"
	"zone6" = "us-east-1f"
	}
}

################################################################
# alb public subnet - 1 , 2 and 3 creation
################################################################

resource "aws_subnet" "public1" {
  vpc_id     = aws_vpc.vpc1.id
  cidr_block = var.subnet.cidr1
  availability_zone = var.subnet.zone1
  map_public_ip_on_launch = true

  tags = {
    Name = var.subnet.name1
  }
}


resource "aws_subnet" "public2" {
  vpc_id     = aws_vpc.vpc1.id
  cidr_block = var.subnet.cidr2
  availability_zone = var.subnet.zone2
  map_public_ip_on_launch = true

  tags = {
    Name = var.subnet.name2
  }
}

resource "aws_subnet" "public3" {
  vpc_id     = aws_vpc.vpc1.id
  cidr_block = var.subnet.cidr3
  availability_zone = var.subnet.zone3
  map_public_ip_on_launch = true

  tags = {
    Name = var.subnet.name3
  }
}

################################################################
# alb private subnet - 1 ,2  and 3 creation
################################################################


resource "aws_subnet" "private1" {
  vpc_id     = aws_vpc.vpc1.id
  cidr_block = var.subnet.cidr4
  availability_zone = var.subnet.zone4
  tags = {
    Name = var.subnet.name4
  }
}



resource "aws_subnet" "private2" {
  vpc_id     = aws_vpc.vpc1.id
  cidr_block = var.subnet.cidr5
  availability_zone = var.subnet.zone5
  tags = {
    Name = var.subnet.name5
  }
}

resource "aws_subnet" "private3" {
  vpc_id     = aws_vpc.vpc1.id
  cidr_block = var.subnet.cidr6
  availability_zone = var.subnet.zone6
  tags = {
    Name = var.subnet.name6
  }
}
################################################################
# internet gateway  creation
################################################################

variable "igw" {
	default = "alb1-igw"
	 
}

resource "aws_internet_gateway" "igw1" {
  vpc_id = aws_vpc.vpc1.id

  tags = {
    Name = var.igw
        }
}

################################################################
# route table variable declaration
################################################################

variable "RT" {
        type = map
        default = {
        "cidr" = "0.0.0.0/0"
        "name1" = "public-RT"
	"name2" = "private-RT"
        }
}

################################################################
#public route table  creation
################################################################

resource "aws_route_table" "publicRT1" {
  vpc_id = aws_vpc.vpc1.id

  route {
    cidr_block = var.RT.cidr
    gateway_id = aws_internet_gateway.igw1.id
        }
   tags = {
        Name = var.RT.name1
        }
}

################################################################
# public  route table  association
################################################################

resource "aws_route_table_association" "RT" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.publicRT1.id
}

resource "aws_route_table_association" "RT2" {
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.publicRT1.id
}

resource "aws_route_table_association" "RT3" {
  subnet_id      = aws_subnet.public3.id
  route_table_id = aws_route_table.publicRT1.id
}

################################################################
# eip creation
################################################################

variable "nat_name" {
	default = "alb-eip"
}

resource "aws_eip" "nat" {
  vpc      = true
  tags = {
    Name = var.nat_name
  }
}

################################################################
#nat gateway creation
################################################################

variable "nat_gw1" {
        default = "alb-NAT"
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public1.id

  tags = {
    Name = var.nat_gw1
  }
}

################################################################
#private route table  creation
################################################################

variable "RT2" {
        default = "private-RT"
	}


resource "aws_route_table" "privateRT1" {
  vpc_id = aws_vpc.vpc1.id

  route {
    cidr_block = var.RT.cidr
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = var.RT2
         }
}

###############################################################
#private subnets to route table  association
################################################################

resource "aws_route_table_association" "private1-RT1" {
  subnet_id      = aws_subnet.private1.id
  route_table_id = aws_route_table.privateRT1.id
}


resource "aws_route_table_association" "private2-RT1" {
  subnet_id      = aws_subnet.private2.id
  route_table_id = aws_route_table.privateRT1.id
}

resource "aws_route_table_association" "private3-RT1" {
  subnet_id      = aws_subnet.private3.id
  route_table_id = aws_route_table.privateRT1.id
}

################################################################
#security group for blue
################################################################

variable "sg1" {
        default = "alb-sg"
}


resource "aws_security_group" "sg1" {
  name        = var.sg1
  description = "Allow from all"
  vpc_id      = aws_vpc.vpc1.id


ingress {
    description = "allow from all"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [var.RT.cidr]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.RT.cidr]
  }

  tags = {
    Name = var.sg1
  }
}

################################################################
#keypair
################################################################

variable "key" {
}

resource "aws_key_pair" "key" {
  key_name   = "virginia"
  public_key = var.key
}


#################################################################
# LC variable declaration
##################################################################

variable "lc" {
        type = map
        default = {
        image = "ami-04d29b6f966df1537"
        type = "t2.micro"

}
}

#################################################################
#  Launch Configuration 1
##################################################################

resource "aws_launch_configuration" "lc1" {

  image_id = var.lc.image
  instance_type = var.lc.type
  key_name = aws_key_pair.key.id
  security_groups = [ aws_security_group.sg1.id ]
  user_data = file("setup.sh")

  lifecycle {
    create_before_destroy = true
  }

}


#################################################################
#  Launch Configuration 2
##################################################################

resource "aws_launch_configuration" "lc2" {

  image_id = var.lc.image
  instance_type = var.lc.type
  key_name = aws_key_pair.key.id
  security_groups = [ aws_security_group.sg1.id ]
  user_data = file("setup1.sh")

  lifecycle {
    create_before_destroy = true
  }

}
#################################################################
#  Launch Configuration 3
##################################################################

resource "aws_launch_configuration" "lc3" {

  image_id = var.lc.image
  instance_type = var.lc.type
  key_name = aws_key_pair.key.id
  security_groups = [ aws_security_group.sg1.id ]
  user_data = file("setup2.sh")

  lifecycle {
    create_before_destroy = true
  }

}

#################################################################
#  target group variable declaration
##################################################################


variable "tg" {
        type = map
        default = {
        "name1" = "alb1-tg1"
	"name2" = "alb1-tg2"
	"name3" = "alb1-tg3"
        "port" = "80"
        "protocol" = "HTTP"
        "type" = "instance"
}
}


#################################################################
#  target group 1
##################################################################

resource "aws_lb_target_group" "tg1" {
  name     = var.tg.name1
  port     = var.tg.port
  protocol = var.tg.protocol
  vpc_id   = aws_vpc.vpc1.id
  target_type = var.tg.type

health_check {
    healthy_threshold   = 3
    unhealthy_threshold = 10
    timeout             = 5
    interval            = 10
    path                = "/"
    port                = "80"
  }
}

#################################################################
#  target group 2
##################################################################

resource "aws_lb_target_group" "tg2" {
  name     = var.tg.name2
  port     = var.tg.port
  protocol = var.tg.protocol
  vpc_id   = aws_vpc.vpc1.id
  target_type = var.tg.type

health_check {
    healthy_threshold   = 3
    unhealthy_threshold = 10
    timeout             = 5
    interval            = 10
    path                = "/blog"
    port                = "80"
  }
}

#################################################################
#  target group 2
##################################################################

resource "aws_lb_target_group" "tg3" {
  name     = var.tg.name3
  port     = var.tg.port
  protocol = var.tg.protocol
  vpc_id   = aws_vpc.vpc1.id
  target_type = var.tg.type

health_check {
    healthy_threshold   = 3
    unhealthy_threshold = 10
    timeout             = 5
    interval            = 10
    path                = "/about"
    port                = "80"
  }
}


#################################################################
#  LB variable declaration
##################################################################

variable "lb" {
        type = map
        default = {
	"name1" = "alb1"
	"name2" = "alb2"
	"name3" = "alb3"
	type = "application"
	
}
}

#################################################################
#  LB 1
##################################################################

resource "aws_lb" "alb1" {
  name               = var.lb.name1
  internal           = false
  load_balancer_type = var.lb.type
  security_groups    = [aws_security_group.sg1.id]
  subnets            = [aws_subnet.public1.id, aws_subnet.public2.id, aws_subnet.public3.id]
  ip_address_type    = "ipv4"

}


#################################################################
#  LB Listener
##################################################################

resource "aws_lb_listener" "ls1" {
  load_balancer_arn = aws_lb.alb1.arn
  port              = var.tg.port
  protocol          = var.tg.protocol
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg1.arn
  }
}

#################################################################
#  LB Listener rule 1
##################################################################



resource "aws_lb_listener_rule" "rule1" {
  listener_arn = aws_lb_listener.ls1.arn
 
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg1.arn
  }

  condition {
    path_pattern {
      values = ["/"]
    }
  }
}


#################################################################
#  LB Listener rule 2
##################################################################


resource "aws_lb_listener_rule" "rule2" {
  listener_arn = aws_lb_listener.ls1.arn
 
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg2.arn
  }

  condition {
    path_pattern {
      values = ["/blog"]
    }
  }
}

#################################################################
#  LB Listener rule 2
##################################################################

resource "aws_lb_listener_rule" "rule3" {
  listener_arn = aws_lb_listener.ls1.arn
 
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg3.arn
  }

  condition {
    path_pattern {
      values = ["/about"]
    }
  }
}


##################################################################
# Autoscaling variable declaration
##################################################################

variable "asg" {
        type = map
        default = {
        "name1" = "ALB-ASG1"
	"name2" = "ALB-ASG2"
	"name3" = "ALB-ASG3"
        "min"     = "0"
        "desired" = "0"
        "max"     = "3"
        "period"  = "120"
        "type"    = "EC2"
        "value1"   = "webserver"
	"value2"  = "webserver-blog"
	"value3"  = "webserver-about"
        "name2"   = "Green-ASG"
}
}


##################################################################
# Autoscaling 1
##################################################################

  resource "aws_autoscaling_group" "asg1" {
  name                 = var.asg.name1
  launch_configuration = aws_launch_configuration.lc1.name
  min_size             = var.asg.min
  desired_capacity     = var.asg.desired
  max_size             = var.asg.max
  health_check_grace_period = var.asg.period
  health_check_type         = var.asg.type
  target_group_arns = [aws_lb_target_group.tg1.arn]
  vpc_zone_identifier = [aws_subnet.public1.id, aws_subnet.public2.id, aws_subnet.public3.id]
  tag {
    key = "Name"
    propagate_at_launch = true
    value = var.asg.value1
  }
  lifecycle {
   create_before_destroy = true
  }
}


##################################################################
# Autoscaling 2
##################################################################

  resource "aws_autoscaling_group" "asg2" {
  name                 = var.asg.name2
  launch_configuration = aws_launch_configuration.lc2.name
  min_size             = var.asg.min
  desired_capacity     = var.asg.desired
  max_size             = var.asg.max
  health_check_grace_period = var.asg.period
  health_check_type         = var.asg.type
  target_group_arns = [aws_lb_target_group.tg2.arn]
  vpc_zone_identifier = [aws_subnet.public1.id, aws_subnet.public2.id, aws_subnet.public3.id]
  tag {
    key = "Name"
    propagate_at_launch = true
    value = var.asg.value2
  }
  lifecycle {
   create_before_destroy = true
  }
}


##################################################################
# Autoscaling 3
##################################################################

  resource "aws_autoscaling_group" "asg3" {
  name                 = var.asg.name3
  launch_configuration = aws_launch_configuration.lc3.name
  min_size             = var.asg.min
  desired_capacity     = var.asg.desired
  max_size             = var.asg.max
  health_check_grace_period = var.asg.period
  health_check_type         = var.asg.type
  target_group_arns = [aws_lb_target_group.tg3.arn]
  vpc_zone_identifier = [aws_subnet.public1.id, aws_subnet.public2.id, aws_subnet.public3.id]
  tag {
    key = "Name"
    propagate_at_launch = true
    value = var.asg.value3
  }
  lifecycle {
   create_before_destroy = true
  }
}
