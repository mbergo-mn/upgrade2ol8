#!/bin/bah

# Update CentOS System
echo "Updating CentOS System..."
sudo yum update -y

# Install Oracle Linux 8.9
echo "Installing Oracle Linux 8.9..."
sudo yum install oraclelinux-release-el8 -y

# Upgrade to Oracle Linux 8.9
echo "Upgrading to Oracle Linux 8.9..."
sudo yum upgrade -y

# Clean CentOS Packages
echo "Cleaning CentOS Packages..."
sudo yum remove centos-* -y

# Verify Upgrade
echo "Verifying Upgrade..."
cat /etc/os-releasetouc