source state_file.txt

aws ec2 describe-vpcs --vpc-id "$VPC_ID"
aws ec2 describe-subnets --subnet-id "$SUBNET_ID"
aws ec2 describe-internet-gateways --internet-gateway-id "$IGW_ID"
aws ec2 describe-security-groups --group-id "$SG_ID"
aws ec2 describe-route-tables --route-table-id "$RT_ID"

