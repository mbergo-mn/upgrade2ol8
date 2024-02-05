#!/bin/bash

# Ensure the script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root."
   exit 1
fi

# Step 1: Update and prepare CentOS 7
echo "Updating CentOS 7 to the latest version..."
yum update -y
yum install -y wget screen yum-utils

# Migrate from CentOS 7 to Oracle Linux 7
echo "Migrating from CentOS 7 to Oracle Linux 7..."
wget https://github.com/oracle/centos2ol/blob/main/centos2ol.sh
chmod +x centos2ol.sh
./centos2ol.sh
# Verify the migration
echo "Migration to Oracle Linux 7 completed. Please verify by checking /etc/oracle-release."

# Step 2: Configure Oracle Linux 7 repositories
echo "Configuring Oracle Linux 7 repositories..."
cd /etc/yum.repos.d/
# Backup current repos and remove them
mkdir -p backup && mv *.repo backup/
# Configure OL7 repository
wget https://yum.oracle.com/repo/OracleLinux/OL7/beta/x86_64/ -O OracleLinux-OL7.repo
yum-config-manager --add-repo OracleLinux-OL7.repo

# Clean YUM cache
yum clean all

# Reinstall all packages for OL7 consistency
echo "Reinstalling all packages for Oracle Linux 7 consistency..."
yum reinstall -y $(yum list installed | grep .centos | awk '{print $1}')

# Step 3: Transition to OL8
echo "Preparing for Oracle Linux 8 upgrade..."
# Backup OL7 repos
mkdir -p backup_ol7 && mv *.repo backup_ol7/
# Configure OL8 repository
wget https://yum.oracle.com/repo/OracleLinux/OL8/beta/x86_64/ -O OracleLinux-OL8.repo
yum-config-manager --add-repo OracleLinux-OL8.repo

# Clean YUM cache
yum clean all

# Step 4: Upgrade to OL8
echo "Upgrading to Oracle Linux 8..."
yum upgrade -y

# Reinstall all packages for OL8 consistency
echo "Reinstalling all packages for Oracle Linux 8 consistency..."
yum reinstall -y $(yum list installed | grep .el7 | awk '{print $1}')

echo "Upgrade process to Oracle Linux 8 completed. Please verify the system's version and functionality."
