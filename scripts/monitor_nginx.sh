#!/bin/bash

LOG_FILE="/var/log/nginx/access.log"
ALERT_THRESHOLD=10  # Alerts if more than 10 errors per minute
TRAFFIC_THRESHOLD=1000  # Alerts if more than 1000 requests per minute

# Function to monitor error rates
monitor_errors() {
    while true; do
        error_count=$(tail -n60 $LOG_FILE | grep -c " [45][0-9][0-9] ")
        if [ $error_count -gt $ALERT_THRESHOLD ]; then
            echo "ALERT: High error rate detected! $error_count errors in last minute"
            # Send email alert if mail is configured
            echo "High error rate: $error_count errors/minute" | mail -s "Nginx Error Alert" root
        fi
        sleep 60
    done
}

# Function to monitor traffic spikes
monitor_traffic() {
    while true; do
        requests=$(tail -n60 $LOG_FILE | wc -l)
        if [ $requests -gt $TRAFFIC_THRESHOLD ]; then
            echo "ALERT: High traffic detected! $requests requests in last minute"
            # Send email alert if mail is configured
            echo "High traffic: $requests requests/minute" | mail -s "Nginx Traffic Alert" root
        fi
        sleep 60
    done
}

# Function to show live statistics
show_stats() {
    while true; do
        clear
        echo "=== Nginx Real-Time Statistics === ($(date))"
        echo "Last 10 requests:"
        tail -n10 $LOG_FILE
        
        echo -e "\nError distribution (last minute):"
        tail -n60 $LOG_FILE | cut -d '"' -f3 | cut -d ' ' -f2 | sort | uniq -c
        
        echo -e "\nTop 5 IPs (last minute):"
        tail -n60 $LOG_FILE | awk '{print $1}' | sort | uniq -c | sort -nr | head -n5
        
        echo -e "\nMost requested URLs (last minute):"
        tail -n60 $LOG_FILE | awk -F'"' '{print $2}' | cut -d' ' -f2 | sort | uniq -c | sort -nr | head -n5
        
        echo -e "\nResponse time distribution:"
        tail -n60 $LOG_FILE | awk '{print $NF}' | sort -n | uniq -c
        
        sleep 5
    done
}

# Function to detect suspicious activity
monitor_security() {
    while true; do
        suspicious=$(tail -n60 $LOG_FILE | grep -i "union\|select\|insert\|admin\|wp-login" | wc -l)
        if [ $suspicious -gt 0 ]; then
            echo "SECURITY ALERT: Suspicious activity detected!"
            tail -n60 $LOG_FILE | grep -i "union\|select\|insert\|admin\|wp-login"
        fi
        sleep 60
    done
}

# Run all monitoring functions in background
show_stats &
monitor_errors &
monitor_traffic &
monitor_security &

# Wait for any process to exit
wait