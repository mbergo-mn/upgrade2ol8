# Automated Oracle Linux 8 EC2 Instance Creation

This Python script automates the launch of an Oracle Linux 8 EC2 instance on AWS, using a predefined user data script for initial setup and configuration.

## Prerequisites

- Python 3.x
- Boto3 Python library
- AWS CLI configured with user credentials
- Necessary IAM permissions for EC2, Security Groups, and IAM roles

## Setup

1. Ensure Python 3.x is installed on your system.
2. Install Boto3 using pip:

    ```
    pip install boto3
    ```

3. Configure your AWS CLI with credentials and a default region:

    ```
    aws configure
    ```

## Usage

1. Modify `upgrade=CentOS7-2-EL8.py` with the appropriate configuration:
    - AMI ID for Oracle Linux 8 (specific to your region)
    - Desired instance type
    - Key pair name for SSH access
    - Security group ID
    - Subnet ID
    - Any additional user data script adjustments

2. Run the script:

    ```
    python upgrade=CentOS7-2-EL8.py
    ```

## Notes

- The provided user data script updates the system and installs basic utilities. Customize this script based on your requirements.
- Check the AWS Management Console to verify the instance status and obtain its public IP address for SSH access.
