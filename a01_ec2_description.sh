#!/bin/bash

source state_file.txt

aws ec2 describe-instances --instance-id "$EC2_ID"