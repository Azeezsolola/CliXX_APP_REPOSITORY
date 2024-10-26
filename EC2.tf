#Creating VPC
resource "aws_vpc" "myvpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true

   tags = {
    Name = "STACKVPC"
  }
}

#Creating public Subnet
resource "aws_subnet" "publicsub" {
  vpc_id     = aws_vpc.myvpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "STACKPUB"
  }
}

#Displaying the output of the subnet id
output "pubsubnetid" {
  value = aws_subnet.publicsub.id
}


#Creating public Subnet
resource "aws_subnet" "publicsub2" {
  vpc_id     = aws_vpc.myvpc.id
  cidr_block = "10.0.4.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "STACKPUB2"
  }
}


#Creating private subnet 
resource "aws_subnet" "privatesub" {
  vpc_id     = aws_vpc.myvpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1a"


  tags = {
    Name = "STACKPRIV"
  }
}

output "privatesubnetid" {
  value = aws_subnet.privatesub.id
}


#Creating internet gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.myvpc.id

  tags = {
    Name = "STACK_TGW"
  }
}



#Fetching data about a particaular EIP
data "aws_eips" "example" {
  filter {
    name   = "tag:Name"
    values = ["STACKEIP2"]
  }
}



output "EIP" {
  value = data.aws_eips.example.allocation_ids
}


#Creating NAT gateway
resource "aws_nat_gateway" "NATGATE" {
  allocation_id = data.aws_eips.example.allocation_ids[0]
  subnet_id     = aws_subnet.publicsub.id

  tags = {
    Name = "STACKNATGATEWAY"
  }
  depends_on = [aws_internet_gateway.gw]
}


#Crating route table for public subnet
resource "aws_route_table" "pubroutetable" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

 

  tags = {
    Name = "STACKRT1"
  }
}

output "routetab" {
  value = aws_route_table.pubroutetable.id
}


#Creating private route table for private subnet 
resource "aws_route_table" "privroutetable" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.NATGATE.id
  }

  tags = {
    Name = "STACKRT2"
  }
}


#Assocating route table with public subnet 
resource "aws_route_table_association" "ass" {
  subnet_id      = aws_subnet.publicsub.id
  route_table_id = aws_route_table.pubroutetable.id
}

#Assocating route table with public subnet 2 
resource "aws_route_table_association" "ass4" {
  subnet_id      = aws_subnet.publicsub2.id
  route_table_id = aws_route_table.pubroutetable.id
}

#Associating route table with private subnet 
resource "aws_route_table_association" "ass2" {
  subnet_id      = aws_subnet.privatesub.id
  route_table_id = aws_route_table.privroutetable.id
}


#Creating private subnet 2 becasue Db
resource "aws_subnet" "privatesub2" {
  vpc_id     = aws_vpc.myvpc.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "STACKPRIV2"
  }
}

output "privatesubnetid2" {
  value = aws_subnet.privatesub2.id
}


#Associating route table with private subnet 2
resource "aws_route_table_association" "ass3" {
  subnet_id      = aws_subnet.privatesub2.id
  route_table_id = aws_route_table.privroutetable.id
}






#Creating Key Pair
resource "aws_key_pair" "Stack_KP" {
  key_name   = "stackkp"
  public_key = file(var.PATH_TO_PUBLIC_KEY)
}

#Create Security Group
resource "aws_security_group" "clixx-sg" {
  vpc_id     = aws_vpc.myvpc.id
  name        = "clixx-WebDMZ"
  description = "clixx Security Group For clixx Instance"
}

resource "aws_security_group_rule" "ssh" {
  security_group_id = aws_security_group.clixx-sg.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "msql" {
  security_group_id = aws_security_group.clixx-sg.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 3306
  to_port           = 3306
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "NFSEC2" {
  security_group_id = aws_security_group.clixx-sg.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 2049
  to_port           = 2049
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "NFSEC23" {
  security_group_id = aws_security_group.clixx-sg.id
  type              = "egress"
  protocol          = "tcp"
  from_port         = 2049
  to_port           = 2049
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "http" {
  security_group_id = aws_security_group.clixx-sg.id
  type              = "egress"
  protocol          = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_blocks       = ["0.0.0.0/0"]
}


resource "aws_security_group_rule" "https1" {
  security_group_id = aws_security_group.clixx-sg.id
  type              = "egress"
  protocol          = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_blocks       = ["0.0.0.0/0"]
}




resource "aws_security_group_rule" "https" {
  security_group_id = aws_security_group.clixx-sg.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_blocks       = ["0.0.0.0/0"]
}


resource "aws_security_group_rule" "http2" {
  security_group_id = aws_security_group.clixx-sg.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_blocks       = ["0.0.0.0/0"]
}


resource "aws_security_group_rule" "mysql2" {
  security_group_id = aws_security_group.clixx-sg.id
  type              = "egress"
  protocol          = "tcp"
  from_port         = 3306
  to_port           = 3306
  cidr_blocks       = ["0.0.0.0/0"]
}

#Creating Security group for DB 
resource "aws_security_group" "clixx-sg2" {
  vpc_id     = aws_vpc.myvpc.id
  name        = "clixx-DB"
  description = "clixx Security Group For RDSInstance"
}

resource "aws_security_group_rule" "NFS" {
  security_group_id = aws_security_group.clixx-sg2.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 2049
  to_port           = 2049
  cidr_blocks       = ["10.0.1.0/24"]
}


resource "aws_security_group_rule" "NFS2" {
  security_group_id = aws_security_group.clixx-sg2.id
  type              = "egress"
  protocol          = "tcp"
  from_port         = 2049
  to_port           = 2049
  cidr_blocks       = ["10.0.1.0/24"]
}


resource "aws_security_group_rule" "mysql3" {
  security_group_id = aws_security_group.clixx-sg2.id
  type              = "egress"
  protocol          = "tcp"
  from_port         = 3306
  to_port           = 3306
  cidr_blocks       = ["10.0.1.0/24"]
}


resource "aws_security_group_rule" "mysql4" {
  security_group_id = aws_security_group.clixx-sg2.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 3306
  to_port           = 3306
  cidr_blocks       = ["10.0.1.0/24"]

}



# Create the DB Subnet Group using the retrieved subnet IDs
resource "aws_db_subnet_group" "groupdb" {
  name       = "my-db-subnet-group"
  subnet_ids = [aws_subnet.privatesub2.id,aws_subnet.privatesub.id]

  tags = {
    Name = "My_DB_Subnet_Group"
  }
}

resource "aws_db_instance" "restored_db" {
  identifier          = "wordpressdbclixx-ecs"
  snapshot_identifier = "arn:aws:rds:us-east-1:577701061234:snapshot:wordpressdbclixx-ecs-snapshot"  
  instance_class      = "db.m6gd.large"        
  allocated_storage    = 20                     
  engine             = "mysql"                
  username           = "wordpressuser"
  password           = "W3lcome123"         
  db_subnet_group_name = aws_db_subnet_group.groupdb.name  
  vpc_security_group_ids = [aws_security_group.clixx-sg2.id] 
  skip_final_snapshot     = true
  publicly_accessible  = true
  
  tags = {
    Name = "wordpressdb"
  }
}






# Create EFS File System
resource "aws_efs_file_system" "my_efs" {
  creation_token = "my-efs-token"

  tags = {
    Name = "MyEFS"
    Environment = "Development"
  }
}



# Create EFS Mount Targets
resource "aws_efs_mount_target" "my_efs_mount_target" {
  count            = 2
  file_system_id   = aws_efs_file_system.my_efs.id
  subnet_id        = [aws_subnet.privatesub2.id,aws_subnet.privatesub.id][count.index]
  security_groups  = [aws_security_group.clixx-sg2.id]
}




#Creating laod Balancer which is an internet facing load Balancer. Because of that, I created it in the public subnet 
resource "aws_lb" "test" {
  name               = "autoscalinglb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.clixx-sg.id]
  subnets            = [aws_subnet.publicsub.id,aws_subnet.publicsub2.id]
  enable_deletion_protection = false
  tags = {
    Environment = "Development"
  }
}



# Target Group
resource "aws_lb_target_group" "instance_target_group" {
  name     = "autoscalingtg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.myvpc.id 

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 5
    timeout             = 120
    interval            = 300
    path                = "/" 
    protocol            = "HTTP"
  }

  tags = {
    Environment = "Development"
  }
}


data "aws_acm_certificate" "amazon_issued" {
  domain      = "*.clixx-azeez.com"
  types       = ["AMAZON_ISSUED"]
  most_recent = true
}


output "mycerts" {
  value = data.aws_acm_certificate.amazon_issued.arn
}


# Listener for the Load Balancer
resource "aws_lb_listener" "http" {
  
  load_balancer_arn = aws_lb.test.arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn = data.aws_acm_certificate.amazon_issued.arn

  default_action {
    type = "forward"

    
      target_group_arn = aws_lb_target_group.instance_target_group.arn
    
  }
}

data "template_file" "bootstrap" {
    template = file(format("%s/scripts/bootstrap.tpl", path.module))
    vars = {
    lb_dns = "https://dev2.clixx-azeez.com" ,
    FILE = aws_efs_file_system.my_efs.id,
    MOUNT_POINT="/var/www/html",
    REGION = "us-east-1"
    condition = "if (isset($$\\_SERVER['HTTP_X_FORWARDED_PROTO']) && $$\\_SERVER['HTTP_X_FORWARDED_PROTO'] === 'https') {\\n $$\\_SERVER['HTTPS'] = 'on';\\n}"
  }
  
   
}





# Create a launch template
resource "aws_launch_template" "my_launch_template" {
  name          = "my-launch-template"
  image_id      = var.ami
  instance_type = var.instance_type

  key_name = aws_key_pair.Stack_KP.key_name
  
  user_data  = base64encode(data.template_file.bootstrap.rendered)


  
  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.clixx-sg.id]
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "newinstance"
    }
  }
}


output "launch_template_id" {
  value = aws_launch_template.my_launch_template.id
}




# Create an Auto Scaling group from the launch template
resource "aws_autoscaling_group" "my_asg" {
  depends_on = [ aws_db_instance.restored_db ]
  launch_template {
    id      = aws_launch_template.my_launch_template.id
    version = "$Latest"  
  }

  min_size     = 1
  max_size     = 3
  desired_capacity = 1
  vpc_zone_identifier = [aws_subnet.publicsub.id]

  tag {
    key                 = "Name"
    value               = "MyAutoScalingInstance"
    propagate_at_launch = true
  }

  target_group_arns = [aws_lb_target_group.instance_target_group.arn]
}


output "autoscaling_group_id" {
  value = aws_autoscaling_group.my_asg.id
}





data "aws_route53_zone" "selected" {
  name         = "clixx-azeez.com"
  
}

output "hostedzone" {
  value = data.aws_route53_zone.selected.zone_id

}

resource "aws_route53_record" "my_record" {
  allow_overwrite = true
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "dev2.clixx-azeez.com"
  type    = "CNAME"
  ttl     = 1500
  records = [aws_lb.test.dns_name]
}