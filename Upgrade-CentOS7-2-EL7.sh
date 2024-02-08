#!/bin/bash

# Check if the script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root" 1>&2
    exit 1
fi

# Download the centos2ol.sh script
echo "Downloading the centos2ol.sh script..."
curl -O https://raw.githubusercontent.com/oracle/centos2ol/main/centos2ol.sh

# Make the script executable
chmod +x centos2ol.sh

# Execute the centos2ol.sh script to start the upgrade process
echo "Starting the upgrade process from CentOS 7 to OL 7..."
./centos2ol.sh -y

# Check if the centos2ol.sh script executed successfully
if [ $? -eq 0 ]; then
    echo "Upgrade successful. System will reboot now."
    # Reboot the system
    shutdown -r now
else
    echo "Upgrade failed. Please check the output for errors."
    exit 1
fi
