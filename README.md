# VPCs-Interconnection-with-Peering-Connection

This repository contains Terraform code to create two VPCs in different regions in AWS and peer them using a VPC peering connection.

# Terraform AWS VPC Peering

This Terraform code creates two VPCs in different regions in AWS and peers them using a VPC peering connection.

# Prerequisites

Before you can use this code, you need to:

Have an AWS account.
Install Terraform.
Configure your AWS access keys.

# Usage

Clone this repository to your local machine.
Navigate to the terraform directory.

Initialize the Terraform working directory by running the following command:

terraform init

Modify the variables.tf file to customize the VPCs' settings as per your requirement.
Modify the provider.tf file to specify your AWS region and credentials.

Run the following command to create the VPC resources:

terraform apply


Once the resources are created, the Terraform output will display the VPC peering connection details.
Navigate to the AWS VPC console to verify the VPC peering connection has been successfully created.

To destroy the resources, run the following command:

terraform destroy

# Resources Created

The Terraform code creates the following AWS resources:

Two VPCs in different regions.
Two public subnets in each VPC.
Two private subnets in each VPC.
Internet Gateway in each VPC.
NAT Gateway in each public subnet.
EC2 instances in each private subnet for testing connectivity.
VPC peering connection between the two VPCs.

# Conclusion

That's it! You have successfully created two VPCs in different regions in AWS and peered them using a VPC peering connection. Feel free to modify the Terraform code as per your requirement and contribute to this repository.
