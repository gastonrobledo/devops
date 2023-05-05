
resource "tls_private_key" "access_key_data" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "vm_access_keypair" {
  key_name   = var.key_pair_name
  public_key = tls_private_key.access_key_data.public_key_openssh
  
  provisioner "local-exec"{
    command = "echo '${tls_private_key.access_key_data.private_key_pem}' > ./${var.key_pair_name}.pem"
  }
}

resource "aws_instance" "vm-manager" {
	ami = data.aws_ami.ubuntu-linux-2004.id
	instance_type = var.instance_type
	
	tags = {
		Name = "Manager VM"
	}
    vpc_security_group_ids = [aws_security_group.instance.id]
    key_name = aws_key_pair.vm_access_keypair.key_name
    user_data = "${file("setup.sh")}"
}

resource "aws_security_group" "instance" {
	name = "terraform-tcp-security-group"
 
	ingress {
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
}