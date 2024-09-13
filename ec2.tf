# Create EC2 instances
resource "aws_instance" "vault_instance_1" {
  ami           = var.AMIS[var.REGION]
  instance_type = "t2.micro"
  key_name      = var.PUB_KEY

  subnet_id                   = aws_subnet.public_subnet_1.id
  vpc_security_group_ids      = [aws_security_group.terrafrom_sg.id]
  associate_public_ip_address = true
  private_ip = "10.0.1.10"

  connection {
    type     = "ssh"
    user     = "ec2-user"
    host     = aws_instance.vault_instance_1.public_ip
    private_key = "${file("./key/bastion")}"
  }

  provisioner "file" {
    source      = "./certs/vaultca.crt"
    destination = "/home/ec2-user/vaultca.crt"
  }  

  provisioner "file" {
    source      = "./certs/vaultclient.crt"
    destination = "/home/ec2-user/vaultclient.crt"
  }

  provisioner "file" {
    source      = "./certs/vaultclient.key"
    destination = "/home/ec2-user/vaultclient.key"
  }  

  provisioner "file" {
    source      = "./scripts/vault-install-tls-awskms-auto-join.sh"
    destination = "/home/ec2-user/vault-install-tls-awskms-auto-join.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /home/ec2-user/vault-install-tls-awskms-auto-join.sh",
      "sudo yum install dos2unix -y",
      "sudo dos2unix /home/ec2-user/vault-install-tls-awskms-auto-join.sh",
      "sudo yum install net-tools -y",
      "sudo yum update -y",
      "sudo yum install telnet -y",
      "sudo hostnamectl set-hostname vault01",
      "exit",
    ]
  }

  tags = {
    "Name" : "Vault_01",
    "Servidor" : "Vault"
  }
}

resource "aws_instance" "vault_instance_2" {
  ami           = var.AMIS[var.REGION]
  instance_type = "t2.micro"
  key_name      = var.PUB_KEY

  subnet_id                   = aws_subnet.public_subnet_2.id
  vpc_security_group_ids      = [aws_security_group.terrafrom_sg.id]
  associate_public_ip_address = true
  private_ip = "10.0.2.10"

  connection {
    type     = "ssh"
    user     = "ec2-user"
    host     = aws_instance.vault_instance_2.public_ip
    private_key = "${file("./key/bastion")}"
  }

  provisioner "file" {
    source      = "./certs/vaultca.crt"
    destination = "/home/ec2-user/vaultca.crt"
  }  

  provisioner "file" {
    source      = "./certs/vaultclient.crt"
    destination = "/home/ec2-user/vaultclient.crt"
  }

  provisioner "file" {
    source      = "./certs/vaultclient.key"
    destination = "/home/ec2-user/vaultclient.key"
  }  

  provisioner "file" {
    source      = "./scripts/vault-install-tls-awskms-auto-join.sh"
    destination = "/home/ec2-user/vault-install-tls-awskms-auto-join.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /home/ec2-user/vault-install-tls-awskms-auto-join.sh",
      "sudo yum install dos2unix -y",
      "sudo dos2unix /home/ec2-user/vault-install-tls-awskms-auto-join.sh",
      "sudo yum install net-tools -y",
      "sudo yum update -y",
      "sudo yum install telnet -y",
      "sudo hostnamectl set-hostname vault02",
      "exit",
    ]
  }

  tags = {
    "Name" : "Vault_02",
    "Servidor" : "Vault"
  }
}


resource "aws_instance" "vault_instance_3" {
  ami           = var.AMIS[var.REGION]
  instance_type = "t2.micro"
  key_name      = var.PUB_KEY

  subnet_id                   = aws_subnet.public_subnet_3.id
  vpc_security_group_ids      = [aws_security_group.terrafrom_sg.id]
  associate_public_ip_address = true
  private_ip = "10.0.3.10"

  connection {
    type     = "ssh"
    user     = "ec2-user"
    host     = aws_instance.vault_instance_3.public_ip
    private_key = "${file("./key/bastion")}"
  }

  provisioner "file" {
    source      = "./certs/vaultca.crt"
    destination = "/home/ec2-user/vaultca.crt"
  }  

  provisioner "file" {
    source      = "./certs/vaultclient.crt"
    destination = "/home/ec2-user/vaultclient.crt"
  }

  provisioner "file" {
    source      = "./certs/vaultclient.key"
    destination = "/home/ec2-user/vaultclient.key"
  }  

  provisioner "file" {
    source      = "./scripts/vault-install-tls-awskms-auto-join.sh"
    destination = "/home/ec2-user/vault-install-tls-awskms-auto-join.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /home/ec2-user/vault-install-tls-awskms-auto-join.sh",
      "sudo yum install dos2unix -y",
      "sudo dos2unix /home/ec2-user/vault-install-tls-awskms-auto-join.sh",
      "sudo yum install net-tools -y",
      "sudo yum update -y",
      "sudo yum install telnet -y",
      "sudo hostnamectl set-hostname vault03",
      "exit",
    ]
  }

  tags = {
    "Name" : "Vault_03",
    "Servidor" : "Vault"
  }
}
