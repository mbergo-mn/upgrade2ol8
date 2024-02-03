#!/bin/bash

# Define log file
LOG_FILE="/var/log/centos_to_ol_migration.log"

# Function to log messages
log_message() {
  echo "[$(date +"%Y-%m-%d %T")] $1" | tee -a "$LOG_FILE"
}

# Starting the migration process
log_message "Starting the migration from CentOS 7.9 to Oracle Linux 8.9"

# Step 1: Backup Reminder
log_message "Reminder: Ensure you have a complete backup of your system before proceeding."
read -p "Press Enter to continue if you have backed up your system..."

# Step 2: Download and Execute centos2ol.sh
log_message "Downloading the centos2ol.sh script from Oracle's GitHub repository..."
curl -O https://raw.githubusercontent.com/oracle/centos2ol/main/centos2ol.sh &>>"$LOG_FILE"
chmod +x centos2ol.sh

log_message "Running the centos2ol.sh script to convert CentOS 7.9 to Oracle Linux 7..."
sudo bash -x ./centos2ol.sh &>>"$LOG_FILE"

# Checking if the conversion was successful
if [[ $? -ne 0 ]]; then
  log_message "The conversion encountered errors. Check $LOG_FILE and resolve any issues before proceeding."
  exit 1
fi
log_message "Conversion to Oracle Linux 7 completed successfully."

# Remove rdma-core if needed
sudo yum remove rdma-core -y &>>"$LOG_FILE"
log_message "rdma-core removed."

# Enable necessary repositories for upgrade
sudo yum-config-manager --enable ol7_latest &>>"$LOG_FILE"
sudo yum-config-manager --enable ol8_baseos_latest &>>"$LOG_FILE"
sudo yum-config-manager --enable ol8_appstream &>>"$LOG_FILE"
log_message "Enabled necessary repositories for the upgrade."

# Begin upgrade to Oracle Linux 8.9
log_message "Upgrading to Oracle Linux 8.9..."
# Note: This step requires careful handling. Include specific commands for upgrading.
# For instance, you may use `dnf` to upgrade to Oracle Linux 8.9, following Oracle's guidelines.
# Begin upgrade to Oracle Linux 8.9
# Install Oracle Linux 8.9
echo "Installing Oracle Linux 8.9..."
sudo yum install oraclelinux-release-el8 -y

# Upgrade to Oracle Linux 8.9
echo "Upgrading to Oracle Linux 8.9..."
sudo yum upgrade -y

# Restart services in /opt
log_message "Restarting services located in /opt..."
for service in /opt/*; do
  if [ -d "$service" ]; then
    local service_name="$(basename "$service")"
    log_message "Attempting to restart the service: $service_name"
    if systemctl is-active --quiet "$service_name"; then
      systemctl restart "$service_name" &>>"$LOG_FILE"
      log_message "Service $service_name restarted."
    else
      log_message "Service $service_name is not active or not a systemd service."
    fi
  fi
done

# Final verification
log_message "Migration to Oracle Linux 8.9 is complete. Remember to test thoroughly."
log_message "Please verify the system version and functionality of all services and applications."
