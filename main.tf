provider "aws" {
  access_key = "AKIAJU7ZLBUAKZRESFBQ"
  secret_key = "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"
  region     = "us-east-2"
}
resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key1"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAsyzOfbdnvOMjHpqPdZPBMhpiz2+INpUjpXbWWRba4U/0sDCfwrmGqGfDif34jCeEmEd7qGpt27z1T31sfDTsyTeppn/flfnkrQUeuAqiAo052KWGrhIRMK5O/J/pOe2rVB1NrC7yVPi9yoGo/xjlvzs4f5l9WghCPEhGQxhuchWm1zPy6RjcVttskYZDXjEr94YHYVt5/GHM7KcDoDTRz6mhjv4KzkdLdoiZbbx0ROEjagYsJbspC3C0UeKuHld9tzGbOvqTTWsyBcqgTZdrDAa2gOZGElzL9C/0Sd+RDmXc4P0D7uMVohRcgWvDERQfkXw1X1WLzcIwfFwtFuZoLw== rsa-key-20180830"
}


data "aws_availability_zones" "all" {}
### Creating EC2 instance
resource "aws_instance" "web" {
  ami               = "${lookup(var.amis,var.region)}"
  count             = "${var.count}"
  key_name               = "${var.key_name}"
  vpc_security_group_ids = ["${aws_security_group.instance.id}"]
  source_dest_check = false
  instance_type = "t2.micro"
tags {
    Name = "${format("web-%03d", count.index + 1)}"
  }
}
### Creating Security Group for EC2
resource "aws_security_group" "instance" {
  name = "terraform-MyTerraform-instance"
  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
## Creating Launch Configuration
resource "aws_launch_configuration" "MyTerraform" {
  image_id               = "${lookup(var.amis,var.region)}"
  instance_type          = "t2.micro"
  security_groups        = ["${aws_security_group.instance.id}"]
  key_name               = "${var.key_name}"
user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World" > index.html
              nohup busybox httpd -f -p 8080 &
              EOF
  lifecycle {
    create_before_destroy = true
  }
}
## Creating AutoScaling Group
resource "aws_autoscaling_group" "MyTerraform" {
  launch_configuration = "${aws_launch_configuration.MyTerraform.id}"
  availability_zones = ["${data.aws_availability_zones.all.names}"]
  min_size = 2
  max_size = 10
  load_balancers = ["${aws_elb.MyTerraform.name}"]
  health_check_type = "ELB"
  tag {
    key = "Name"
    value = "terraform-SG-MyTerraform"
    propagate_at_launch = true
  }
}
## Security Group for ELB
resource "aws_security_group" "elb" {
  name = "terraform-MyTerraform-elb"
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

    # HTTPS access from anywhere
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
   ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_iam_server_certificate" "test_cert" {
  name_prefix      = "example-cert"
  certificate_body = "${file("c:\\test2\\apache2.pem")}"
  private_key      = "${file("c:\\test2\\apachekey.pem")}"

  lifecycle {
    create_before_destroy = true
  }
}





### Creating ELB
resource "aws_elb" "MyTerraform" {
  name = "terraform-SG-MyTerraform"
  security_groups = ["${aws_security_group.elb.id}"]
  availability_zones = ["${data.aws_availability_zones.all.names}"]
  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    interval = 30
    target = "HTTP:8080/"
  }
  
    listener {
    lb_port = 80
    lb_protocol = "http"
    instance_port = "8080"
    instance_protocol = "http"
	
	
  }
  listener {
    lb_port = 443
    lb_protocol = "https"
	ssl_certificate_id = "${aws_iam_server_certificate.test_cert.arn}"
    instance_port = "8080"
    instance_protocol = "http"
	
	
  }

  
  
}

resource "aws_route53_health_check" "child1" {
  fqdn              = "${aws_elb.MyTerraform.dns_name}"
  port              = 443
  type              = "HTTPS"
  resource_path     = "/"
  failure_threshold = "5"
  request_interval  = "30"

  tags = {
    Name = "tf-test-health-check"
  }
}

resource "aws_route53_health_check" "foo" {
  type                   = "CALCULATED"
  child_health_threshold = 1
  child_healthchecks     = ["${aws_route53_health_check.child1.id}"]

  tags = {
    Name = "tf-test-calculated-health-check"
  }
}


output "instance_ids" {
    value = ["${aws_instance.web.*.public_ip}"]
}
output "elb_dns_name" {
  value = "${aws_elb.MyTerraform.dns_name}"
}

