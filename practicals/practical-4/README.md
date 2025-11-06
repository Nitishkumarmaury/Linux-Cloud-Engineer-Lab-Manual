# Practical 4: Automating Backups with Bash & Cron

This practical demonstrates how to create and schedule automated backups, an essential skill for maintaining data safety in cloud environments.

## Objectives

- Write a backup shell script
- Implement automated scheduling with cron
- Handle backup rotation
- Monitor backup success/failure

## Prerequisites

- Completed Practicals 1-3
- Basic shell scripting knowledge
- Understanding of cron syntax

## Step-by-Step Guide

### 1. Create Backup Directories

```bash
# Create backup directory
sudo mkdir -p /var/backups/website
sudo mkdir -p /var/backups/logs

# Set permissions
sudo chmod 750 /var/backups/website
sudo chmod 750 /var/backups/logs
```

### 2. Create Backup Script

Create the script file:
```bash
sudo vi /usr/local/bin/backup_web.sh
```

Add this content:
```bash
#!/bin/bash

# Configuration
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_DIR="/var/backups/website"
LOG_DIR="/var/backups/logs"
BACKUP_FILE="web-backup-$TIMESTAMP.tar.gz"
LOG_FILE="$LOG_DIR/backup-$TIMESTAMP.log"
MAX_BACKUPS=7

# Ensure backup directory exists
mkdir -p $BACKUP_DIR
mkdir -p $LOG_DIR

# Start logging
exec 1> >(tee -a "$LOG_FILE")
exec 2>&1

echo "Starting backup at $(date)"

# Create backup
echo "Creating backup of /var/www/html"
tar -czf "$BACKUP_DIR/$BACKUP_FILE" /var/www/html
if [ $? -eq 0 ]; then
    echo "Backup successful: $BACKUP_FILE"
else
    echo "Backup failed!"
    exit 1
fi

# Rotate old backups
echo "Rotating old backups..."
ls -1t $BACKUP_DIR/web-backup-* 2>/dev/null | tail -n +$((MAX_BACKUPS + 1)) | xargs -r rm
echo "Backup rotation complete"

# Calculate backup size
BACKUP_SIZE=$(du -h "$BACKUP_DIR/$BACKUP_FILE" | cut -f1)
echo "Backup size: $BACKUP_SIZE"

# Send email notification (if mail is configured)
if command -v mail >/dev/null 2>&1; then
    echo "Backup completed successfully. Size: $BACKUP_SIZE" | mail -s "Website Backup Report" root
fi

echo "Backup process completed at $(date)"
```

### 3. Set Permissions

```bash
# Make script executable
sudo chmod 755 /usr/local/bin/backup_web.sh

# Test run the script
sudo /usr/local/bin/backup_web.sh
```

### 4. Configure Cron Job

```bash
# Edit root's crontab
sudo crontab -e
```

Add this line to run daily at 3 AM:
```
0 3 * * * /usr/local/bin/backup_web.sh
```

### 5. Monitor Backups

Create a backup monitoring script:
```bash
sudo vi /usr/local/bin/check_backups.sh
```

Add this content:
```bash
#!/bin/bash

BACKUP_DIR="/var/backups/website"
LOG_DIR="/var/backups/logs"

# Check for recent backups (last 24 hours)
RECENT_BACKUPS=$(find $BACKUP_DIR -name "web-backup-*" -mtime -1 | wc -l)

if [ $RECENT_BACKUPS -eq 0 ]; then
    echo "WARNING: No recent backups found!"
    exit 1
else
    echo "Found $RECENT_BACKUPS recent backup(s)"
    ls -lh $BACKUP_DIR/web-backup-* | tail -n $RECENT_BACKUPS
fi

# Check backup sizes
LATEST_BACKUP=$(ls -1t $BACKUP_DIR/web-backup-* | head -n1)
BACKUP_SIZE=$(du -h "$LATEST_BACKUP" | cut -f1)
echo "Latest backup size: $BACKUP_SIZE"

# Check available disk space
DISK_SPACE=$(df -h $BACKUP_DIR | awk 'NR==2 {print $4}')
echo "Available disk space: $DISK_SPACE"
```

Make it executable:
```bash
sudo chmod 755 /usr/local/bin/check_backups.sh
```

## Expected Outcomes

- [x] Automated daily backups
- [x] Backup rotation implemented
- [x] Email notifications configured
- [x] Monitoring script functional

## Troubleshooting

### Common Issues

1. **Script Not Running**
   - Check cron service: `systemctl status cron`
   - Verify script permissions
   - Check cron syntax

2. **Backup Failed**
   - Check disk space
   - Verify directory permissions
   - Review backup logs

3. **Email Notifications Not Working**
   - Install postfix or mailutils
   - Configure mail relay
   - Check mail logs

## Backup Best Practices

1. Regular Testing
```bash
# Test backup restoration
sudo tar -xzf /var/backups/website/[BACKUP_FILE] -C /tmp/restore_test
```

2. Monitoring
```bash
# Add to monitoring script crontab
0 9 * * * /usr/local/bin/check_backups.sh
```

3. Off-site Copy
```bash
# Example with rsync (if configured)
rsync -av /var/backups/ backup-server:/backups/
```

## Career Tips

- Understand backup strategies (full, incremental, differential)
- Learn about backup verification and testing
- Document your backup and recovery procedures
- Practice disaster recovery scenarios