#!/bin/bash

# Specify your AWS region
REGION="us-west-2"

# Create VPC and store its ID in a variable
a1_vpc_id=$(aws ec2 create-vpc --cidr-block "172.16.0.0/16" --region "$REGION" --tag-specifications "ResourceType=vpc,Tags=[{Key=Project,Value=a1_project}]" --query "Vpc.VpcId" --output "text")

# Create Subnet and store its ID in a variable
a1_subnet_id=$(aws ec2 create-subnet --cidr-block "172.16.0.0/24" --region "$REGION" --vpc-id "$a1_vpc_id" --tag-specifications "ResourceType=subnet,Tags=[{Key=Project,Value=a1_project}]" --query "Subnet.SubnetId" --output "text")

# Create Internet Gateway and store its ID in a variable
a1_igw_id=$(aws ec2 create-internet-gateway --region "$REGION" --tag-specifications "ResourceType=internet-gateway,Tags=[{Key=Project,Value=a1_project}]" --query "InternetGateway.InternetGatewayId" --output "text")

# Attach Internet Gateway to VPC
aws ec2 attach-internet-gateway --internet-gateway-id "$a1_igw_id" --vpc-id "$a1_vpc_id"

# Create Security Group and store its ID in a variable
a1_sg_id=$(aws ec2 create-security-group --group-name a1_web_sg_1 --description "Assignment 1 security group" --vpc-id "$a1_vpc_id" --query "GroupId" --output "text")

# Authorize Security Group Ingress Rules
aws ec2 authorize-security-group-ingress --group-name "$a1_sg_id" --protocol tcp --port 22 --cidr 66.183.17.224/32 --vpc-id "$a1_vpc_id"
aws ec2 authorize-security-group-ingress --group-name "$a1_sg_id" --protocol tcp --port 80 --cidr 66.183.17.224/33 --vpc-id "$a1_vpc_id"
aws ec2 authorize-security-group-ingress --group-name "$a1_sg_id" --protocol tcp --port 80 --cidr 142.232.0.0/16 --vpc-id "$a1_vpc_id"
aws ec2 authorize-security-group-ingress --group-name "$a1_sg_id" --protocol tcp --port 22 --cidr 142.232.0.0/16 --vpc-id "$a1_vpc_id"
aws ec2 authorize-security-group-ingress --group-name "$a1_sg_id" --protocol tcp --port 80 --cidr 0.0.0.0/0 --vpc-id "$a1_vpc_id"

# Create Route Table and store its ID in a variable
a1_rt_id=$(aws ec2 create-route-table --vpc-id "$a1_vpc_id" --tag-specifications "ResourceType=route-table,Tags=[{Key=Project,Value=a1_project}]" --query "RouteTable.RouteTableId" --output "text")

# Create Default Route in the Route Table
aws ec2 create-route --route-table-id "$a1_rt_id" --destination-cidr-block 0.0.0.0/0 --gateway-id "$a1_igw_id"

# Store resource IDs in a state file
echo "a1_vpc_id=\"$a1_vpc_id\"" > "state_file.txt"
echo "a1_subnet_id=\"$a1_subnet_id\"" >> "state_file.txt"
echo "a1_igw_id=\"$a1_igw_id\"" >> "state_file.txt"
echo "a1_sg_id=\"$a1_sg_id\"" >> "state_file.txt"
echo "a1_rt_id=\"$a1_rt_id\"" >> "state_file.txt"

