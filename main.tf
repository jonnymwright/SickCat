provider "aws" {
  region = "eu-west-2"
}
variable "privateKeyLocation" {
  type = "string"
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

    provisioner "remote-exec" {
      inline = [
        "mkdir config",
        "mkdir src",
        "mkdir etc",
      ]

      connection {
        type        = "ssh"
        user        = "ec2-user"
        private_key = "${file(var.privateKeyLocation)}"
      }
    }

    provisioner "file" {
      source      = "./build.sh"
      destination = "~/build.sh"

      connection {
        type        = "ssh"
        user        = "ec2-user"
        private_key = "${file(var.privateKeyLocation)}"
      }
    }

    provisioner "file" {
      source      = "./config/local.yaml"
      destination = "~/config/local.yaml"

      connection {
        type        = "ssh"
        user        = "ec2-user"
        private_key = "${file(var.privateKeyLocation)}"
      }
    }
    
    provisioner "file" {
      source      = "./etc/freshclam.conf"
      destination = "~/etc/freshclam.conf"

      connection {
        type        = "ssh"
        user        = "ec2-user"
        private_key = "${file(var.privateKeyLocation)}"
      }
    }
    
    provisioner "file" {
      source      = "./dist/handler.js"
      destination = "~/src/handler.js"

      connection {
        type        = "ssh"
        user        = "ec2-user"
        private_key = "${file(var.privateKeyLocation)}"
      }
    }
    
    provisioner "file" {
      source      = "./dist/update.js"
      destination = "~/src/update.js"

      connection {
        type        = "ssh"
        user        = "ec2-user"
        private_key = "${file(var.privateKeyLocation)}"
      }
    }
    
    provisioner "remote-exec" {
      inline = [
        "cd ~",
        "sudo chmod 777 build.sh",
        "sudo sh build.sh"
      ]

      connection {
        type        = "ssh"
        user        = "ec2-user"
        private_key = "${file(var.privateKeyLocation)}"
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

# Get the zip that was created
resource "null_resource" "FTP_get_zip" {
  provisioner "local-exec" {
    command = "sftp -i '${var.privateKeyLocation}' -o StrictHostKeyChecking=accept-new ec2-user@${aws_instance.binaries_builder_instance.public_ip}:/home/ec2-user/scan.zip . "
    interpreter = ["PowerShell", "-Command"]
  }
}