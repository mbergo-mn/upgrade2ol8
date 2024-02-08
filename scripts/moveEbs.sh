#!/bin/bash

# Function to stop an EC2 instance
stop_instance() {
    echo "Stopping instance: $1"
    aws ec2 stop-instances --instance-ids $1
    aws ec2 wait instance-stopped --instance-ids $1
    echo "Instance $1 stopped."
}

# Function to detach an EBS volume
detach_volume() {
    echo "Detaching volume: $1"
    aws ec2 detach-volume --volume-id $1
    aws ec2 wait volume-available --volume-ids $1
    echo "Volume $1 detached."
}

# Function to attach an EBS volume to an instance
attach_volume() {
    echo "Attaching volume $1 to instance $2"
    aws ec2 attach-volume --volume-id $1 --instance-id $2 --device /dev/sdf
    echo "Volume $1 attached to instance $2."
}

# Function to mount the volume using SSH
mount_volume() {
    echo "Mounting volume on instance $2 at /opt"
    ssh -o StrictHostKeyChecking=no -i /path/to/your/key.pem opc@$2 <<EOF
    sudo mkdir -p /opt
    sudo mount /dev/sdf /opt
    echo "Volume mounted at /opt"
EOF
}

# Main script starts here
# $1: Instance ID to stop, $2: Volume ID, $3: New Instance ID for attachment
instance_id_to_stop=$1
volume_id=$2
instance_id_to_attach=$3

# Get the public DNS or IP of the new instance for SSH
instance_dns=$(aws ec2 describe-instances --instance-ids $instance_id_to_attach --query 'Reservations[].Instances[].PublicDnsName' --output text)

stop_instance $instance_id_to_stop
detach_volume $volume_id
attach_volume $volume_id $instance_id_to_attach

# Wait a bit for the instance to initialize after attachment
echo "Waiting for instance to initialize..."
sleep 60

mount_volume $volume_id $instance_dns
