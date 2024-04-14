#vpc
resource "aws_vpc" "myvpc" {
  cidr_block = var.cidr
}

#public subnet
resource "aws_subnet" "public" {
  vpc_id = aws_vpc.myvpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true
}

#igw
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.myvpc.id
}

#route table
resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.myvpc.id

  route = {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  
}

#associate rt with subnet
resource "aws_route_table_association" "rta" {
  subnet_id = aws_subnet.public.id
  route_table_id = aws_route_table.rt.id  
}


#security groups
resource "aws_security_group" "sg" {
  name = "web"
  vpc_id = aws_vpc.myvpc.id

  ingress  {
    description = "HTTP to VPC"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Web-sg"
  }
}

resource "aws_key_pair" "keys" {
  key_name = "terraform-project-keys"
  public_key = file(var.pk_path) #your public key path
  
}

#web app
resource "aws_instance" "server" {
  ami = var.ami_serv
  instance_type = var.instance
  key_name = aws_key_pair.keys.key_name
  vpc_security_group_ids = a[aws_security_group.sg.id]
  subnet_id = aws_subnet.public.id

  connection {
    type = "ssh"
    user = var.ssh_user
    private_key = file(var.privk_path)
    host = self.public_ip
  }

  provisioner "file" {
    source = "app.py"
    destination = "/home/ubuntu/app.py"  
  }
    provisioner "remote-exec" {
    inline = [
      "echo 'Hello from the remote instance'",
      "sudo apt update -y",  # Update package lists (for ubuntu)
      "sudo apt-get install -y python3-pip",  # Example package installation
      "cd /home/ubuntu",
      "sudo pip3 install flask",
      "sudo python3 app.py &",
    ]
  }

}
