#!/bin/bash

#=================================================================
# Practical 5: Backup Management
# Purpose: Verify and validate backup integrity
# Created: November 7, 2025
#=================================================================

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

# Check backup integrity
if [ -f "$LATEST_BACKUP" ]; then
    if tar -tzf "$LATEST_BACKUP" >/dev/null 2>&1; then
        echo "Backup integrity check: PASSED"
    else
        echo "Backup integrity check: FAILED"
        exit 1
    fi
fi

# Check backup logs
RECENT_ERRORS=$(grep -i "error\|fail" "$LOG_DIR"/* 2>/dev/null | wc -l)
if [ $RECENT_ERRORS -gt 0 ]; then
    echo "WARNING: Found $RECENT_ERRORS error(s) in recent backup logs"
    grep -i "error\|fail" "$LOG_DIR"/*
fi

exit 0