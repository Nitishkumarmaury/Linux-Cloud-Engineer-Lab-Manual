# Practical 4: Web Server Configuration and Management

## 🎯 Learning Objectives

After completing this practical, you will be able to:
- Install and configure Nginx web server
- Set up virtual hosts and SSL/TLS
- Implement reverse proxy configurations
- Monitor web server performance
- Secure web applications
- Handle load balancing

## 🔧 Technical Skills Covered

- Web server administration
- SSL/TLS configuration
- Reverse proxy setup
- Performance tuning
- Security hardening
- Load balancing

## 📋 Prerequisites

1. Linux system (Ubuntu 20.04 LTS recommended)
2. Root or sudo access
3. Domain name (optional but recommended)
4. Basic networking knowledge

## 🚀 Step-by-Step Implementation Guide

### Step 1: Installing Nginx

```bash
# Update system packages
sudo apt update
sudo apt upgrade -y

# Install Nginx and related tools
sudo apt install -y \
    nginx \
    ssl-cert \
    certbot \
    python3-certbot-nginx \
    apache2-utils

# Check Nginx status
sudo systemctl status nginx
```

**💡 Explanation:**
- `nginx`: Main web server package
- `ssl-cert`: SSL certificate utilities
- `certbot`: Let's Encrypt client
- `apache2-utils`: Useful tools like htpasswd

### Step 2: Basic Configuration

```bash
# Backup default configuration
sudo cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bak

# Create main configuration
sudo tee /etc/nginx/nginx.conf <<EOF
user www-data;
worker_processes auto;
pid /run/nginx.pid;
include /etc/nginx/modules-enabled/*.conf;

events {
    worker_connections 1024;
    multi_accept on;
}

http {
    # Basic Settings
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;

    # SSL Settings
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_prefer_server_ciphers on;
    ssl_ciphers "EECDH+AESGCM:EDH+AESGCM";
    ssl_session_cache shared:SSL:10m;

    # Logging Settings
    access_log /var/log/nginx/access.log;
    error_log /var/log/nginx/error.log;

    # Virtual Host Configs
    include /etc/nginx/conf.d/*.conf;
    include /etc/nginx/sites-enabled/*;
}
EOF

# Test configuration
sudo nginx -t
```

### Step 3: Setting Up Virtual Hosts

```bash
# Create directory structure
sudo mkdir -p /var/www/example.com/html
sudo chown -R $USER:$USER /var/www/example.com/html
sudo chmod -R 755 /var/www/example.com

# Create sample page
sudo tee /var/www/example.com/html/index.html <<EOF
<!DOCTYPE html>
<html>
<head>
    <title>Welcome to example.com!</title>
</head>
<body>
    <h1>Success! Your virtual host is working!</h1>
</body>
</html>
EOF

# Create server block configuration
sudo tee /etc/nginx/sites-available/example.com <<EOF
server {
    listen 80;
    listen [::]:80;
    
    root /var/www/example.com/html;
    index index.html index.htm index.nginx-debian.html;
    
    server_name example.com www.example.com;
    
    location / {
        try_files \$uri \$uri/ =404;
    }
}
EOF

# Enable site
sudo ln -s /etc/nginx/sites-available/example.com /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

### Step 4: SSL/TLS Configuration

```bash
# Install SSL certificate using Let's Encrypt
sudo certbot --nginx -d example.com -d www.example.com

# Auto-renewal configuration
sudo systemctl status certbot.timer

# Test renewal
sudo certbot renew --dry-run
```

### Step 5: Setting Up Reverse Proxy

```bash
# Create reverse proxy configuration
sudo tee /etc/nginx/sites-available/reverse-proxy <<EOF
server {
    listen 80;
    server_name app.example.com;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }
}
EOF

# Enable configuration
sudo ln -s /etc/nginx/sites-available/reverse-proxy /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

### Step 6: Load Balancing Configuration

```bash
# Create upstream configuration
sudo tee /etc/nginx/conf.d/upstream.conf <<EOF
upstream backend {
    server backend1.example.com:8080;
    server backend2.example.com:8080;
    server backend3.example.com:8080;
}

server {
    listen 80;
    server_name loadbalancer.example.com;

    location / {
        proxy_pass http://backend;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }
}
EOF

# Apply configuration
sudo nginx -t
sudo systemctl reload nginx
```

## ✅ Success Criteria

### Required Outcomes
- [x] Nginx installed and running
- [x] Virtual hosts configured
- [x] SSL/TLS implemented
- [x] Reverse proxy working
- [x] Load balancing configured
- [x] Security measures applied

### Security Checklist
- [ ] SSL/TLS properly configured
- [ ] HTTP/2 enabled
- [ ] Security headers implemented
- [ ] Access logs enabled
- [ ] Rate limiting configured
- [ ] DDoS protection implemented

## 🔍 Troubleshooting Guide

### 1. Connection Issues
```bash
# Check Nginx status
sudo systemctl status nginx

# Test configuration
sudo nginx -t

# Check logs
sudo tail -f /var/log/nginx/error.log
sudo tail -f /var/log/nginx/access.log
```

### 2. SSL Problems
```bash
# Verify certificate
sudo certbot certificates

# Test SSL configuration
curl -vI https://example.com

# Check SSL grade
# Use SSL Labs online tool
```

### 3. Performance Issues
```bash
# Check current connections
netstat -an | grep :80 | wc -l

# Monitor Nginx process
top -p $(pgrep nginx | tr "\n" "," | sed 's/,$//')

# Check access patterns
sudo tail -f /var/log/nginx/access.log | ngxtop
```

## 💼 Career Development

### Key Skills Demonstrated
- Web server administration
- SSL/TLS management
- Reverse proxy configuration
- Load balancer setup
- Security implementation

### Interview Topics
1. **Web Server Configuration:**
   - Virtual host setup
   - SSL/TLS implementation
   - Performance optimization
   - Security hardening

2. **Load Balancing:**
   - Algorithms and methods
   - Health checks
   - Session persistence
   - High availability

### Sample Interview Questions
1. Explain Nginx's event-driven architecture
2. How would you secure a web server?
3. Describe load balancing algorithms
4. How do you handle SSL termination?

### Salary Insights (2025)
- Web Administrator: $75,000 - $95,000
- DevOps Engineer: $120,000 - $180,000
- System Engineer: $90,000 - $140,000
- Cloud Architect: $150,000 - $200,000

## 📚 Additional Resources

### Documentation
- [Nginx Documentation](https://nginx.org/en/docs/)
- [Let's Encrypt Documentation](https://letsencrypt.org/docs/)
- [Mozilla SSL Configuration Generator](https://ssl-config.mozilla.org/)

### Practice Materials
- [Nginx Cookbook](https://www.nginx.com/resources/library/complete-nginx-cookbook/)
- [Digital Ocean Tutorials](https://www.digitalocean.com/community/tutorials?q=nginx)

## 🔄 Next Steps

1. Learn advanced Nginx features
2. Study high availability setups
3. Implement monitoring solutions
4. Practice security hardening
5. Explore containerization

## 📝 Practice Exercises

1. Set up a multi-domain server
2. Implement rate limiting
3. Configure caching
4. Set up HTTP/2
5. Create a high-availability setup

Remember: A well-configured web server is crucial for application reliability and security!

This practical demonstrates how to create and schedule automated backups, an essential skill for maintaining data safety in cloud environments.

## Objectives

- Write a backup shell script
- Implement automated scheduling with cron
- Handle backup rotation
- Monitor backup success/failure

## Prerequisites

- Completed Practicals 1-3
- Basic shell scripting knowledge
- Understanding of cron syntax

## Step-by-Step Guide

### 1. Create Backup Directories

```bash
# Create backup directory
sudo mkdir -p /var/backups/website
sudo mkdir -p /var/backups/logs

# Set permissions
sudo chmod 750 /var/backups/website
sudo chmod 750 /var/backups/logs
```

### 2. Create Backup Script

Create the script file:
```bash
sudo vi /usr/local/bin/backup_web.sh
```

Add this content:
```bash
#!/bin/bash

# Configuration
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_DIR="/var/backups/website"
LOG_DIR="/var/backups/logs"
BACKUP_FILE="web-backup-$TIMESTAMP.tar.gz"
LOG_FILE="$LOG_DIR/backup-$TIMESTAMP.log"
MAX_BACKUPS=7

# Ensure backup directory exists
mkdir -p $BACKUP_DIR
mkdir -p $LOG_DIR

# Start logging
exec 1> >(tee -a "$LOG_FILE")
exec 2>&1

echo "Starting backup at $(date)"

# Create backup
echo "Creating backup of /var/www/html"
tar -czf "$BACKUP_DIR/$BACKUP_FILE" /var/www/html
if [ $? -eq 0 ]; then
    echo "Backup successful: $BACKUP_FILE"
else
    echo "Backup failed!"
    exit 1
fi

# Rotate old backups
echo "Rotating old backups..."
ls -1t $BACKUP_DIR/web-backup-* 2>/dev/null | tail -n +$((MAX_BACKUPS + 1)) | xargs -r rm
echo "Backup rotation complete"

# Calculate backup size
BACKUP_SIZE=$(du -h "$BACKUP_DIR/$BACKUP_FILE" | cut -f1)
echo "Backup size: $BACKUP_SIZE"

# Send email notification (if mail is configured)
if command -v mail >/dev/null 2>&1; then
    echo "Backup completed successfully. Size: $BACKUP_SIZE" | mail -s "Website Backup Report" root
fi

echo "Backup process completed at $(date)"
```

### 3. Set Permissions

```bash
# Make script executable
sudo chmod 755 /usr/local/bin/backup_web.sh

# Test run the script
sudo /usr/local/bin/backup_web.sh
```

### 4. Configure Cron Job

```bash
# Edit root's crontab
sudo crontab -e
```

Add this line to run daily at 3 AM:
```
0 3 * * * /usr/local/bin/backup_web.sh
```

### 5. Monitor Backups

Create a backup monitoring script:
```bash
sudo vi /usr/local/bin/check_backups.sh
```

Add this content:
```bash
#!/bin/bash

BACKUP_DIR="/var/backups/website"
LOG_DIR="/var/backups/logs"

# Check for recent backups (last 24 hours)
RECENT_BACKUPS=$(find $BACKUP_DIR -name "web-backup-*" -mtime -1 | wc -l)

if [ $RECENT_BACKUPS -eq 0 ]; then
    echo "WARNING: No recent backups found!"
    exit 1
else
    echo "Found $RECENT_BACKUPS recent backup(s)"
    ls -lh $BACKUP_DIR/web-backup-* | tail -n $RECENT_BACKUPS
fi

# Check backup sizes
LATEST_BACKUP=$(ls -1t $BACKUP_DIR/web-backup-* | head -n1)
BACKUP_SIZE=$(du -h "$LATEST_BACKUP" | cut -f1)
echo "Latest backup size: $BACKUP_SIZE"

# Check available disk space
DISK_SPACE=$(df -h $BACKUP_DIR | awk 'NR==2 {print $4}')
echo "Available disk space: $DISK_SPACE"
```

Make it executable:
```bash
sudo chmod 755 /usr/local/bin/check_backups.sh
```

## Expected Outcomes

- [x] Automated daily backups
- [x] Backup rotation implemented
- [x] Email notifications configured
- [x] Monitoring script functional

## Troubleshooting

### Common Issues

1. **Script Not Running**
   - Check cron service: `systemctl status cron`
   - Verify script permissions
   - Check cron syntax

2. **Backup Failed**
   - Check disk space
   - Verify directory permissions
   - Review backup logs

3. **Email Notifications Not Working**
   - Install postfix or mailutils
   - Configure mail relay
   - Check mail logs

## Backup Best Practices

1. Regular Testing
```bash
# Test backup restoration
sudo tar -xzf /var/backups/website/[BACKUP_FILE] -C /tmp/restore_test
```

2. Monitoring
```bash
# Add to monitoring script crontab
0 9 * * * /usr/local/bin/check_backups.sh
```

3. Off-site Copy
```bash
# Example with rsync (if configured)
rsync -av /var/backups/ backup-server:/backups/
```

## Career Tips

- Understand backup strategies (full, incremental, differential)
- Learn about backup verification and testing
- Document your backup and recovery procedures
- Practice disaster recovery scenarios