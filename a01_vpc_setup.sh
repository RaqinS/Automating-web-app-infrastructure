
REGION="us-west-2"
ID_FILE="state_file.txt"


ADD_TO_STATE_FILE() {                 #Function to add ids as variables to state file
  local VAR="$1"
  local ID="$2" 
  echo "$VAR=$ID" >> "$ID_FILE"
}

truncate -s 0 $ID_FILE

VPC_ID=$(aws ec2 create-vpc --cidr-block "172.16.0.0/16" --region "$REGION" --tag-specifications "ResourceType=vpc,Tags=[{Key=Project,Value=a1_project},{Key=Name,Value=a1_vpc}]" --query "Vpc.VpcId" --output "text")  #Creates VPC and assigns the vpc id to a variable
ADD_TO_STATE_FILE "VPC_ID" "$VPC_ID" #adds vpc id variable to state file"

SUBNET_ID=$(aws ec2 create-subnet --cidr-block "172.16.0.0/24" --region "$REGION" --vpc-id "$VPC_ID" --tag-specifications "ResourceType=subnet,Tags=[{Key=Project,Value=a1_project},{Key=Name,Value=a1_sn_web_1}]" --query "Subnet.SubnetId" --output "text") #creates subnet and assigns subnet id to a variable
ADD_TO_STATE_FILE "SUBNET_ID" "$SUBNET_ID" #adds subnet id variable to state file"


IGW_ID=$(aws ec2 create-internet-gateway --region "$REGION" --tag-specifications "ResourceType=internet-gateway,Tags=[{Key=Project,Value=a1_project},{Key=Name,Value=a1_gw_1}]" --query "InternetGateway.InternetGatewayId" --output "text") #creates internet gateway and assigns subnet id to a variable
ADD_TO_STATE_FILE "IGW_ID" "$IGW_ID" #adds internet gateway id to state file


aws ec2 attach-internet-gateway --internet-gateway-id "$IGW_ID" --vpc-id "$VPC_ID" #attaches internet gateway to vpc


SG_ID=$(aws ec2 create-security-group --group-name a1_web_sg_1 --description "Assignment 1 security group" --vpc-id "$VPC_ID" --query "GroupId" --output "text" --tag-specifications "ResourceType=security-group,Tags=[{Key=Project,Value=a1_project}]") #creates security group
ADD_TO_STATE_FILE "SG_ID" "$SG_ID" #adds security group id to state file


aws ec2 authorize-security-group-ingress --group-id "$SG_ID" --protocol tcp --port 22 --cidr 66.183.17.224/32 #allows ssh access from home
aws ec2 authorize-security-group-ingress --group-id "$SG_ID" --protocol tcp --port 80 --cidr 66.183.17.224/32 #allows http access from home
aws ec2 authorize-security-group-ingress --group-id "$SG_ID" --protocol tcp --port 80 --cidr 142.232.0.0/16 #allows http access from bcit
aws ec2 authorize-security-group-ingress --group-id "$SG_ID" --protocol tcp --port 22 --cidr 142.232.0.0/16 #alows ssh access from bcit
aws ec2 authorize-security-group-ingress --group-id "$SG_ID" --protocol tcp --port 80 --cidr 0.0.0.0/0 #allows http access from all ips


RT_ID=$(aws ec2 create-route-table --vpc-id "$VPC_ID" --tag-specifications "ResourceType=route-table,Tags=[{Key=Project,Value=a1_project},{Key=Name,Value=a1_web_rt_1}]" --query "RouteTable.RouteTableId" --output "text") #creates route table
ADD_TO_STATE_FILE "RT_ID" "$RT_ID"


aws ec2 create-route --route-table-id "$RT_ID" --destination-cidr-block 0.0.0.0/0 --gateway-id "$IGW_ID" #assigns defualt route to route table


