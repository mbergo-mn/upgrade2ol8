#!/bin/bash

# Ensure the script is run as root
if [ "$(id -u)" -ne 0 ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

echo "Starting the process to upgrade from CentOS 8 to Oracle Linux 8.9..."

# Step 1: Install Oracle Linux Switch script
echo "Installing Oracle Linux Switch script..."
curl -O https://linux.oracle.com/switch/centos2ol.sh
chmod +x centos2ol.sh

# Step 2: Run the switch script
echo "Running the Oracle Linux Switch script..."
./centos2ol.sh

# Script will perform checks and ask for confirmation before proceeding

# Step 3: Check for successful switch
if [ $? -eq 0 ]; then
    echo "Switch to Oracle Linux repositories successful."
else
    echo "Switch to Oracle Linux repositories failed. Please check the output for errors."
    exit 1
fi

# Step 4: Update all packages to Oracle Linux latest
echo "Updating all packages to the latest versions under Oracle Linux..."
dnf update -y

# Step 5: Upgrade to Oracle Linux 8.9
echo "Upgrading to Oracle Linux 8.9..."
dnf update -y

# Step 6: Clean up
echo "Cleaning up..."
dnf clean all

# Step 7: Check Oracle Linux version
echo "Checking Oracle Linux version..."
cat /etc/oracle-release

# Step 8: Reboot
echo "System needs to reboot to complete the upgrade process."
read -p "Reboot now? (y/N): " answer
if [[ "$answer" = [Yy]* ]]; then
    echo "Rebooting..."
    reboot
else
    echo "Please reboot the system manually to complete the upgrade."
fi

echo "Upgrade process complete. Your system is now running Oracle Linux 8.9."
