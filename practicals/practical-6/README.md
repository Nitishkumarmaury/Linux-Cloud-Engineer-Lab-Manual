# Practical 6: Troubleshooting a "Crashed" Service

This practical focuses on systematic service troubleshooting, a critical skill for maintaining reliable cloud applications.

## Objectives

- Understand service management with systemd
- Diagnose service failures
- Read and interpret service logs
- Apply systematic troubleshooting methodology

## Prerequisites

- Completed Practicals 1-5
- Understanding of Linux services
- Familiarity with systemd
- Basic knowledge of logging systems

## Step-by-Step Guide

### 1. Understanding Service Status

```bash
# Check Nginx service status
sudo systemctl status nginx

# View service unit file
systemctl cat nginx

# List all running services
systemctl list-units --type=service --state=running
```

### 2. Simulating Service Issues

```bash
# Stop the service
sudo systemctl stop nginx

# Verify it's stopped
sudo systemctl status nginx

# Try to access website
curl http://localhost
```

### 3. Systematic Troubleshooting

Create a troubleshooting script:
```bash
sudo vi /usr/local/bin/troubleshoot_nginx.sh
```

Add this content:
```bash
#!/bin/bash

echo "=== Nginx Troubleshooting Report ==="
echo "Running diagnostics..."

# Check if service is running
echo -e "\n1. Service Status:"
systemctl status nginx

# Check configuration
echo -e "\n2. Configuration Test:"
nginx -t

# Check port binding
echo -e "\n3. Port Status:"
netstat -tulpn | grep nginx

# Check logs
echo -e "\n4. Recent Error Logs:"
tail -n 20 /var/log/nginx/error.log

# Check resource usage
echo -e "\n5. Resource Usage:"
ps aux | grep nginx

# Check disk space
echo -e "\n6. Disk Space:"
df -h /var/log/nginx

# Check file permissions
echo -e "\n7. File Permissions:"
ls -l /var/www/html
ls -l /etc/nginx/nginx.conf

echo -e "\nTroubleshooting complete."
```

Make it executable:
```bash
sudo chmod +x /usr/local/bin/troubleshoot_nginx.sh
```

### 4. Log Analysis

```bash
# View systemd journal logs
sudo journalctl -u nginx.service

# View recent logs
sudo journalctl -u nginx.service -n 50

# Follow new log entries
sudo journalctl -u nginx.service -f

# View logs since last boot
sudo journalctl -u nginx.service -b
```

### 5. Common Service Issues

#### Config File Issues
```bash
# Backup config
sudo cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bak

# Test configuration
sudo nginx -t

# View config
sudo less /etc/nginx/nginx.conf
```

#### Permission Issues
```bash
# Check nginx user permissions
sudo -u www-data ls -l /var/www/html

# Fix common permission issues
sudo chown -R www-data:www-data /var/www/html
sudo chmod -R 755 /var/www/html
```

#### Port Binding Issues
```bash
# Check port usage
sudo netstat -tulpn | grep :80

# Check SELinux if applicable
sestatus
```

## Expected Outcomes

- [x] Understanding of service management
- [x] Ability to diagnose service issues
- [x] Knowledge of log analysis
- [x] Systematic troubleshooting approach

## Common Service States

| State | Meaning | Common Causes |
|-------|---------|---------------|
| active (running) | Service is running normally | N/A |
| active (exited) | Service completed successfully | One-time tasks |
| failed | Service failed to start | Config errors, permissions |
| inactive | Service is not running | Manually stopped |
| activating | Service is starting | N/A |
| deactivating | Service is stopping | N/A |

## Troubleshooting Methodology

1. **Identify the Problem**
   - Check service status
   - Review error messages
   - Verify symptoms

2. **Gather Information**
   - Check logs
   - Review configurations
   - Check system resources

3. **Form Hypothesis**
   - Based on evidence
   - Consider common causes
   - Review similar issues

4. **Test Solution**
   - Make one change at a time
   - Document changes
   - Verify fix works

5. **Prevent Recurrence**
   - Update documentation
   - Add monitoring
   - Implement alerts

## Best Practices

1. Configuration Management
```bash
# Always backup configs before changes
sudo cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.$(date +%Y%m%d)
```

2. Log Management
```bash
# Rotate logs properly
sudo logrotate -f /etc/logrotate.d/nginx
```

3. Service Monitoring
```bash
# Set up service monitoring
sudo systemctl enable nginx.service
sudo systemctl enable nginx.service --now
```

## Career Tips

- Learn to read and understand error messages
- Document your troubleshooting steps
- Create troubleshooting runbooks
- Practice systematic problem-solving
- Understand service dependencies

## Additional Resources

Create a service dependency map:
```bash
# Install systemd-analyze
sudo apt install systemd-analyze

# View service dependencies
systemd-analyze dot nginx.service | dot -Tsvg > nginx-deps.svg
```

This will create a visual representation of service dependencies, useful for documentation and troubleshooting.