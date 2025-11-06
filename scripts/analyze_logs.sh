#!/bin/bash

#=================================================================
# Practical 6: Log Analysis and Management
# Purpose: Analyze system and application logs for issues
# Created: November 7, 2025
#=================================================================

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

# Identify potential security issues
echo -e "\nPotential Security Issues:" >> $REPORT_FILE
grep -i "union\|select\|insert\|admin\|wp-login" $LOG_FILE | tail -n 10 >> $REPORT_FILE

# Calculate average response time
echo -e "\nAverage Response Time:" >> $REPORT_FILE
awk '{sum+=$NF; count++} END {print sum/count " seconds"}' $LOG_FILE >> $REPORT_FILE

echo "Report generated at: $REPORT_FILE"