# Practical 8: Configuring a Basic Firewall

This practical focuses on implementing network security using UFW (Uncomplicated Firewall) and understanding basic network security concepts.

## Objectives

- Configure UFW firewall
- Implement network security policies
- Monitor network traffic
- Understand firewall logs

## Prerequisites

- Completed Practicals 1-7
- Basic understanding of networking
- Knowledge of common ports and services

## Step-by-Step Guide

### 1. Install and Enable UFW

```bash
# Install UFW
sudo apt update
sudo apt install ufw

# Check UFW status
sudo ufw status verbose
```

### 2. Basic UFW Configuration

```bash
# Set default policies
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Allow SSH (important to do this first!)
sudo ufw allow ssh

# Allow HTTP and HTTPS
sudo ufw allow http
sudo ufw allow https

# Enable UFW
sudo ufw enable
```

### 3. Advanced UFW Rules

```bash
# Allow specific port
sudo ufw allow 8080/tcp

# Allow port range
sudo ufw allow 5000:5100/tcp

# Allow from specific IP
sudo ufw allow from 192.168.1.100

# Allow from subnet to specific port
sudo ufw allow from 192.168.1.0/24 to any port 3306

# Rate limiting (protect against brute force)
sudo ufw limit ssh
```

### 4. Create Firewall Monitoring Script

Create a firewall monitoring script:
```bash
sudo vi /usr/local/bin/monitor_firewall.sh
```

Add this content:
```bash
#!/bin/bash

LOG_FILE="/var/log/ufw.log"
ALERT_LOG="/var/log/firewall_alerts.log"
THRESHOLD=10  # Alert if more than 10 connection attempts per minute

log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> $ALERT_LOG
}

monitor_connections() {
    # Monitor connection attempts
    tail -f $LOG_FILE | while read line; do
        # Count connection attempts in last minute
        attempts=$(grep -c "UFW BLOCK" <(tail -n60 $LOG_FILE))
        
        if [ $attempts -gt $THRESHOLD ]; then
            ip=$(echo $line | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" | head -1)
            log_message "High connection attempts detected from IP: $ip"
            
            # Optional: Block IP automatically
            if [ ! -z "$ip" ]; then
                sudo ufw insert 1 deny from $ip
                log_message "Automatically blocked IP: $ip"
            fi
        fi
    done
}

# Start monitoring
monitor_connections
```

Make it executable:
```bash
sudo chmod +x /usr/local/bin/monitor_firewall.sh
```

### 5. Configure Logging

```bash
# Enable UFW logging
sudo ufw logging on

# Set logging level
sudo ufw logging medium

# View logs
tail -f /var/log/ufw.log
```

### 6. Network Security Monitoring

Install and configure network monitoring tools:
```bash
# Install tools
sudo apt install -y nmap iptraf-ng tcpdump

# Monitor network traffic
sudo iptraf-ng

# Capture packets
sudo tcpdump -i any port 80

# Network scanning (for testing)
sudo nmap -sS -p- localhost
```

## Firewall Policy Template

Create a comprehensive firewall policy:
```bash
#!/bin/bash

# Reset UFW
sudo ufw --force reset

# Default policies
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Essential services
sudo ufw allow ssh
sudo ufw allow http
sudo ufw allow https

# Application-specific rules
sudo ufw allow 3306/tcp  # MySQL
sudo ufw allow 27017/tcp # MongoDB
sudo ufw allow 6379/tcp  # Redis

# Rate limiting
sudo ufw limit ssh

# Enable firewall
sudo ufw --force enable
```

## Expected Outcomes

- [x] UFW properly configured
- [x] Essential services accessible
- [x] Unauthorized access blocked
- [x] Logging and monitoring setup

## Security Best Practices

### 1. Regular Rule Review

```bash
# List all rules with numbers
sudo ufw status numbered

# Review rule details
sudo ufw show added

# Check listening ports
sudo netstat -tulpn
```

### 2. Implement Rate Limiting

```bash
# Rate limit sensitive services
sudo ufw limit ssh
sudo ufw limit 3306/tcp  # MySQL
```

### 3. Geo-IP Blocking

Create a script for Geo-IP blocking:
```bash
#!/bin/bash
# Required: sudo apt install geoip-bin

COUNTRY_CODE="CN"  # Example: Block China
for ip in $(wget -qO- http://www.ipdeny.com/ipblocks/data/countries/$COUNTRY_CODE.zone); do
    sudo ufw deny from $ip
done
```

## Troubleshooting

### Common Issues

1. **Locked Out of SSH**
   - Boot in recovery mode
   - Disable UFW: `ufw disable`
   - Fix rules and re-enable

2. **Service Not Accessible**
   - Check UFW status
   - Verify rule exists
   - Check service is running
   - Verify port is correct

3. **Performance Issues**
   - Check rule order
   - Monitor log size
   - Review rate limiting

## Monitoring Tools

### 1. UFW Status Dashboard

Create a simple dashboard script:
```bash
#!/bin/bash

echo "=== UFW Status Dashboard ==="
echo "Last updated: $(date)"
echo
echo "=== Current Rules ==="
sudo ufw status numbered
echo
echo "=== Recent Blocks ==="
tail -n 10 /var/log/ufw.log | grep "UFW BLOCK"
echo
echo "=== Listening Ports ==="
netstat -tulpn
```

### 2. Traffic Analysis

```bash
# Install traffic analyzer
sudo apt install vnstat

# Monitor traffic
vnstat -l -i eth0
```

## Career Tips

- Understand defense in depth
- Document all firewall changes
- Implement change control
- Learn about network security
- Practice incident response

## Additional Resources

Create a network diagram:
```bash
# Install network mapping tool
sudo apt install nmap graphviz

# Generate network map
sudo nmap -sn 192.168.1.0/24 -oG - | \
awk '/Up$/{print $2}' | \
while read ip; do
    echo "\"Network\" -> \"$ip\";"
done | \
graph-easy --as=boxart
```

This provides a visual representation of your network topology.