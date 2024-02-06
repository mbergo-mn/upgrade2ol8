#!/bin/bash

# Ensure the script is executed as root
if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root"
  exit 1
fi

# Step 0: Pre-upgrade warning
echo "WARNING: This script attempts to upgrade from CentOS 7 to CentOS 8, which is End-of-Life."
echo "Ensure you have backups before proceeding. This process cannot be reversed."

# Step 1: System preparation
echo "Updating all CentOS 7 packages to their latest versions..."
yum update -y && yum upgrade -y

# Install the EPEL repository for CentOS 7
yum install -y epel-release
yum clean all

# System backup reminder
echo "It is crucial to perform a full system backup before proceeding."

# Replacing CentOS 7 repositories with CentOS 8
echo "Setting up CentOS 8 repositories..."
cat >/etc/yum.repos.d/CentOS-Base.repo <<EOF
[BaseOS]
name=CentOS-8 - Base
baseurl=http://vault.centos.org/8.4.2105/BaseOS/x86_64/os/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial

[AppStream]
name=CentOS-8 - AppStream
baseurl=http://vault.centos.org/8.4.2105/AppStream/x86_64/os/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial
EOF

# Cleaning up YUM caches
yum clean all
rm -r /var/cache/yum
yum makecache

# Step 2: Install the DNF package manager
echo "Installing DNF, the next-generation package manager..."
yum install -y dnf

# Removing yum to prevent conflicts
echo "Removing yum package manager..."
yum remove -y yum yum-metadata-parser
rm -rf /etc/yum

# Step 3: Upgrade process
echo "Upgrading the system to CentOS 8. Please be patient, as this might take a while..."
dnf -y --releasever=8 --allowerasing --setopt=deltarpm=false distro-sync

# Step 4: Post-upgrade steps
echo "Reinstalling all packages to ensure they are up to date with CentOS 8 versions..."
dnf -y reinstall "*"

echo "Installing new kernel..."
dnf -y install kernel-core

echo "Removing old kernels..."
dnf -y remove kernel

echo "Cleaning up..."
dnf -y autoremove
dnf clean all

# Rebuilding RPM DB
echo "Rebuilding RPM database..."
rpm --rebuilddb

# Step 5: Finalize upgrade
echo "Regenerating initramfs..."
dracut -f --regenerate-all

echo "Upgrade process is almost complete. A reboot is required to finalize the upgrade."
read -p "Do you want to reboot now? (y/n): " answer
if [[ "$answer" = "y" ]]; then
  echo "Rebooting now..."
  reboot
else
  echo "Please reboot the system manually to complete the upgrade process."
fi
