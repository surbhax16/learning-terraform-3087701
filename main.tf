data "aws_ami" "app_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"]
}

locals {
  tomcat_user_data = <<-EOF
    #!/bin/bash
    dnf update -y
    dnf install -y java-17-amazon-corretto wget

    TOMCAT_VERSION=10.1.28
    cd /opt
    wget https://dlcdn.apache.org/tomcat/tomcat-10/v$${TOMCAT_VERSION}/bin/apache-tomcat-$${TOMCAT_VERSION}.tar.gz
    tar xzf apache-tomcat-$${TOMCAT_VERSION}.tar.gz
    ln -s apache-tomcat-$${TOMCAT_VERSION} tomcat
    chmod +x /opt/tomcat/bin/*.sh
    /opt/tomcat/bin/startup.sh
  EOF
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.app_ami.id
  instance_type = "t3.nano"
  user_data     = local.tomcat_user_data

  tags = {
    Name = "HelloWorld"
  }
}
