provider "aws" {
  region = "eu-west-2"
}

resource "aws_instance" "binaries_builder_instance" {
  # Hard coded to Amazon Linux 2018
  ami           = "ami-01419b804382064e4"
  instance_type = "t2.micro"
  key_name      = "JonnyKey"

  tags = {
    Name        = "KittyCat builder"
    Description = "Virus scan binaries builder"
  }

  security_groups = ["${aws_security_group.ssh_access.name}"]

    provisioner "file" {
      source      = "./build.sh"
      destination = "~/build.sh"

      connection {
        type        = "ssh"
        user        = "ec2-user"
        private_key = "${file("C:\\Users\\jmwright\\Documents\\Keys\\JonnyKey AWS.pem")}"
      }
    }

    provisioner "remote-exec" {
      inline = [
        "ping -c 2 8.8.8.8",
        "ping -c 2 www.clamav.net",
      ]

      connection {
        type        = "ssh"
        user        = "ec2-user"
        private_key = "${file("C:\\Users\\jmwright\\Documents\\Keys\\JonnyKey AWS.pem")}"
      }
    }
    
    provisioner "remote-exec" {
      inline = [
        "cd ~",
        "sudo chmod 777 build.sh",
        "sudo sh build.sh",
      ]

      connection {
        type        = "ssh"
        user        = "ec2-user"
        private_key = "${file("C:\\Users\\jmwright\\Documents\\Keys\\JonnyKey AWS.pem")}"
      }
    }
}

# Allow ssh into the instance
resource "aws_security_group" "ssh_access" {
  description = "allow remote ssh into ec2 instance"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}
