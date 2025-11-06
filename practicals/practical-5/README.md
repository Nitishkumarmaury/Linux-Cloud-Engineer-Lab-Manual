# Practical 5: Real-Time Log Monitoring & Analysis

This practical focuses on essential log monitoring and analysis skills required for troubleshooting in cloud environments.

## Objectives

- Monitor real-time log files
- Analyze web server access logs
- Parse and filter log data
- Create basic log analysis scripts

## Prerequisites

- Completed Practicals 1-4
- Nginx web server running
- Basic understanding of regular expressions
- Familiarity with text processing tools

## Step-by-Step Guide

### 1. Basic Log Monitoring

```bash
# View real-time Nginx access logs
sudo tail -f /var/log/nginx/access.log

# View real-time error logs
sudo tail -f /var/log/nginx/error.log

# View system logs
sudo tail -f /var/log/syslog
```

### 2. Generate Test Log Data

```bash
# Install Apache Bench for testing
sudo apt install apache2-utils -y

# Generate test traffic
ab -n 1000 -c 10 http://localhost/

# Try some 404 errors
curl http://localhost/nonexistent-page
curl http://localhost/test-404
```

### 3. Basic Log Analysis

```bash
# Count total requests
wc -l /var/log/nginx/access.log

# Find all 404 errors
grep " 404 " /var/log/nginx/access.log

# Find all 500 errors
grep " 500 " /var/log/nginx/access.log

# Count requests by status code
cut -d '"' -f3 /var/log/nginx/access.log | cut -d ' ' -f2 | sort | uniq -c | sort -rn
```

### 4. Advanced Log Analysis

Create a log analysis script:
```bash
sudo vi /usr/local/bin/analyze_logs.sh
```

Add this content:
```bash
#!/bin/bash

LOG_FILE="/var/log/nginx/access.log"
REPORT_FILE="/var/log/nginx/analysis_$(date +%Y%m%d).txt"

echo "Log Analysis Report - $(date)" > $REPORT_FILE
echo "============================" >> $REPORT_FILE

# Top 10 IP addresses
echo -e "\nTop 10 IP Addresses:" >> $REPORT_FILE
awk '{print $1}' $LOG_FILE | sort | uniq -c | sort -nr | head -n 10 >> $REPORT_FILE

# HTTP Status Code Distribution
echo -e "\nHTTP Status Code Distribution:" >> $REPORT_FILE
awk '{print $9}' $LOG_FILE | sort | uniq -c | sort -nr >> $REPORT_FILE

# Most Requested Pages
echo -e "\nMost Requested Pages:" >> $REPORT_FILE
awk -F'"' '{print $2}' $LOG_FILE | cut -d' ' -f2 | sort | uniq -c | sort -nr | head -n 10 >> $REPORT_FILE

# Traffic by Hour
echo -e "\nTraffic by Hour:" >> $REPORT_FILE
awk '{print $4}' $LOG_FILE | cut -d: -f2 | sort | uniq -c >> $REPORT_FILE

# 404 Errors
echo -e "\n404 Errors:" >> $REPORT_FILE
grep " 404 " $LOG_FILE | awk '{print $7}' | sort | uniq -c | sort -nr | head -n 10 >> $REPORT_FILE

echo "Report generated at: $REPORT_FILE"
```

Make the script executable:
```bash
sudo chmod +x /usr/local/bin/analyze_logs.sh
```

### 5. Real-Time Monitoring Script

Create a real-time monitoring script:
```bash
sudo vi /usr/local/bin/monitor_nginx.sh
```

Add this content:
```bash
#!/bin/bash

LOG_FILE="/var/log/nginx/access.log"
ALERT_THRESHOLD=10  # Alerts if more than 10 errors per minute

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

# Function to show live statistics
show_stats() {
    while true; do
        clear
        echo "=== Nginx Real-Time Statistics ==="
        echo "Last 10 requests:"
        tail -n10 $LOG_FILE
        echo -e "\nError distribution (last minute):"
        tail -n60 $LOG_FILE | cut -d '"' -f3 | cut -d ' ' -f2 | sort | uniq -c
        sleep 5
    done
}

# Run monitoring functions
show_stats & monitor_errors
```

Make it executable:
```bash
sudo chmod +x /usr/local/bin/monitor_nginx.sh
```

## Expected Outcomes

- [x] Understanding of log file locations and formats
- [x] Ability to monitor logs in real-time
- [x] Basic log analysis skills
- [x] Automated monitoring setup

## Log File Locations

Important log files:
```
/var/log/nginx/access.log    # Web server access logs
/var/log/nginx/error.log     # Web server error logs
/var/log/syslog             # System logs
/var/log/auth.log           # Authentication logs
```

## Troubleshooting

### Common Issues

1. **Permission Denied**
   - Verify user has sudo access
   - Check file permissions
   - Use sudo when needed

2. **Log Rotation Issues**
   - Check logrotate configuration
   - Verify log rotation schedule
   - Monitor disk space usage

3. **Missing Logs**
   - Verify logging is enabled
   - Check log paths in configuration
   - Ensure service is running

## Log Analysis Best Practices

1. Regular Monitoring
```bash
# Add to crontab for daily analysis
0 0 * * * /usr/local/bin/analyze_logs.sh
```

2. Log Rotation
```bash
# Check logrotate configuration
cat /etc/logrotate.d/nginx
```

3. Disk Space Management
```bash
# Monitor log directory size
du -sh /var/log/nginx/
```

## Advanced Analysis Tips

1. One-liner for response time analysis:
```bash
awk '{print $NF}' /var/log/nginx/access.log | sort -n | uniq -c
```

2. Find suspicious activity:
```bash
grep -i "union\|select\|insert" /var/log/nginx/access.log
```

3. Traffic spike detection:
```bash
awk '{print $4}' /var/log/nginx/access.log | cut -d: -f2 | sort | uniq -c
```

## Career Tips

- Learn common log patterns and formats
- Understand basic log analysis tools
- Practice creating monitoring scripts
- Study security-related log patterns
- Learn to use log management tools (ELK Stack)