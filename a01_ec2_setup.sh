#!/bin/bash

source state_file.txt

aws ec2 create-key-pair --key-name Assignment1_key --query 'KeyMaterial' --output text > Assignment1_key.pem

EC2_ID=$(aws ec2 run-instances --region "us-west-2" --instance-type t2.micro --image-id ami-04203cad30ceb4a0c --subnet-id $SUBNET_ID --key-name Assignment1_key --security-group-ids $SG_ID --tag-specifications "ResourceType=instance,Tags=[{Key=Project,Value=a1_project},{Key=Name,Value=a1_ec2}]" )