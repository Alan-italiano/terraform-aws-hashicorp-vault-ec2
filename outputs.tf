output "ip_vault_1" {
  description = "IP for Vault instance 1"
  value       = "ssh ec2-user@${aws_instance.vault_instance_1.public_ip} -i bastion"
}

output "ip_vault_2" {
  description = "IP for Vault instance 2"
  value       = "ssh ec2-user@${aws_instance.vault_instance_2.public_ip} -i bastion"
}

output "ip_vault_3" {
  description = "IP for Vault instance 3"
  value       = "ssh ec2-user@${aws_instance.vault_instance_3.public_ip} -i bastion"
}

output "kms_vault" {
  description = "KMS ID for Vault Unseal"
  value      = aws_kms_key.vault.key_id
}