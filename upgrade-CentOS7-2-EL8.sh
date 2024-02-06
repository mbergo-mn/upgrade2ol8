#!/bin/bash

# Ensure the script is run as root
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# Step 1: Download and run the CentOS to Oracle Linux conversion script
echo "Starting the conversion from CentOS 7.9 to Oracle Linux 7.9..."
cd /tmp || exit
wget https://linux.oracle.com/switch/centos2ol.sh
chmod +x centos2ol.sh
sh centos2ol.sh

# Checking if the conversion was successful
if [ $? -eq 0 ]; then
    echo "Conversion to Oracle Linux completed successfully."
else
    echo "Conversion to Oracle Linux failed. Please check the logs for details."
    exit 1
fi

# Step 2: Update the system to Oracle Linux 7.9
echo "Updating system to Oracle Linux 7.9..."
yum update -y

# Step 3: Configure the Oracle Linux 7 repository
# echo "Configuring Oracle Linux 7 repository..."
# cd /etc/yum.repos.d
# wget https://yum.oracle.com/public-yum-ol7.repo
# # If you need to specifically enable the OL7 beta repository, you might need to edit the repo file manually or use `sed` to automate it
# sed -i 's/enabled=0/enabled=1/g' public-yum-ol7.repo

# Optional: You might want to specifically enable the beta repository
echo "Enabling Oracle Linux 7 Beta repository..."
yum-config-manager --enable ol7_beta

# Step 4: Reinstall any packages from the old CentOS repository to ensure compatibility
echo "Reinstalling packages to ensure compatibility with Oracle Linux..."
rpm -qa | grep -i centos | xargs yum -y reinstall

echo "System update and configuration completed! Please reboot..."
