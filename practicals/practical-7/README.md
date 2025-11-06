# Practical 7: Identifying High-CPU Processes

This practical focuses on monitoring and managing system resources, particularly CPU usage, which is crucial for maintaining performance in cloud environments.

## Objectives

- Monitor system resource usage
- Identify resource-intensive processes
- Manage process priorities
- Implement resource monitoring tools

## Prerequisites

- Completed Practicals 1-6
- Basic understanding of Linux processes
- Familiarity with monitoring tools

## Step-by-Step Guide

### 1. Install Monitoring Tools

```bash
# Install necessary tools
sudo apt update
sudo apt install -y htop stress sysstat iotop

# Verify installations
which htop stress mpstat iotop
```

### 2. Basic System Monitoring

```bash
# View system resource usage
top

# View formatted process list
htop

# Check CPU statistics
mpstat 1 5

# View memory usage
free -m

# Check load average
uptime
```

### 3. Simulate High CPU Load

```bash
# Create artificial CPU load
stress --cpu 1 --timeout 300 &

# Monitor the impact
top
```

### 4. Process Management

```bash
# List processes by CPU usage
ps aux --sort=-%cpu | head -n 10

# Find specific process
pidof stress

# Check process details
ps -p $(pidof stress) -o pid,ppid,cmd,%cpu,%mem

# Kill high-CPU process
kill -15 $(pidof stress)  # Graceful termination
# or
kill -9 $(pidof stress)   # Force termination
```

### 5. CPU Monitoring Script

Create a CPU monitoring script:
```bash
sudo vi /usr/local/bin/monitor_cpu.sh
```

Add this content:
```bash
#!/bin/bash

THRESHOLD=80  # CPU usage threshold
INTERVAL=5    # Check every 5 seconds
LOG_FILE="/var/log/cpu_monitoring.log"

log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> $LOG_FILE
}

while true; do
    # Get top CPU consuming processes
    processes=$(ps aux --sort=-%cpu | head -n 6 | tail -n 5)
    
    # Get CPU usage percentage
    cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d. -f1)
    
    if [ $cpu_usage -gt $THRESHOLD ]; then
        log_message "HIGH CPU ALERT: ${cpu_usage}%"
        log_message "Top processes:"
        echo "$processes" >> $LOG_FILE
        
        # Optional: Send email alert
        if command -v mail >/dev/null 2>&1; then
            echo -e "High CPU usage detected: ${cpu_usage}%\n\nTop processes:\n$processes" | \
            mail -s "High CPU Alert" root
        fi
    fi
    
    sleep $INTERVAL
done
```

Make it executable:
```bash
sudo chmod +x /usr/local/bin/monitor_cpu.sh
```

### 6. Process Priority Management

```bash
# View process priority (nice value)
ps -el | grep stress

# Start process with lower priority
nice -n 19 stress --cpu 1 &

# Change priority of running process
renice -n 19 -p $(pidof stress)
```

## Expected Outcomes

- [x] Understanding of system resource monitoring
- [x] Ability to identify resource-intensive processes
- [x] Knowledge of process management
- [x] Implementation of monitoring solutions

## Resource Monitoring Best Practices

### 1. Regular Monitoring

Set up regular monitoring with sar:
```bash
# Enable system activity collection
sudo sed -i 's/ENABLED="false"/ENABLED="true"/' /etc/default/sysstat
sudo systemctl restart sysstat

# View CPU statistics
sar -u 1 5

# View memory statistics
sar -r 1 5
```

### 2. Process Limits

Configure process limits in `/etc/security/limits.conf`:
```
* soft nproc 2048
* hard nproc 4096
* soft nofile 4096
* hard nofile 8192
```

### 3. Automated Monitoring

Create a monitoring service:
```bash
sudo vi /etc/systemd/system/cpu-monitor.service
```

Add this content:
```ini
[Unit]
Description=CPU Usage Monitoring Service
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/monitor_cpu.sh
Restart=always

[Install]
WantedBy=multi-user.target
```

Enable and start the service:
```bash
sudo systemctl enable cpu-monitor
sudo systemctl start cpu-monitor
```

## Troubleshooting

### Common Issues

1. **High CPU Usage**
   - Identify the process: `top` or `htop`
   - Check process details: `strace -p PID`
   - Monitor system calls: `ltrace -p PID`

2. **Process Won't Die**
   - Check process state: `ps aux | grep PID`
   - Send SIGKILL: `kill -9 PID`
   - Check for zombie processes: `ps aux | grep Z`

3. **System Unresponsive**
   - Use Magic SysRq keys (if enabled)
   - Check load average: `uptime`
   - Monitor I/O: `iotop`

## Performance Analysis Tools

1. **CPU Profiling**
```bash
# Install perf
sudo apt install linux-tools-common linux-tools-generic

# Profile a process
sudo perf top -p PID
```

2. **System Statistics**
```bash
# Collect system statistics
vmstat 1 10

# I/O statistics
iostat -x 1 10
```

3. **Network Usage**
```bash
# Network statistics
netstat -tulpn

# Network traffic
iftop
```

## Career Tips

- Learn to read and interpret system metrics
- Understand the relationship between resources
- Practice identifying performance bottlenecks
- Document your monitoring setup
- Create automated alerts for critical issues

## Additional Resources

Create a system monitoring dashboard:
```bash
# Install monitoring stack (e.g., Prometheus + Grafana)
# This is a simplified example
sudo docker run -d --name prometheus -p 9090:9090 prom/prometheus
sudo docker run -d --name grafana -p 3000:3000 grafana/grafana
```

This provides a visual interface for monitoring system resources.