#!/bin/bash

#=================================================================
# Practical 7: Security Configuration
# Purpose: Monitor firewall status and security events
# Created: November 7, 2025
#=================================================================

# Configuration
LOG_FILE="/var/log/ufw.log"
ALERT_LOG="/var/log/firewall_alerts.log"
THRESHOLD=10  # Alert if more than 10 connection attempts per minute
BLOCK_THRESHOLD=20  # Auto-block if more than 20 attempts
WHITELIST_FILE="/etc/security/whitelist.txt"
EMAIL_ALERTS="root"

# Create log file if it doesn't exist
touch $ALERT_LOG
chmod 640 $ALERT_LOG

# Function to log messages
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> $ALERT_LOG
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
}

# Function to check if IP is whitelisted
is_whitelisted() {
    if [ -f "$WHITELIST_FILE" ]; then
        grep -q "^$1$" "$WHITELIST_FILE"
        return $?
    fi
    return 1
}

# Function to send email alerts
send_alert() {
    if command -v mail >/dev/null 2>&1; then
        echo "$1" | mail -s "Firewall Alert on $(hostname)" $EMAIL_ALERTS
    fi
}

# Function to analyze attack patterns
analyze_patterns() {
    ip=$1
    log_file=$2
    
    # Check for SSH brute force attempts
    ssh_attempts=$(grep "DPT=22" $log_file | grep $ip | wc -l)
    if [ $ssh_attempts -gt 5 ]; then
        log_message "Possible SSH brute force attack from $ip"
        return 1
    fi
    
    # Check for port scanning
    unique_ports=$(grep $ip $log_file | grep "DPT=" | cut -d"=" -f3 | cut -d" " -f1 | sort -u | wc -l)
    if [ $unique_ports -gt 10 ]; then
        log_message "Possible port scan from $ip"
        return 1
    fi
    
    return 0
}

# Function to handle suspicious IP
handle_suspicious_ip() {
    ip=$1
    
    if is_whitelisted $ip; then
        log_message "Whitelisted IP detected: $ip - skipping block"
        return
    fi
    
    # Check if IP is already blocked
    if sudo ufw status | grep -q $ip; then
        log_message "IP $ip is already blocked"
        return
    fi
    
    # Block the IP
    sudo ufw insert 1 deny from $ip
    log_message "Blocked IP: $ip"
    send_alert "Blocked suspicious IP: $ip due to multiple connection attempts"
    
    # Log to system journal
    logger -t firewall-monitor "Blocked suspicious IP: $ip"
}

# Function to monitor connections
monitor_connections() {
    log_message "Starting firewall monitoring..."
    
    tail -F $LOG_FILE | while read line; do
        # Extract IP address
        ip=$(echo $line | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" | head -1)
        
        if [ ! -z "$ip" ]; then
            # Count recent attempts from this IP
            attempts=$(grep $ip <(tail -n500 $LOG_FILE) | wc -l)
            
            if [ $attempts -gt $BLOCK_THRESHOLD ]; then
                analyze_patterns $ip $LOG_FILE
                if [ $? -eq 1 ]; then
                    handle_suspicious_ip $ip
                fi
            elif [ $attempts -gt $THRESHOLD ]; then
                log_message "Warning: High connection attempts from IP: $ip ($attempts attempts)"
            fi
        fi
    done
}

# Function to generate hourly report
generate_report() {
    while true; do
        sleep 3600  # Wait for 1 hour
        
        echo "=== Firewall Report $(date) ===" >> $ALERT_LOG
        echo "Top 10 blocked IPs in the last hour:" >> $ALERT_LOG
        grep "UFW BLOCK" $LOG_FILE | tail -n1000 | \
            grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" | \
            sort | uniq -c | sort -nr | head -n10 >> $ALERT_LOG
            
        echo "Recent suspicious activities:" >> $ALERT_LOG
        tail -n100 $ALERT_LOG | grep "suspicious\|blocked\|attack" >> $ALERT_LOG
    done
}

# Start monitoring in background
monitor_connections &

# Start report generation in background
generate_report &

# Wait for any process to exit
wait