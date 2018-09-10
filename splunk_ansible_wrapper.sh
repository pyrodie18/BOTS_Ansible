#!/bin/bash

#Get the API Key
read -p "Enter your api key:  " API_KEY
export AWS_ACCESS_KEY_ID=$API_KEY

#Get the API Secret Key
read -p "Enter your secret key:  " SECRET_KEY
export AWS_SECRET_ACCESS_KEY=$SECRET_KEY

#Select Region
printf "What region would you like this instance to run in?\n"
printf "1.  Virgina\n"
printf "2.  Ohio\n"
printf "3.  Oregon\n"
printf "4.  Califonia\n"
printf "5.  London\n"
read -p "Selection:  " REGION

#Validate Region
if [ $REGION -eq 1 ]; then
	AWS_REGION="us-east-1"
elif [ $REGION -eq 2 ]; then
	AWS_REGION="us-east-2"
elif [ $REGION -eq 3 ]; then
	AWS_REGION="us-west-2"
elif [ $REGION -eq 4 ]; then
	AWS_REGION="us-west-1"
elif [ $REGION -eq 5 ]; then
	AWS_REGION="eu-west-1"
else
	echo "Invalid Selection"
	exit 1
fi

#Select Instance Size
printf "What size instance would you like to run?\n"
printf "1.  t2.micro (1 vCPU 1GB)\n"
printf "2.  t2.small (1 vCPU 2GB)\n"
printf "3.  t2.medium (2 vCPU 4GB)\n"
printf "4.  t2.large (2 vCPU 8GB)\n"
printf "5.  t2.xlarge (4 vCPU 16GB)\n"
printf "6.  t2.2xlarge (8 vCPU 32GB)\n"
read -p "Selection:  " INSTANCE_TYPE

#Validate Instance Size
if [ $INSTANCE_TYPE -eq 1 ]; then
	AWS_INSTANCE_TYPE="t2.micro"
elif [ $INSTANCE_TYPE -eq 2 ]; then
	AWS_INSTANCE_TYPE="t2.small"
elif [ $INSTANCE_TYPE -eq 3 ]; then
	AWS_INSTANCE_TYPE="t2.medium"
elif [ $INSTANCE_TYPE -eq 4 ]; then
	AWS_INSTANCE_TYPE="t2.large"
elif [ $INSTANCE_TYPE -eq 5 ]; then
	AWS_INSTANCE_TYPE="t2.xlarge"
elif [ $INSTANCE_TYPE -eq 6 ]; then
	AWS_INSTANCE_TYPE="t2.2xlarge"
else
	echo "Invalid Selection"
	exit 1
fi

#Set Key Policy Name
read -p "Enter the name of your key pair:  " KEY_PAIR

#Set Admin Password
read -p "Enter the Splunk Admin password (Press Enter for a Random Password):  " PASSWORD
if [ -z $PASSWORD ]; then
	PASSWORD=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9!@#$' | fold -w 15 | head -n 1)
elif [ $(echo $PASSWORD | wc -c) -lt 8 ]; then
	echo "Invalid password"
	exit 1
else
	read -p "Please reenter the Splunk Admin password:  " CONF_PASSWORD
	if [ $PASSWORD != $CONF_PASSWORD ]; then
		echo "Passwords don't match"
		exit 1
	fi
fi

#Generate Cabanboy password
CABANABOYPASSWORD=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9!@#$' | fold -w 15 | head -n 1)
VKEY=$(cat /dev/urandom | tr -dc '0-9' | fold -w 10 | head -n 1)

#Get Points Deductions
read -p "Enter how many points to deduct on an incorrect answer:  " PENALTY

#Set Speed Bonus
echo "Would you like to enable a speed bonus?\n"
echo "0.  No"
echo "1.  Yes"
read -p "Speed Bonus?  " SPEED 

export ANSIBLE_HOST_KEY_CHECKING=False

ANSIBLE_ENABLE_TASK_DEBUGGER=True ansible-playbook -i ./hosts --extra-vars "instance_type=$AWS_INSTANCE_TYPE keypair=$KEY_PAIR region=$AWS_REGION" aws_build.yml

read -p "continue" STUFF

ANSIBLE_ENABLE_TASK_DEBUGGER=True ansible-playbook -i ./hosts --extra-vars "cboypassword=$CABANABOYPASSWORD vkey=$VKEY penalty=$PENALTY speed_bonus=$SPEED adminpassword=$PASSWORD" splunk_build.yml

echo "Install Complete\n"
echo "Your Splunk admin password is $PASSWORD"
