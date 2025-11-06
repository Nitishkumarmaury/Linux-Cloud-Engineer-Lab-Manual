#!/bin/bash

# Configuration
BACKUP_DIR="/etc/ufw/backup"
LOG_FILE="/var/log/ufw_setup.log"

# Function to log messages
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a $LOG_FILE
}

# Create backup directory
mkdir -p $BACKUP_DIR

# Backup existing rules
if [ -f /etc/ufw/user.rules ]; then
    cp /etc/ufw/user.rules "$BACKUP_DIR/user.rules.$(date +%Y%m%d)"
fi

# Reset UFW
log_message "Resetting UFW to default state"
sudo ufw --force reset

# Default policies
log_message "Setting default policies"
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Essential services
log_message "Configuring essential services"
sudo ufw allow ssh
sudo ufw allow http
sudo ufw allow https

# Application-specific rules
log_message "Configuring application-specific rules"

# Web Services
sudo ufw allow 80/tcp    # HTTP
sudo ufw allow 443/tcp   # HTTPS

# Database Services
sudo ufw allow 3306/tcp  # MySQL
sudo ufw allow 5432/tcp  # PostgreSQL
sudo ufw allow 27017/tcp # MongoDB

# Cache Services
sudo ufw allow 6379/tcp  # Redis
sudo ufw allow 11211/tcp # Memcached

# Mail Services
sudo ufw allow 25/tcp    # SMTP
sudo ufw allow 143/tcp   # IMAP
sudo ufw allow 993/tcp   # IMAPS
sudo ufw allow 995/tcp   # POP3S

# Rate limiting
log_message "Configuring rate limiting"
sudo ufw limit ssh
sudo ufw limit 3306/tcp  # MySQL
sudo ufw limit 5432/tcp  # PostgreSQL

# Allow specific subnets (customize as needed)
# sudo ufw allow from 192.168.1.0/24
# sudo ufw allow from 10.0.0.0/8

# Logging
log_message "Configuring logging"
sudo ufw logging on
sudo ufw logging medium

# Enable firewall
log_message "Enabling UFW"
sudo ufw --force enable

# Verify configuration
log_message "Current UFW Status:"
sudo ufw status verbose | tee -a $LOG_FILE

# Create allowed ports summary
log_message "Creating ports summary"
echo "# Allowed Ports Summary" > $BACKUP_DIR/ports_summary.txt
sudo ufw status numbered | grep ALLOW | cut -d"]" -f2 | sort -u >> $BACKUP_DIR/ports_summary.txt

# Create basic documentation
cat << EOF > $BACKUP_DIR/README.md
# Firewall Configuration Documentation

## Overview
This firewall configuration was set up on $(date) using UFW (Uncomplicated Firewall).

## Allowed Services
$(grep ALLOW /etc/ufw/user.rules | sed 's/### tuple ### /\n### /')

## Default Policies
- Incoming: DENY
- Outgoing: ALLOW

## Rate Limited Services
- SSH (port 22)
- MySQL (port 3306)
- PostgreSQL (port 5432)

## Logging
- Logging is enabled
- Level: medium

## Backup Location
Configuration backups are stored in $BACKUP_DIR

## Modification History
$(ls -l $BACKUP_DIR)
EOF

log_message "Firewall configuration completed successfully"
log_message "Configuration documentation saved to $BACKUP_DIR/README.md"

# Final checks
log_message "Performing final checks"
echo "Checking SSH access..."
nc -zv localhost 22
echo "Checking HTTP access..."
nc -zv localhost 80
echo "Checking HTTPS access..."
nc -zv localhost 443

log_message "Setup complete. Please verify all required services are accessible."