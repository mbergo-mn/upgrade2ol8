#!/bin/bash

# Ensure the script is run as root
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# Step 1: Convert from CentOS 7.9 to Oracle Linux 7.9
echo "Starting the conversion from CentOS 7.9 to Oracle Linux 7.9..."
cd /tmp
wget https://linux.oracle.com/switch/centos2ol.sh
chmod +x centos2ol.sh
sh centos2ol.sh

if [ $? -eq 0 ]; then
    echo "Conversion to Oracle Linux completed successfully."
else
    echo "Conversion to Oracle Linux failed. Please check the logs for details."
    exit 1
fi

# Step 2: Configure Oracle Linux 7 repository after conversion
echo "Configuring Oracle Linux 7 repositories..."
cd /etc/yum.repos.d
wget https://yum.oracle.com/public-yum-ol7.repo
# Enabling required repositories for Oracle Linux 7
yum-config-manager --enable ol7_latest ol7_u0_base

# Update system to ensure all packages are up to date after repository change
echo "Updating system packages..."
yum update -y

# Step 3: Update system and install Leapp for upgrade preparation
echo "Installing Leapp for Oracle Linux upgrade preparation..."
yum install leapp leapp-repository -y

# Prepare for the upgrade using Leapp
echo "Preparing for Oracle Linux 8 upgrade with Leapp..."
leapp preupgrade

# Step 4: Upgrade to Oracle Linux 8 using Leapp
echo "Upgrading to Oracle Linux 8..."
leapp upgrade

# Step 5: Configure the Oracle Linux 8 repository after upgrade
echo "Configuring Oracle Linux 8 repositories..."
cd /etc/yum.repos.d
wget https://yum.oracle.com/public-yum-ol8.repo
# Enabling required repositories for Oracle Linux 8
yum-config-manager --enable ol8_baseos_latest ol8_appstream

# Update system to ensure all packages are up to date after repository change
echo "Updating system packages for Oracle Linux 8..."
yum update -y

# Step 6: Reinstall packages that were specifically related to CentOS 7 for compatibility with Oracle Linux 8
echo "Reinstalling CentOS 7 specific packages for compatibility with Oracle Linux 8..."
rpm -qa | grep -i el7 | xargs yum -y reinstall

echo "System update, upgrade, and configuration completed."
