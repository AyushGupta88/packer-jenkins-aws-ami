# Auttomated build AWS ami using Packer

## What is Packer?
Packer is an open source tool for creating identical machine images for multiple platforms from a single source configuration. Packer is lightweight, runs on every major operating system, and is highly performant, creating machine images for multiple platforms in parallel. Packer does not replace configuration management like Chef or Puppet. In fact, when building images, Packer is able to use tools like Chef or Puppet to install software onto the image.

A machine image is a single static unit that contains a pre-configured operating system and installed software which is used to quickly create new running machines. Machine image formats change for each platform. Some examples include AMIs for EC2, VMDK/VMX files for VMware, OVF exports for VirtualBox, etc.

## Installing Packer in Linux(ubuntu)
1. Add hashicorp gpgkey
``` 
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
```
2. Add hashicorp linux repository
``` 
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
```
3. Update and install.
``` 
sudo apt-get update && sudo apt-get install packer 
```

### Note: For other OS follow the link [Install packer-cli](https://learn.hashicorp.com/tutorials/packer/get-started-install-cli)

## How to create aws machine Image using packer

### STEP-1 Create a directory 

``` 
mkdir {Directory_Name} 
```

### STEP-2 Got to the directory and clone the repository
```
cd {~/Directory_Name}
git clone https://github.com/AyushGupta88/packer-jenkins-aws-ami.git
```
### STEP-3 Ensure Packer is Installed

``` 
packer --version
```

You should see the following output. Else first install Packer from above steps.
![image](https://user-images.githubusercontent.com/82572357/130447590-0f0dee3b-1f55-4346-a5f2-55f42016fc96.png)

### STEP-4 Now initialize the packer configuration.

``` 
packer init . 
```

It will install all the required plugins and other settings. Packer will download the plugins defined in the pkr.hcl files. 
In this case, Packer will download the Packer AWS plugin version >=0.0.2.

### STEP-5 Format and validate your Packer template

The packer fmt command updates templates in the current directory for readability and consistency.

Format your template. Packer will print out the names of the files it modified, if any. In this case, your template file was already formatted correctly, so Packer won't return any file names.

``` 
packer fmt . 
```

You can also make sure your configuration is syntactically valid and internally consistent by using the packer validate command.

Validate your template. If Packer detects any invalid configuration, Packer will print out the file name, the error type and line number of the invalid configuration. The example configuration provided above is valid, so Packer will return nothing.

```
packer validate .
```

### STEP-6 Now Build ami

In this step packer will build ami and execute all the steps that we have defined in the configuration file.
``` 
packer build <File_Name>.pkr.hcl 
```

On successful build the following output will be shown on the terminal.
If any error occurs then check the configuration settings.

![image](https://user-images.githubusercontent.com/82572357/130449701-335e463e-ba46-4bd2-89f4-13acbee608f1.png)

## Details about the configuration files

The directory structure should look like the following:- 

![image](https://user-images.githubusercontent.com/82572357/130450115-3c6ba52c-2675-4a44-9185-7a0a8cfa3694.png)

### 1. awsjenkins.pkr.hcl

This file contains all the configurations for the ami. 

### packer block

The packer {} block contains Packer settings, including specifying a required Packer version.
Each plugin block contains a version and source attribute. Packer will use these attributes to download the appropriate plugin(s).

### source block

The source block configures a specific builder plugin, which is then invoked by a build block. Source blocks use builders and communicators to define what kind of virtualization to use, how to launch the image you want to provision, and how to connect to it. Builders and communicators are bundled together and configured side-by-side in a source block. A source can be reused across multiple builds, and you can use multiple sources in a single build. A builder plugin is a component of Packer that is responsible for creating a machine and turning that machine into an image.

A source block has two important labels: a builder type and a name. These two labels together will allow us to uniquely reference sources later on when we define build runs.
Each builder has its own unique set of configuration attributes. The Docker builder starts a Docker container, runs provisioners within this container, then exports the container for reuse or commits the image.

### The build block

The build block defines what Packer should do with the Docker container after it launches.

In the example template, the build block references the Docker image defined by the source block above 
```
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
```
### 2. jenkins_vars.pkr.hcl

In the vars file we have defined all the variables used in the configuration to make the configuration more dynamic.
~~~ 
variable "ami_prefix" {
  type    = string
  default = "jenkins-linux-aws"
}
variable "instance_type" {
  type    = string
  default = "t2.micro"
}
variable "region" {
  type    = string
  default = "us-east-1"
}
variable "source_ami" {
  type    = string
  default = "ami-09e67e426f25ce0d7"
}
variable "ssh_username" {
  type    = string
  default = "ubuntu"
}
~~~
### 3. docker 

In this folder we have all the required files to setup jenkins server over the docker container for the ami.
It contains:-  
A Dockerfile which is used to build the docker container image for jenkins with the customized configurations.
A docker-compose file to deploy the docker container with the jenkins and expose it to the world which can be access by the public Ip of the instance and the port number (9586).
A plugin.txt file which contains all the plugins list to be installed into the docker image for jenkins.

## Thank You.
