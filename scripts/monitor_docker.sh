#!/bin/bash

#=================================================================
# Practical 9: Container Management
# Purpose: Monitor Docker containers and resource usage
# Created: November 7, 2025
#=================================================================

# Configuration
LOG_FILE="/var/log/docker_monitor.log"
ALERT_LOG="/var/log/docker_alerts.log"
THRESHOLD_CPU=80      # CPU threshold percentage
THRESHOLD_MEM=80      # Memory threshold percentage
THRESHOLD_DISK=80     # Disk usage threshold percentage
CHECK_INTERVAL=60     # Check every 60 seconds
EMAIL_TO="root"       # Alert email recipient

# Function to log messages
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a $LOG_FILE
}

# Function to send alerts
send_alert() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - ALERT: $1" | tee -a $ALERT_LOG
    if command -v mail >/dev/null 2>&1; then
        echo "$1" | mail -s "Docker Alert on $(hostname)" $EMAIL_TO
    fi
}

# Function to check container health
check_container_health() {
    local container=$1
    local status=$(docker inspect --format='{{.State.Status}}' $container 2>/dev/null)
    local health=$(docker inspect --format='{{.State.Health.Status}}' $container 2>/dev/null)
    
    if [ "$status" != "running" ]; then
        send_alert "Container $container is not running (Status: $status)"
        return 1
    fi
    
    if [ ! -z "$health" ] && [ "$health" != "healthy" ]; then
        send_alert "Container $container is unhealthy (Health: $health)"
        return 1
    fi
    
    return 0
}

# Function to check resource usage
check_resources() {
    local container=$1
    
    # Get CPU usage percentage
    local cpu_usage=$(docker stats --no-stream --format "{{.CPUPerc}}" $container | sed 's/%//')
    
    # Get memory usage percentage
    local mem_usage=$(docker stats --no-stream --format "{{.MemPerc}}" $container | sed 's/%//')
    
    # Get container disk usage
    local disk_usage=$(docker system df -v | grep $container | awk '{print $5}' | sed 's/%//')
    
    if (( $(echo "$cpu_usage > $THRESHOLD_CPU" | bc -l) )); then
        send_alert "High CPU usage in container $container: ${cpu_usage}%"
    fi
    
    if (( $(echo "$mem_usage > $THRESHOLD_MEM" | bc -l) )); then
        send_alert "High memory usage in container $container: ${mem_usage}%"
    fi
    
    if [ ! -z "$disk_usage" ] && (( $(echo "$disk_usage > $THRESHOLD_DISK" | bc -l) )); then
        send_alert "High disk usage in container $container: ${disk_usage}%"
    fi
}

# Function to check container logs for errors
check_logs() {
    local container=$1
    local error_count=$(docker logs --since 1m $container 2>&1 | grep -ic "error\|exception\|fatal")
    
    if [ $error_count -gt 0 ]; then
        send_alert "Found $error_count error(s) in container $container logs"
    fi
}

# Function to generate report
generate_report() {
    local report_file="/tmp/docker_report_$(date +%Y%m%d_%H%M%S).txt"
    
    echo "Docker Container Report - $(date)" > $report_file
    echo "================================" >> $report_file
    
    echo -e "\nContainer Status:" >> $report_file
    docker ps -a --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" >> $report_file
    
    echo -e "\nResource Usage:" >> $report_file
    docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}\t{{.BlockIO}}" >> $report_file
    
    echo -e "\nDisk Usage:" >> $report_file
    docker system df -v >> $report_file
    
    echo -e "\nNetworking:" >> $report_file
    docker network ls >> $report_file
    
    # Archive old reports (keep last 7 days)
    find /tmp -name "docker_report_*" -mtime +7 -delete
    
    log_message "Generated report: $report_file"
}

# Main monitoring loop
log_message "Starting Docker monitoring..."

while true; do
    # Check if Docker daemon is running
    if ! docker info >/dev/null 2>&1; then
        send_alert "Docker daemon is not running!"
        sleep $CHECK_INTERVAL
        continue
    fi
    
    # Get list of running containers
    containers=$(docker ps --format "{{.Names}}")
    
    if [ -z "$containers" ]; then
        log_message "No running containers found"
    else
        for container in $containers; do
            # Check container health
            check_container_health $container
            
            # Check resource usage
            check_resources $container
            
            # Check logs for errors
            check_logs $container
        done
    fi
    
    # Generate hourly report
    if [ $(date +%M) -eq 0 ]; then
        generate_report
    fi
    
    # Check overall Docker system
    docker_info=$(docker info --format '{{.ServerVersion}}')
    log_message "Docker version: $docker_info"
    
    # Check system storage
    docker system df | grep -q "^TYPE.*SIZE" || send_alert "Unable to get system storage information"
    
    sleep $CHECK_INTERVAL
done