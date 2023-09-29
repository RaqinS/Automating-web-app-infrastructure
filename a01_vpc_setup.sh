#!/bin/bash


REGION="us-east-1"
OUTPUT_FILE="a01_vpc_description.sh"
ID_FILE="state_file.txt"

aws ec2 create-vpc --cidr-block "172.16.0.0/16" --region "$REGION" --tag-specifications "ResourceType=vpc,Tags=[{Key=Project,Value=a1_project},{Key=Name,Value=a1_vpc}]" --query "Vpc.VpcId" --output "text" > "$ID_FILE"

VPC_ID=$(head -n 1 "$ID_FILE")

aws ec2 create-subnet --cidr-block "172.16.0.0/24" --region "$REGION" --vpc-id "$VPC_ID" --tag-specifications "ResourceType=subnet,Tags=[{Key=Project,Value=a1_project},{Key=Name,Value=a1_sn_web_1}]" --query "Subnet.SubnetId" --output "text" >> "$ID_FILE"





