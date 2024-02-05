import boto3
from botocore.exceptions import ClientError

def launch_ec2_instance(image_id, instance_type, key_name, security_group_ids, subnet_id, user_data):
    """
    Launch an EC2 instance with the specified configuration.

    :param image_id: str. AMI ID for the instance.
    :param instance_type: str. EC2 instance type.
    :param key_name: str. Name of the SSH key pair.
    :param security_group_ids: str. Security group ID.
    :param subnet_id: str. Subnet ID for the instance.
    :param user_data: str. User data script for initial setup.
    """
    ec2 = boto3.resource('ec2')

    try:
        instance = ec2.create_instances(
            ImageId=image_id,
            MinCount=1,
            MaxCount=1,
            InstanceType=instance_type,
            KeyName=key_name,
            SecurityGroupIds=[security_group_ids],
            SubnetId=subnet_id,
            UserData=user_data,
            TagSpecifications=[{
                'ResourceType': 'instance',
                'Tags': [
                    {'Key': 'Name', 'Value': 'OracleLinux8-Instance'}
                ]
            }]
        )
        print(f"Instance {instance[0].id} launched, waiting for it to become running...")
        instance[0].wait_until_running()
        instance[0].reload()
        print(f"Instance {instance[0].id} is now running. Public IP: {instance[0].public_ip_address}")
    except ClientError as e:
        print(f"An error occurred: {e}")

if __name__ == "__main__":
    # User data script for initial setup
    user_data_script = """#!/bin/bash
yum update -y
yum install -y nano wget curl
timedatectl set-timezone America/New_York
# Add more setup commands here
"""

    # Configuration: replace these values
    ami_id = "ami-xxxxxxxxxxxxxxxxx"  # Replace with the Oracle Linux 8 AMI ID 
    instance_type = "t2.micro"
    key_name = "your-key-pair-name"  # Ensure this key pair exists
    security_group_id = "sg-xxxxxxxx"  # Ensure this security group exists 
    subnet_id = "subnet-xxxxxxxx"  # Ensure this subnet ID is correct
    user_data = user_data_script

    launch_ec2_instance(ami_id, instance_type, key_name, security_group_id, subnet_id, user_data)
