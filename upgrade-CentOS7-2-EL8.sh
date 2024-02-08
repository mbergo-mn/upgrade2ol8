#!/bin/bash

LOCK_FILE="/var/run/upgrade-to-ol8.lock"
ANSWER_FILE="/etc/leapp/answerfile"

# Ensure the script is run as root
if [ "$(id -u)" != "0" ]; then
    echo "This script must be run as root" 1>&2
    exit 1
fi

if [ ! -f "$LOCK_FILE" ]; then
    # Convert from CentOS 7.9 to Oracle Linux 7.9
    echo "Starting the conversion from CentOS 7.9 to Oracle Linux 7.9..."
    cd /tmp
    wget https://linux.oracle.com/switch/centos2ol.sh
    chmod +x centos2ol.sh
    ./centos2ol.sh

    if [ $? -eq 0 ]; then
        echo "Conversion to Oracle Linux completed successfully."
    else
        echo "Conversion to Oracle Linux failed. Please check the logs for details."
        exit 1
    fi

    # Configure Oracle Linux 7 repository after conversion
    # echo "Configuring Oracle Linux 7 repositories..."
    # cd /etc/yum.repos.d
    # wget https://yum.oracle.com/public-yum-ol7.repo
    # yum-config-manager --enable ol7_latest ol7_u0_base

    # Update system packages
    echo "Updating system packages..."
    yum update -y

    # Reinstall Oracle Linux 7 kernel
    echo "Reinstalling Oracle Linux 7 kernel..."
    yum reinstall kernel -y

    # Reinstall CentOS 7 specific packages for compatibility
    echo "Reinstalling CentOS 7 specific packages for compatibility with Oracle Linux 7..."
    rpm -qa | grep -i centos | xargs yum -y reinstall

    # Create a lock file to indicate the script has run before and needs to resume after reboot
    touch "$LOCK_FILE"

    echo "System will now reboot. After reboot, please run the script again to continue with the upgrade to Oracle Linux 8."
    reboot
else
    # Ensure Leapp and its repositories are installed
    echo "Installing Leapp for Oracle Linux upgrade preparation..."
    yum install leapp leapp-repository -y

    # Run Leapp preupgrade with Oracle Linux configuration
    echo "Running Leapp preupgrade with Oracle Linux configuration..."
    leapp preupgrade --oraclelinux

    # Modify the answer file automatically
    echo "Modifying the answer file automatically..."
    # Example modification: Uncommenting a line or setting a value
    # sed -i 's/^#setoption=setoption_value/setoption=setoption_value/' $ANSWER_FILE
    # Note: Replace the above sed command with the actual change needed

    # Proceed with Oracle Linux upgrade
    echo "Proceeding with Oracle Linux upgrade..."
    leapp upgrade --oraclelinux

    # Configure Oracle Linux 8 repository after upgrade
    echo "Configuring Oracle Linux 8 repositories..."
    cd /etc/yum.repos.d
    wget https://yum.oracle.com/public-yum-ol8.repo
    yum-config-manager --enable ol8_baseos_latest ol8_appstream

    # Update system packages for Oracle Linux 8
    echo "Updating system packages for Oracle Linux 8..."
    yum update -y

    # Reinstall Oracle 7 Linux specific packages for compatibility with Oracle Linux 8
    echo "Reinstalling Oracle Linux 7 specific packages for compatibility with Oracle Linux 8..."
    rpm -qa | grep -i el7 | xargs yum -y reinstall

    echo "System update, upgrade, and configuration completed."

    # Remove the lock file after completion
    rm -f "$LOCK_FILE"
fi
