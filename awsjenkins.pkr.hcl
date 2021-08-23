packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

source "amazon-ebs" "ubuntu" {
  ami_name      = "${var.ami_prefix}"
  instance_type = "${var.instance_type}"
  region        = "${var.region}"
  source_ami    = "${var.source_ami}"
  ssh_username  = "${var.ssh_username}"
}

build {
  name = "Jenkins_ami"
  sources = [
    "source.amazon-ebs.ubuntu"
  ]
  provisioner "shell" {
    inline = [
      "echo Installing docker and docker compose",
      "sleep 30",
      "sudo apt-get update",
      "sudo apt-get -y update",
      "sudo apt-get -y install docker.io",
      "sudo curl -L https://github.com/docker/compose/releases/download/1.21.2/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose",
      "sudo chmod +x /usr/local/bin/docker-compose",
      "docker-compose --version",
      "docker --version",
      "sudo chmod 666 /var/run/docker.sock",
      "sudo chown -R ubuntu:ubuntu /opt"
    ]
  }
  provisioner "file" {
    source      = "/home/ayush/packer/automation/aws-packer/docker"
    destination = "/opt"
  }
  provisioner "shell" {
    inline = [
      "cd /opt/docker",
      "sudo docker-compose up -d --build",
      "docker ps -a"
    ]
  }
}
