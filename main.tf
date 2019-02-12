provider "aws" {
  region = "eu-west-2"
}
variable "privateKey" {
  type = "string"
}

# EC2 instance to build the scanner
resource "aws_instance" "binaries_builder_instance" {
  # Hard coded to Amazon Linux 2018
  ami             = "ami-01419b804382064e4"
  instance_type   = "t2.micro"
  key_name        = "${var.privateKey}"
  security_groups = ["${aws_security_group.ssh_access.name}"]

  tags = {
    Name        = "KittyCat builder"
    Description = "Virus scan binaries builder"
  }

  # Create files and folders on EC2 instance that are needed to build the zip
  provisioner "remote-exec" {
    inline = [
      "mkdir config",
      "mkdir src",
      "mkdir etc",
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = "${file(var.privateKey)}"
    }
  }

  provisioner "file" {
    source      = "./build.sh"
    destination = "~/build.sh"

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = "${file(var.privateKey)}"
    }
  }

  provisioner "file" {
    source      = "./config/local.yaml"
    destination = "~/config/local.yaml"

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = "${file(var.privateKey)}"
    }
  }

  provisioner "file" {
    source      = "./etc/freshclam.conf"
    destination = "~/etc/freshclam.conf"

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = "${file(var.privateKey)}"
    }
  }

  provisioner "file" {
    source      = "./dist/handler.js"
    destination = "~/src/handler.js"

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = "${file(var.privateKey)}"
    }
  }

  provisioner "file" {
    source      = "./dist/update.js"
    destination = "~/src/update.js"

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = "${file(var.privateKey)}"
    }
  }

  # Call a script to build the scanner
  provisioner "remote-exec" {
    inline = [
      "cd ~",
      "sudo chmod 777 build.sh",
      "sudo sh build.sh"
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = "${file(var.privateKey)}"
    }
  }
}

# Allow ssh into and wget out of the instance
resource "aws_security_group" "ssh_access" {
  description = "Allow ssh into and wget out of the instance"

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
