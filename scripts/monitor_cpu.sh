#!/bin/bash

#=================================================================
# Practical 3: System Resource Monitoring
# Purpose: Monitor CPU usage and system resources
# Created: November 7, 2025
#=================================================================

# Configuration
THRESHOLD=80         # CPU usage threshold percentage
INTERVAL=5          # Check interval in seconds
LOG_FILE="/var/log/cpu_monitoring.log"
ALERT_COUNT=0       # Counter for consecutive alerts
MAX_ALERTS=3        # Maximum number of consecutive alerts before taking action
NOTIFICATION_EMAIL="root"  # Email to send notifications to

# Function to log messages
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> $LOG_FILE
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
}

# Function to get process details
get_process_details() {
    pid=$1
    if [ -e "/proc/$pid" ]; then
        cmd=$(ps -p $pid -o cmd=)
        user=$(ps -p $pid -o user=)
        cpu=$(ps -p $pid -o %cpu=)
        mem=$(ps -p $pid -o %mem=)
        echo "PID: $pid, User: $user, CPU: $cpu%, Mem: $mem%, Command: $cmd"
    fi
}

# Function to take action on high CPU processes
handle_high_cpu_process() {
    pid=$1
    cpu_usage=$2
    
    log_message "Taking action on PID $pid (CPU: $cpu_usage%)"
    
    # First attempt: Renice the process
    renice 19 $pid
    log_message "Reniced PID $pid to lowest priority"
    
    # Wait and check if CPU usage improved
    sleep 10
    new_cpu_usage=$(ps -p $pid -o %cpu= | tr -d ' ')
    
    if [ ${new_cpu_usage%.*} -gt $THRESHOLD ]; then
        log_message "Process still consuming high CPU after renice. Sending SIGTERM..."
        kill -15 $pid
        
        # Wait and check if process ended
        sleep 5
        if kill -0 $pid 2>/dev/null; then
            log_message "Process didn't respond to SIGTERM. Sending SIGKILL..."
            kill -9 $pid
        fi
    fi
}

# Main monitoring loop
while true; do
    # Get overall CPU usage
    cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d. -f1)
    
    if [ $cpu_usage -gt $THRESHOLD ]; then
        ALERT_COUNT=$((ALERT_COUNT + 1))
        
        # Get top CPU consuming processes
        top_processes=$(ps aux --sort=-%cpu | head -n 6 | tail -n 5)
        
        log_message "HIGH CPU ALERT #$ALERT_COUNT: ${cpu_usage}%"
        log_message "Top processes:"
        echo "$top_processes" >> $LOG_FILE
        
        # If we've had multiple consecutive alerts, take action
        if [ $ALERT_COUNT -ge $MAX_ALERTS ]; then
            log_message "Multiple consecutive alerts detected. Taking action..."
            
            # Get highest CPU consuming process
            highest_cpu_pid=$(ps aux --sort=-%cpu | awk 'NR==2 {print $2}')
            highest_cpu_usage=$(ps aux --sort=-%cpu | awk 'NR==2 {print $3}')
            
            # Log detailed information about the process
            log_message "Highest CPU consuming process:"
            process_details=$(get_process_details $highest_cpu_pid)
            log_message "$process_details"
            
            # Take action on the process
            handle_high_cpu_process $highest_cpu_pid $highest_cpu_usage
            
            # Reset alert counter
            ALERT_COUNT=0
        fi
        
        # Send email alert if mail is configured
        if command -v mail >/dev/null 2>&1; then
            echo -e "High CPU usage detected: ${cpu_usage}%\n\nTop processes:\n$top_processes\n\nAction taken: $action_taken" | \
            mail -s "High CPU Alert on $(hostname)" $NOTIFICATION_EMAIL
        fi
    else
        ALERT_COUNT=0
    fi
    
    # Also monitor memory usage
    memory_usage=$(free | awk '/Mem:/ {printf("%.2f"), $3/$2 * 100}')
    if [ ${memory_usage%.*} -gt $THRESHOLD ]; then
        log_message "HIGH MEMORY ALERT: ${memory_usage}%"
        top_memory_processes=$(ps aux --sort=-%mem | head -n 6 | tail -n 5)
        log_message "Top memory-consuming processes:"
        echo "$top_memory_processes" >> $LOG_FILE
    fi
    
    sleep $INTERVAL
done