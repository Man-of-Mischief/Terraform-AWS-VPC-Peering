################### output.tf

output "frotend_public_ip" {
        value = aws_instance.frontend.public_ip
}

output "frotend_private_ip" {
        value = aws_instance.frontend.private_ip
}

output "backend_public_ip" {
        value = aws_instance.backend.public_ip
}

output "backend_private_ip" {
        value = aws_instance.backend.private_ip
}

output "bastion_public_ip" {
        value = aws_instance.bastion.public_ip
}

output "bastion_private_ip" {
        value = aws_instance.bastion.private_ip
}
