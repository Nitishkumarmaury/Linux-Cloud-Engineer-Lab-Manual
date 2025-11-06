# Practical 3: System Resource Monitoring and Performance Analysis

## 🎯 Learning Objectives

After completing this practical, you will be able to:
- Monitor system resources (CPU, memory, disk, network)
- Use essential Linux monitoring tools
- Set up monitoring alerts
- Analyze system performance
- Create monitoring scripts

## 🔧 Technical Skills Covered

- System resource monitoring
- Performance analysis
- Shell scripting
- Log analysis
- Alert configuration
- Resource optimization

## 📋 Prerequisites

1. Linux system (Ubuntu 20.04 LTS recommended)
2. Root or sudo access
3. Basic command line knowledge
4. Text editor (vim/nano)

## 🚀 Step-by-Step Implementation Guide

### Step 1: Installing Essential Monitoring Tools

```bash
# Update package list
sudo apt update

# Install monitoring tools
sudo apt install -y \
    sysstat \
    htop \
    iotop \
    nethogs \
    iftop \
    atop \
    nmon \
    telegraf

# Enable sysstat data collection
sudo systemctl enable sysstat
sudo systemctl start sysstat
```

**💡 Explanation:**
- `sysstat`: Collection of performance monitoring tools
- `htop`: Interactive process viewer
- `iotop`: I/O monitoring tool
- `nethogs`: Net bandwidth monitor per process

### Step 2: Basic System Monitoring

```bash
# View system resources in real-time
top

# Interactive process viewer (better alternative to top)
htop

# Memory information
free -h
vmstat 1

# Disk usage
df -h
du -sh /*

# CPU information
mpstat 1
```

**💡 Key Metrics:**
- CPU usage percentage
- Memory usage and swap
- Disk space utilization
- Process resource consumption

### Step 3: Advanced Performance Monitoring

```bash
# CPU detailed statistics
sar -u 1 5

# Memory statistics
sar -r 1 5

# I/O statistics
iostat -xz 1

# Network statistics
sar -n DEV 1
```

**💡 Understanding Output:**
- CPU: %user, %system, %iowait
- Memory: free, used, cached
- I/O: reads/s, writes/s
- Network: packets/s, bytes/s

### Step 4: Creating a Basic Monitoring Script

```bash
#!/bin/bash

# monitor_resources.sh
LOG_FILE="/var/log/system_monitor.log"
ALERT_FILE="/var/log/system_alerts.log"

# Thresholds
CPU_THRESHOLD=80
MEM_THRESHOLD=80
DISK_THRESHOLD=90

# Function to log messages
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a $LOG_FILE
}

# Function to send alerts
alert() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - ALERT: $1" | tee -a $ALERT_FILE
    # Add email notification here if needed
}

# Check CPU usage
check_cpu() {
    CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d. -f1)
    log_message "CPU Usage: $CPU_USAGE%"
    
    if [ $CPU_USAGE -gt $CPU_THRESHOLD ]; then
        alert "High CPU usage: $CPU_USAGE%"
    fi
}

# Check memory usage
check_memory() {
    MEM_USAGE=$(free | grep Mem | awk '{print $3/$2 * 100.0}' | cut -d. -f1)
    log_message "Memory Usage: $MEM_USAGE%"
    
    if [ $MEM_USAGE -gt $MEM_THRESHOLD ]; then
        alert "High memory usage: $MEM_USAGE%"
    fi
}

# Check disk usage
check_disk() {
    DISK_USAGE=$(df / | tail -1 | awk '{print $5}' | cut -d% -f1)
    log_message "Disk Usage: $DISK_USAGE%"
    
    if [ $DISK_USAGE -gt $DISK_THRESHOLD ]; then
        alert "High disk usage: $DISK_USAGE%"
    fi
}

# Main monitoring loop
while true; do
    check_cpu
    check_memory
    check_disk
    sleep 300  # Check every 5 minutes
done
```

### Step 5: Setting Up System Logging

```bash
# Configure rsyslog for custom logging
sudo tee /etc/rsyslog.d/monitoring.conf <<EOF
local0.* /var/log/monitoring.log
EOF

# Restart rsyslog
sudo systemctl restart rsyslog

# View logs
tail -f /var/log/monitoring.log
```

### Step 6: Implementing Process Monitoring

```bash
# Monitor specific process
watch -n 1 'ps -p $(pgrep nginx) -o %cpu,%mem,cmd'

# Track system load
watch -n 1 'cat /proc/loadavg'

# Monitor network connections
watch -n 1 'netstat -ant | grep ESTABLISHED | wc -l'
```

## ✅ Success Criteria

### Required Outcomes
- [x] Monitoring tools installed and configured
- [x] Resource monitoring script created
- [x] Alerts working properly
- [x] Logging system configured
- [x] Performance metrics collected

### Monitoring Checklist
- [ ] CPU utilization tracking
- [ ] Memory usage monitoring
- [ ] Disk space alerts
- [ ] Network performance metrics
- [ ] Process monitoring
- [ ] Alert thresholds configured

## 🔍 Troubleshooting Guide

### 1. High CPU Usage
```bash
# Find CPU-intensive processes
top -c -o %CPU

# Check process tree
pstree -p

# Track CPU statistics
mpstat -P ALL 1
```

### 2. Memory Issues
```bash
# Check memory stats
vmstat 1

# View detailed memory info
cat /proc/meminfo

# Find memory-hungry processes
ps aux --sort=-%mem | head -n 10
```

### 3. Disk Problems
```bash
# Check I/O statistics
iostat -xz 1

# Find large files/directories
du -h / | grep '^[0-9.]*G'

# Track disk activity
iotop -o
```

## 💼 Career Development

### Key Skills Demonstrated
- System monitoring
- Performance analysis
- Shell scripting
- Problem diagnosis
- Resource optimization

### Interview Topics
1. **System Monitoring:**
   - Key performance metrics
   - Monitoring tools and usage
   - Alert thresholds
   - Performance optimization

2. **Troubleshooting:**
   - Common performance issues
   - Diagnostic approaches
   - Root cause analysis
   - Solution implementation

### Sample Interview Questions
1. How do you identify performance bottlenecks?
2. What metrics are crucial for system health?
3. Explain load average in Linux
4. How do you handle resource constraints?

### Salary Insights (2025)
- System Administrator: $80,000 - $120,000
- Performance Engineer: $100,000 - $150,000
- DevOps Engineer: $130,000 - $180,000
- Site Reliability Engineer: $140,000 - $200,000

## 📚 Additional Resources

### Documentation
- [Linux Performance](https://www.brendangregg.com/linuxperf.html)
- [Sysstat Documentation](http://sebastien.godard.pagesperso-orange.fr/)
- [Monitoring Best Practices](https://www.kernel.org/doc/html/latest/admin-guide/perf-security.html)

### Practice Materials
- [Linux Performance Tools](https://netflixtechblog.com/linux-performance-analysis-in-60-000-milliseconds-accc10403c55)
- [Performance Tuning Guide](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/performance_tuning_guide/index)

## 🔄 Next Steps

1. Learn advanced monitoring tools
2. Study system optimization techniques
3. Implement automated reporting
4. Explore cloud monitoring solutions
5. Practice performance tuning

## 📝 Practice Exercises

1. Set up comprehensive monitoring for a web server
2. Create custom monitoring dashboards
3. Implement automated alert responses
4. Analyze and optimize system performance
5. Build a monitoring stack with visualization

Remember: Effective monitoring is crucial for system reliability and performance!

## Prerequisites

- Completed Practical 1 & 2
- Understanding of Linux file permissions
- Familiarity with command line

## Step-by-Step Guide

### 1. Create Project Groups

```bash
# Create groups for different teams
sudo groupadd developers
sudo groupadd testers

# Verify group creation
grep 'developers\|testers' /etc/group
```

### 2. Create Team Members

```bash
# Create developer user
sudo adduser dev_user
sudo usermod -aG developers dev_user

# Create tester user
sudo adduser test_user
sudo usermod -aG testers test_user

# Verify user creation and group membership
id dev_user
id test_user
```

### 3. Project Directory Setup

```bash
# Create project directory
sudo mkdir -p /opt/my_project

# Set ownership
sudo chown root:developers /opt/my_project

# Set permissions (rwxrwxr-x)
sudo chmod 775 /opt/my_project
```

### 4. Create Test Files

```bash
# Switch to developer user
su - dev_user

# Create test file
touch /opt/my_project/dev_file.txt
echo "Developer test file" > /opt/my_project/dev_file.txt

# Exit dev_user
exit

# Try as test user
su - test_user
touch /opt/my_project/test_file.txt  # This should fail
```

### 5. Verify Permissions

```bash
# Check directory permissions
ls -l /opt | grep my_project

# Check file permissions
ls -l /opt/my_project/
```

## Understanding Permissions

### Numeric Permission Breakdown

775 permissions explained:
- 7 (owner): read (4) + write (2) + execute (1) = 7
- 7 (group): read (4) + write (2) + execute (1) = 7
- 5 (others): read (4) + execute (1) = 5

### Special Permissions

```bash
# Set SGID bit (files inherit group ownership)
sudo chmod g+s /opt/my_project

# Add sticky bit (only owner can delete files)
sudo chmod +t /opt/my_project
```

## File Access Matrix

| User Type  | Read | Write | Execute |
|------------|------|-------|---------|
| Root       | Yes  | Yes   | Yes     |
| Developers | Yes  | Yes   | Yes     |
| Testers    | Yes  | No    | Yes     |
| Others     | Yes  | No    | Yes     |

## Expected Outcomes

- [x] Groups created and verified
- [x] Users added to appropriate groups
- [x] Project directory with correct permissions
- [x] Developers can create/modify files
- [x] Testers can read but not modify
- [x] Others have limited access

## Troubleshooting

### Common Issues

1. **Permission Denied**
   - Verify user is in correct group
   - Check directory permissions
   - Ensure parent directories are accessible

2. **Group Access Not Working**
   - User might need to log out and back in
   - Verify group exists and user is member
   - Check if group has required permissions

3. **Cannot Create Files**
   - Check directory write permissions
   - Verify ownership and group membership
   - Ensure proper parent directory permissions

## Security Best Practices

1. Follow Principle of Least Privilege
```bash
# Audit user permissions regularly
sudo find /opt/my_project -type f -ls
```

2. Regular Group Membership Review
```bash
# List all group members
getent group developers
getent group testers
```

3. Monitor File Access
```bash
# Install audit daemon
sudo apt install auditd

# Monitor directory access
sudo auditctl -w /opt/my_project -p warx
```

## Career Tips

- Document your permission schemes
- Understand and explain your security decisions
- Learn to troubleshoot permission issues
- Practice using access control lists (ACLs)