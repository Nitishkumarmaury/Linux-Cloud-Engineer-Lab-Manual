#!/bin/bash

#=================================================================
# Practical 10: Multi-VM Infrastructure Management
# Purpose: Monitor multiple VMs in a distributed environment
# Created: November 7, 2025
#=================================================================

# Configuration
LOG_FILE="/var/log/multi_vm_monitor.log"
ALERT_LOG="/var/log/multi_vm_alerts.log"
EMAIL_TO="root"

# VM Information
WEB_SERVER="web-server-1"
DB_SERVER="db-server-1"
LB_SERVER="lb-server-1"

# Thresholds
CPU_THRESHOLD=80
MEMORY_THRESHOLD=80
DISK_THRESHOLD=90
LOAD_THRESHOLD=5

# Function to log messages
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a $LOG_FILE
}

# Function to send alerts
send_alert() {
    local message="$1"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - ALERT: $message" | tee -a $ALERT_LOG
    if command -v mail >/dev/null 2>&1; then
        echo "$message" | mail -s "Multi-VM Alert on $(hostname)" $EMAIL_TO
    fi
}

# Function to check server health
check_server_health() {
    local server=$1
    
    # Check if server is reachable
    if ! ping -c 1 $server >/dev/null 2>&1; then
        send_alert "Server $server is unreachable"
        return 1
    fi
    
    # Get system metrics using SSH
    ssh $server "
        # CPU Usage
        cpu_usage=\$(top -bn1 | grep 'Cpu(s)' | awk '{print \$2}' | cut -d. -f1)
        
        # Memory Usage
        mem_usage=\$(free | grep Mem | awk '{print \$3/\$2 * 100.0}' | cut -d. -f1)
        
        # Disk Usage
        disk_usage=\$(df / | tail -1 | awk '{print \$5}' | sed 's/%//')
        
        # Load Average
        load_avg=\$(uptime | awk -F'load average:' '{print \$2}' | cut -d, -f1 | tr -d ' ')
        
        # Output all metrics
        echo \"\$cpu_usage|\$mem_usage|\$disk_usage|\$load_avg\"
    " > /tmp/metrics_$server
    
    # Read metrics
    IFS='|' read cpu_usage mem_usage disk_usage load_avg < /tmp/metrics_$server
    
    # Check thresholds
    if [ $cpu_usage -gt $CPU_THRESHOLD ]; then
        send_alert "High CPU usage on $server: ${cpu_usage}%"
    fi
    
    if [ $mem_usage -gt $MEMORY_THRESHOLD ]; then
        send_alert "High memory usage on $server: ${mem_usage}%"
    fi
    
    if [ $disk_usage -gt $DISK_THRESHOLD ]; then
        send_alert "High disk usage on $server: ${disk_usage}%"
    fi
    
    if (( $(echo "$load_avg > $LOAD_THRESHOLD" | bc -l) )); then
        send_alert "High load average on $server: $load_avg"
    fi
    
    # Clean up
    rm /tmp/metrics_$server
}

# Function to check database connectivity
check_database() {
    ssh $WEB_SERVER "
        mysql -h $DB_SERVER -u myapp -p'secure_password' -e 'SELECT 1;' >/dev/null 2>&1
    "
    if [ $? -ne 0 ]; then
        send_alert "Database connectivity failed from $WEB_SERVER to $DB_SERVER"
    fi
}

# Function to check web service
check_web_service() {
    # Check from load balancer
    ssh $LB_SERVER "
        curl -s -I http://$WEB_SERVER | grep -q '200 OK'
    "
    if [ $? -ne 0 ]; then
        send_alert "Web service check failed from $LB_SERVER to $WEB_SERVER"
    fi
}

# Function to check SSL certificates
check_ssl_certificates() {
    ssh $LB_SERVER "
        ssl_dates=\$(openssl s_client -connect localhost:443 -servername \$HOSTNAME </dev/null 2>/dev/null | openssl x509 -noout -dates)
        end_date=\$(echo \"\$ssl_dates\" | grep 'notAfter=' | cut -d= -f2)
        end_epoch=\$(date -d \"\$end_date\" +%s)
        current_epoch=\$(date +%s)
        days_left=\$(( (\$end_epoch - \$current_epoch) / 86400 ))
        
        if [ \$days_left -lt 30 ]; then
            echo \"SSL certificate will expire in \$days_left days\"
        fi
    " | while read line; do
        if [ ! -z "$line" ]; then
            send_alert "$line"
        fi
    done
}

# Function to generate report
generate_report() {
    local report_file="/tmp/infrastructure_report_$(date +%Y%m%d_%H%M%S).txt"
    
    echo "Multi-VM Infrastructure Report - $(date)" > $report_file
    echo "=====================================" >> $report_file
    
    for server in $WEB_SERVER $DB_SERVER $LB_SERVER; do
        echo -e "\nServer: $server" >> $report_file
        ssh $server "
            echo 'System Information:'
            uname -a
            echo -e '\nUptime:'
            uptime
            echo -e '\nMemory Usage:'
            free -h
            echo -e '\nDisk Usage:'
            df -h
            echo -e '\nProcess List:'
            ps aux --sort=-%cpu | head -n 6
        " >> $report_file 2>&1
    done
    
    log_message "Generated report: $report_file"
}

# Main monitoring loop
log_message "Starting multi-VM monitoring..."

while true; do
    # Check each server
    for server in $WEB_SERVER $DB_SERVER $LB_SERVER; do
        check_server_health $server
    done
    
    # Check services
    check_database
    check_web_service
    check_ssl_certificates
    
    # Generate hourly report
    if [ $(date +%M) -eq 0 ]; then
        generate_report
    fi
    
    # Wait before next check
    sleep 300  # Check every 5 minutes
done