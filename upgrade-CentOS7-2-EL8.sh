#!/bin/bash

# Upgrade script from CentOS 7 to Oracle Linux 7, then to Oracle Linux 8
# This script attempts to handle package reinstallation and YUM to DNF upgrade

# Variables
UPGRADE_FLAG="/root/upgrade_stage.txt"
CENTOS_PKG_LIST="/root/centos_packages.txt"

# Stage 1: Migrate from CentOS to Oracle Linux 7
migrate_to_ol7() {
    echo "Stage 1: Migrating from CentOS to Oracle Linux 7..."
    yum update -y
    yum install -y screen wget
    wget https://github.com/oracle/centos2ol/blob/main/centos2ol.sh
    chmod +x centos2ol.sh
    ./centos2ol.sh
    echo "2" > $UPGRADE_FLAG
    rpm -qa | grep -i centos > $CENTOS_PKG_LIST
    echo "Rebooting into Oracle Linux 7..."
    reboot
}

# Stage 2: Replace CentOS packages, upgrade YUM to DNF
replace_centos_packages_and_upgrade_yum() {
    echo "Stage 2: Replacing CentOS packages and upgrading YUM to DNF..."
    while IFS= read -r package; do
        yum reinstall -y "$package"
    done < "$CENTOS_PKG_LIST"
    yum install -y dnf
    dnf upgrade -y
    echo "3" > $UPGRADE_FLAG
    echo "Rebooting to ensure all updates take effect..."
    reboot
}

# Stage 3: Upgrade from Oracle Linux 7 to Oracle Linux 8
upgrade_to_ol8() {
    echo "Stage 3: Upgrading from Oracle Linux 7 to Oracle Linux 8..."
    # The Leapp upgrade requires manual intervention and careful planning
    # Placeholder for Leapp upgrade commands and preparation
    echo "Manual intervention required for OL7 to OL8 upgrade. Please follow Oracle's official documentation."
    # After manual upgrade:
    # echo "4" > $UPGRADE_FLAG
}

# Final stage: Cleanup and finishing touches
final_cleanup() {
    echo "Final Stage: Cleanup and system checks..."
    # Placeholder for any final cleanup tasks
    echo "Upgrade process completed."
    # Remove the script from cron jobs
    crontab -l | grep -v 'upgrade_script.sh' | crontab -
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
            replace_centos_packages_and_upgrade_yum
            ;;
        3)
            upgrade_to_ol8
            ;;
        4)
            final_cleanup
            ;;
        *)
            echo "Unknown stage. Exiting..."
            exit 1
            ;;
    esac
fi

# Add to crontab to run at reboot, if not already added
if ! crontab -l | grep -q 'upgrade_script.sh'; then
    (crontab -l 2>/dev/null; echo "@reboot /root/upgrade_script.sh") | crontab -
fi
