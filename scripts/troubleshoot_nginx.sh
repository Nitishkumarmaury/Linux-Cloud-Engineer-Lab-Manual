#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print section headers
print_header() {
    echo -e "\n${YELLOW}=== $1 ===${NC}"
}

# Function to check command status
check_status() {
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}[✓] $1${NC}"
    else
        echo -e "${RED}[✗] $1${NC}"
    fi
}

print_header "Nginx Troubleshooting Report"
echo "Starting diagnostics at $(date)"

# 1. Service Status
print_header "1. Service Status"
systemctl status nginx
check_status "Service status check"

# 2. Configuration Test
print_header "2. Configuration Test"
nginx -t 2>&1
check_status "Configuration syntax"

# 3. Port Status
print_header "3. Port Status"
netstat -tulpn | grep nginx
check_status "Port binding check"

# 4. Log Analysis
print_header "4. Recent Error Logs"
tail -n 20 /var/log/nginx/error.log
check_status "Log access"

# 5. Resource Usage
print_header "5. Resource Usage"
ps aux | grep nginx | grep -v grep
check_status "Process check"

# 6. Disk Space
print_header "6. Disk Space"
df -h /var/log/nginx
check_status "Disk space check"

# 7. File Permissions
print_header "7. File Permissions"
ls -l /var/www/html
ls -l /etc/nginx/nginx.conf
check_status "Permission check"

# 8. SSL Certificate (if using HTTPS)
if [ -f /etc/nginx/conf.d/default.conf ] && grep -q "ssl_certificate" /etc/nginx/conf.d/default.conf; then
    print_header "8. SSL Certificate Status"
    CERT_PATH=$(grep "ssl_certificate " /etc/nginx/conf.d/default.conf | awk '{print $2}' | sed 's/;//')
    openssl x509 -in $CERT_PATH -text -noout | grep -A 2 "Validity"
    check_status "SSL certificate check"
fi

# 9. SELinux Status (if applicable)
if command -v getenforce >/dev/null 2>&1; then
    print_header "9. SELinux Status"
    getenforce
    check_status "SELinux check"
fi

# 10. Memory Usage
print_header "10. Memory Usage"
free -m
check_status "Memory check"

# 11. System Load
print_header "11. System Load"
uptime
check_status "System load check"

print_header "Summary"
echo "Troubleshooting completed at $(date)"
echo "Review the above output for potential issues"
echo "For detailed logs, check journalctl -u nginx.service"