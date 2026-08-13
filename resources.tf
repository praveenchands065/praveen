
#creation of vpc
resource "aws_vpc" "main_vpc" {
    cidr_block           = "10.0.0.0/16"
    enable_dns_support   = true
    enable_dns_hostnames = true

    tags = {
        name = "my-vpc"
    }
}

#creation of public subnet 
resource "aws_subnet" "public_subnet" {
    vpc_id                  = aws_vpc.main_vpc.id
    cidr_block              = "10.0.1.0/24"
    map_public_ip_on_launch = true
    availability_zone         = "us-east-1a"

    tags = {
        name = "public-subnet"
    }
}

#creation of private subnet
resource "aws_subnet" "private_subnet" {
    vpc_id                  = aws_vpc.main_vpc.id
    cidr_block              = "10.0.2.0/24"
    availability_zone        = "us-east-1b"

    tags = {
        name = "private-subnet"
    }
}

#creation of internet gateway

resource "aws_internet_gateway" "igw" {
    vpc_id  = aws_vpc.main_vpc.id

    tags = {
        name = "main-igw"
    }

}

#ceration of elastic ip for NAT

resource "aws_eip" "nat_eip" {
    domain     = "vpc"
    depends_on = [aws_internet_gateway.igw]

    tags = {
        name = "nat-eip"
    }
}

#creation of NAT gateway

resource "aws_nat_gateway" "natgw" {
    allocation_id = aws_eip.nat_eip.id
    subnet_id     = aws_subnet.public_subnet.id
    depends_on    = [aws_internet_gateway.igw]

    tags = {
        name = "main-natgw"
    }
}

#creation of public RT

resource "aws_route_table" "public_rt" {
    vpc_id = aws_vpc.main_vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }
    tags = {
        name = "public-rt"
    }
}

#creation of private RT

resource "aws_route_table" "private_rt" {
    vpc_id = aws_vpc.main_vpc.id

    route {
        cidr_block     = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.natgw.id
    }
    tags = {
        name = "private-rt"
    }

}

#RT association

resource "aws_route_table_association" "public_assoc" {
    subnet_id      = aws_subnet.public_subnet.id
    route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "private_assoc"{
    subnet_id      = aws_subnet.private_subnet.id
    route_table_id = aws_route_table.private_rt.id
}

#security grps (public)

resource "aws_security_group" "public_sg" {
    name = "public-sg"
    description = "Allow ssh and HTTP ffrom anywhere"
    vpc_id = aws_vpc.main_vpc.id

    ingress {
        description = "SSH"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks  = ["0.0.0.0/0"]

    }

    ingress {
        description = "HTTP"
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port  = 0
        to_port    = 0
        protocol   = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        name = "public-sg"
    }
}

#private SG (for internal servers)

resource "aws_security_group" "private_sg" {

    name        = "private-sg"
    description = "Allow internal traffic from sg"
    vpc_id      = aws_vpc.main_vpc.id

    ingress {
        description = "Allow internal traffic from public SG"
        from_port       = 0
        to_port         = 65535
        protocol        = "tcp"
        security_groups = [aws_security_group.public_sg.id]
    }

    egress {
        from_port  = 0
        to_port    = 0
        protocol   = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        name = "private-sg"
    }
}

resource "aws_security_group" "lb_sg" {
  name        = "alb-sg"
  description = "Allow HTTP traffic"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "alb-sg"
  }
}


#creation of s3 bucket 

resource "aws_s3_bucket" "example" {
  bucket = "abhisheksterraform2023project"
}

#public ec2 (web server with apache)

resource "aws_instance" "public_ec2" {
    ami = var.ami_id
    instance_type = var.instance_type
    subnet_id = aws_subnet.public_subnet.id

    vpc_security_group_ids = [aws_security_group.public_sg.id]

    user_data = <<-EOF
          #!/bin/bash
          yum update -y
          yum install -y httpd
          systemctl start httpd
          systemctl enable httpd
          echo"<h1>welcome to Terraform EC2 
    web server</h1>" >/var/www/html/index.html
          EOF

          tags = {
            name = "public-ec2-web"
          }

}

#private Ec2 (APP or DB server)

resource "aws_instance" "private_ec2" {
    ami    = var.ami_id_2
    instance_type = var.instance_type_2
    subnet_id = aws_subnet.private_subnet.id
    vpc_security_group_ids = [aws_security_group.private_sg.id]

    tags = {
        name = "private-EC2"
    }

}


#creation ALB (application load balancer

resource "aws_lb" "test" {
  name               = "test-lb-tf"
  internal           = false
  load_balancer_type = "application"

  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = [aws_subnet.public_subnet.id, aws_subnet.private_subnet.id]

  tags = {
    name = "test-lb"
  }
}

#creation of traget group

 resource "aws_lb_target_group" "alb-example" {
  name        = "tf-example-lb-alb-tg"
  port        = 80
  protocol    = "TCP"
  vpc_id      = aws_vpc.main_vpc.id

  health_check {
    path = "/"
    port = "traffic-port"
  }
}

#creation of target group attachment

resource "aws_lb_target_group_attachment" "public_ec2" {
  target_group_arn = aws_lb_target_group.alb-example.arn
  target_id        = aws_instance.public_ec2.id
  port             = 80
}


resource "aws_lb_target_group_attachment" "private_ec2" {
  target_group_arn = aws_lb_target_group.alb-example.arn
  target_id        = aws_instance.private_ec2.id
  port             = 80
}

#creation of listner 

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.test.arn
  port              = "80"
  protocol          = "HTTP"


  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb-example.arn
  }
}


