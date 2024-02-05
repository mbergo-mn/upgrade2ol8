import boto3

def launch_ec2_instance(image_id, instance_type, key_name, security_group_ids, subnet_id, user_data):
    """
    Launch an EC2 instance with the specified configuration.
    """
    ec2 = boto3.resource('ec2')
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
    print(f"Instance {instance[0].id} is now running.")

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
    key_name = "your-key-pair-name"
    security_group_id = "sg-xxxxxxxx"
    subnet_id = "subnet-xxxxxxxx"
    user_data = user_data_script

    launch_ec2_instance(ami_id, instance_type, key_name, security_group_id, subnet_id, user_data)
