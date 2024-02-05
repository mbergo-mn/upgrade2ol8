#!/bin/bash

# Upgrade Script from CentOS 7.9 to OL7, then to OL8

# Path to a flag file to control the upgrade flow
UPGRADE_FLAG="/root/upgrade_stage.txt"
LOG_FILE="/root/upgrade_log.txt"

# Ensure the script is running as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

# Log execution
exec > >(tee -a $LOG_FILE) 2>&1

# Function to check if the last command was successful
check_success() {
    if [ $? -ne 0 ]; then
        echo "An error occurred. Please check the log file for more information."
        exit 1
    fi
}

# Function to migrate CentOS to OL7
migrate_to_ol7() {
    echo "Starting migration from CentOS to Oracle Linux 7..."
    yum update -y
    check_success

    yum install -y screen wget
    check_success

    wget https://github.com/oracle/centos2ol/blob/main/centos2ol.sh
    check_success

    chmod +x centos2ol.sh
    ./centos2ol.sh
    check_success

    echo "2" > $UPGRADE_FLAG
    echo "Migration to Oracle Linux 7 completed. Rebooting to continue..."
    reboot
}

# Function to reinstall CentOS packages with OL equivalents
reinstall_centos_packages() {
    echo "Identifying and reinstalling CentOS packages with Oracle Linux equivalents..."
    rpm -qa | grep -i centos | while read -r pkg; do
        yum reinstall "$pkg" -y
        check_success
    done
}

# Function to upgrade from OL7 to OL8
upgrade_to_ol8() {
    echo "Starting upgrade from Oracle Linux 7 to Oracle Linux 8..."
    yum install -y oraclelinux-release-el8
    check_success

    dnf -y install oracle-epel-release-el8
    check_success

    dnf -y upgrade
    check_success

    echo "Upgrade to Oracle Linux 8 completed. Final cleanup and checks..."
    echo "3" > $UPGRADE_FLAG
}

# Function for final cleanup and removing the script from startup
final_cleanup() {
    echo "Performing final cleanup..."
    # Additional cleanup tasks can be added here

    # Remove script from crontab
    crontab -l | grep -v '/root/upgrade_script.sh' | crontab -
    echo "Upgrade process completed. Upgrade script removed from startup."
}

# Main logic
if [ ! -f $UPGRADE_FLAG ]; then
    echo "1" > $UPGRADE_FLAG
    migrate_to_ol7
else
    stage=$(cat $UPGRADE_FLAG)
    case $stage in
        1)
            migrate_to_ol7
            ;;
        2)
            reinstall_centos_packages
            upgrade_to_ol8
            ;;
        3)
            final_cleanup
            ;;
        *)
            echo "Unknown stage. Exiting..."
            exit 1
            ;;
    esac
fi

# Add to crontab to run at reboot if not already added
if ! crontab -l | grep -q '/root/upgrade_script.sh'; then
  (crontab -l 2>/dev/null; echo "@reboot /root/upgrade_script.sh") | crontab -
fi
