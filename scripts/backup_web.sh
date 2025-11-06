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