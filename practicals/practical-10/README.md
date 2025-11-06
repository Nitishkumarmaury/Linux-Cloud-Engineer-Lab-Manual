# Practical 10: Multi-VM Infrastructure Management

## 🎯 Learning Objectives

After completing this practical, you will be able to:
- Set up and manage multiple VMs
- Configure network communication
- Implement load balancing
- Monitor distributed systems
- Manage centralized logging
- Implement high availability

## 🔧 Technical Skills Covered

- Multi-VM management
- Network configuration
- Load balancing
- Distributed monitoring
- High availability
- Infrastructure scaling

## 📋 Prerequisites

1. Multiple Linux VMs (Ubuntu 20.04 LTS recommended)
2. Root or sudo access on all VMs
3. Network connectivity between VMs
4. Basic understanding of distributed systems

## 🚀 Step-by-Step Implementation Guide

### Step 1: Setting Up the Infrastructure

```bash
# Create three VMs: web, app, and database servers
# Example using GCP (adjust as needed for your cloud provider)
gcloud compute instances create web-server-1 \
    --machine-type=e2-medium \
    --zone=us-central1-a \
    --image-family=ubuntu-2004-lts \
    --image-project=ubuntu-os-cloud

gcloud compute instances create app-server-1 \
    --machine-type=e2-medium \
    --zone=us-central1-a \
    --image-family=ubuntu-2004-lts \
    --image-project=ubuntu-os-cloud

gcloud compute instances create db-server-1 \
    --machine-type=e2-medium \
    --zone=us-central1-a \
    --image-family=ubuntu-2004-lts \
    --image-project=ubuntu-os-cloud
```

### Step 2: Network Configuration

```bash
# Set up private network
gcloud compute networks create private-network

# Create firewall rules
gcloud compute firewall-rules create allow-internal \
    --network private-network \
    --allow tcp:0-65535,udp:0-65535,icmp \
    --source-ranges 10.0.0.0/8

# Configure load balancer
gcloud compute forwarding-rules create web-lb \
    --region=us-central1 \
    --ports=80 \
    --target-pool web-pool
```

### Step 3: Monitoring Setup

```bash
# Install monitoring tools on each server
for server in web-server-1 app-server-1 db-server-1; do
    ssh $server "sudo apt update && sudo apt install -y \
        prometheus-node-exporter \
        collectd \
        grafana"
done

# Configure centralized logging
sudo tee /etc/rsyslog.d/30-remote.conf <<EOF
*.* @@log-server:514
EOF

sudo systemctl restart rsyslog
```

### Step 4: High Availability Configuration

```bash
# Install and configure HAProxy
sudo apt install -y haproxy

# Configure HAProxy
sudo tee /etc/haproxy/haproxy.cfg <<EOF
global
    log /dev/log local0
    log /dev/log local1 notice
    chroot /var/lib/haproxy
    stats socket /run/haproxy/admin.sock mode 660 level admin expose-fd listeners
    stats timeout 30s
    user haproxy
    group haproxy
    daemon

defaults
    log global
    mode http
    option httplog
    option dontlognull
    timeout connect 5000
    timeout client  50000
    timeout server  50000

frontend http_front
    bind *:80
    default_backend http_back

backend http_back
    balance roundrobin
    option httpchk HEAD /
    server web1 web-server-1:80 check
    server web2 web-server-2:80 check
EOF

sudo systemctl restart haproxy
```

### Step 5: Backup Strategy

```bash
# Install backup tools
sudo apt install -y restic

# Initialize backup repository
restic init --repo /backup/

# Create backup script
cat > backup.sh <<EOF
#!/bin/bash
# Backup important directories
restic -r /backup/ backup /var/www/html /etc /var/lib/mysql
# Keep only last 7 daily, 4 weekly, and 6 monthly backups
restic -r /backup/ forget --keep-daily 7 --keep-weekly 4 --keep-monthly 6
EOF

chmod +x backup.sh

# Add to crontab
(crontab -l 2>/dev/null; echo "0 2 * * * /root/backup.sh") | crontab -
```

### Step 6: Disaster Recovery Plan

1. Data Backup Verification
```bash
# Verify backup integrity
restic -r /backup/ check

# Test restore procedure
restic -r /backup/ restore latest --target /tmp/restore-test
```

2. Service Recovery Procedure
```bash
# Create recovery script
cat > recover-service.sh <<EOF
#!/bin/bash
SERVICE=\$1

case \$SERVICE in
    "web")
        systemctl restart nginx
        ;;
    "app")
        systemctl restart application
        ;;
    "db")
        systemctl restart mysql
        ;;
esac

# Verify service status
systemctl status \$SERVICE
EOF

chmod +x recover-service.sh
```

## 🔍 Monitoring and Alerting

### 1. Set up Prometheus Alert Rules

```yaml
# /etc/prometheus/alerts.yml
groups:
- name: example
  rules:
  - alert: HighCPUUsage
    expr: 100 - (avg by(instance) (rate(node_cpu_seconds_total{mode="idle"}[2m])) * 100) > 80
    for: 5m
    labels:
      severity: warning
    annotations:
      summary: High CPU usage detected
```

### 2. Configure Grafana Dashboard

```bash
# Import dashboard
curl -X POST -H "Content-Type: application/json" -d '{
  "dashboard": {
    "id": null,
    "title": "System Overview",
    "panels": [
      {
        "title": "CPU Usage",
        "type": "graph",
        "datasource": "Prometheus"
      }
    ]
  }
}' http://localhost:3000/api/dashboards/db
```

## 📊 Salary Insights (2025)

- Junior Infrastructure Engineer: $75,000 - $95,000
- Senior Infrastructure Engineer: $110,000 - $160,000
- Infrastructure Architect: $140,000 - $200,000
- Site Reliability Engineer: $120,000 - $180,000

## 💡 Pro Tips

1. Always implement infrastructure as code
2. Use configuration management tools
3. Implement proper monitoring and alerting
4. Regular backup testing is crucial
5. Document all procedures and configurations
6. Implement automated failover testing

## 🎓 Career Path Progression

1. Junior Infrastructure Engineer
   - Focus on basic VM management
   - Learn monitoring tools
   - Understand networking basics

2. Infrastructure Engineer
   - Implement HA solutions
   - Manage complex networks
   - Handle backup and DR

3. Senior Infrastructure Engineer
   - Design scalable architectures
   - Implement security measures
   - Lead infrastructure projects

4. Infrastructure Architect
   - Design enterprise solutions
   - Define best practices
   - Strategic planning

## 🔗 Additional Resources

1. [Google Cloud Documentation](https://cloud.google.com/docs)
2. [HAProxy Documentation](http://www.haproxy.org/#docs)
3. [Prometheus Documentation](https://prometheus.io/docs/introduction/overview/)
4. [Grafana Documentation](https://grafana.com/docs/)
5. [Infrastructure as Code Best Practices](https://docs.microsoft.com/en-us/azure/architecture/framework/devops/automation-infrastructure)

## 🎯 Next Steps

1. Learn Terraform for infrastructure as code
2. Explore Kubernetes for container orchestration
3. Study site reliability engineering practices
4. Implement GitOps workflows
5. Explore cloud-native architectures
frontend http_front
    bind *:80
    default_backend http_back

backend http_back
    balance roundrobin
    server web1 web-server-1:80 check
    server web2 web-server-2:80 check
EOF

sudo systemctl restart haproxy
```

[Content continues with detailed sections for Backup Strategy, Security Implementation, Monitoring Setup, etc...]

This practical focuses on deploying a distributed web application across multiple VMs, simulating a real-world production environment.

## Objectives

- Set up multiple VMs with different roles
- Configure secure networking between VMs
- Deploy a database server
- Set up a web application
- Implement monitoring
- Configure load balancing

## Prerequisites

- Completed Practicals 1-9
- GCP account with billing enabled
- Understanding of networking concepts
- Basic web application knowledge

## Step-by-Step Guide

### 1. Infrastructure Setup

Create three VMs using gcloud:

```bash
# Create Web Server VM
gcloud compute instances create web-server-1 \
    --machine-type=e2-medium \
    --zone=us-central1-a \
    --image-family=ubuntu-2004-lts \
    --image-project=ubuntu-os-cloud \
    --tags=http-server,https-server

# Create Database Server VM
gcloud compute instances create db-server-1 \
    --machine-type=e2-medium \
    --zone=us-central1-a \
    --image-family=ubuntu-2004-lts \
    --image-project=ubuntu-os-cloud \
    --tags=mysql-server

# Create Load Balancer VM
gcloud compute instances create lb-server-1 \
    --machine-type=e2-medium \
    --zone=us-central1-a \
    --image-family=ubuntu-2004-lts \
    --image-project=ubuntu-os-cloud \
    --tags=http-server,https-server
```

### 2. Network Configuration

Create firewall rules:
```bash
# Allow HTTP/HTTPS traffic to load balancer
gcloud compute firewall-rules create allow-http-https \
    --direction=INGRESS \
    --priority=1000 \
    --network=default \
    --action=ALLOW \
    --rules=tcp:80,tcp:443 \
    --source-ranges=0.0.0.0/0 \
    --target-tags=http-server

# Allow MySQL traffic only from web servers
gcloud compute firewall-rules create allow-mysql-internal \
    --direction=INGRESS \
    --priority=1000 \
    --network=default \
    --action=ALLOW \
    --rules=tcp:3306 \
    --source-tags=http-server \
    --target-tags=mysql-server
```

### 3. Database Server Setup

SSH into the database server:
```bash
gcloud compute ssh db-server-1
```

Install and configure MySQL:
```bash
# Install MySQL
sudo apt update
sudo apt install -y mysql-server

# Secure MySQL installation
sudo mysql_secure_installation

# Create application database and user
sudo mysql -e "CREATE DATABASE myapp;"
sudo mysql -e "CREATE USER 'myapp'@'%' IDENTIFIED BY 'secure_password';"
sudo mysql -e "GRANT ALL PRIVILEGES ON myapp.* TO 'myapp'@'%';"
sudo mysql -e "FLUSH PRIVILEGES;"
```

Configure MySQL for remote access:
```bash
sudo vi /etc/mysql/mysql.conf.d/mysqld.cnf
```

Change the bind-address:
```
bind-address = 0.0.0.0
```

Restart MySQL:
```bash
sudo systemctl restart mysql
```

### 4. Web Server Setup

SSH into the web server:
```bash
gcloud compute ssh web-server-1
```

Install required packages:
```bash
# Install LAMP stack
sudo apt update
sudo apt install -y apache2 php php-mysql libapache2-mod-php

# Install monitoring tools
sudo apt install -y prometheus-node-exporter
```

Create a test PHP file:
```bash
sudo vi /var/www/html/index.php
```

Add content:
```php
<?php
$host = 'db-server-1';
$dbname = 'myapp';
$user = 'myapp';
$pass = 'secure_password';

try {
    $pdo = new PDO("mysql:host=$host;dbname=$dbname", $user, $pass);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    echo "Database connection successful!";
} catch(PDOException $e) {
    echo "Connection failed: " . $e->getMessage();
}
?>
```

### 5. Load Balancer Setup

SSH into the load balancer:
```bash
gcloud compute ssh lb-server-1
```

Install and configure Nginx:
```bash
# Install Nginx
sudo apt update
sudo apt install -y nginx

# Configure load balancing
sudo vi /etc/nginx/conf.d/load-balancer.conf
```

Add configuration:
```nginx
upstream backend {
    server web-server-1:80;
    # Add more web servers here as needed
}

server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

Test and reload Nginx:
```bash
sudo nginx -t
sudo systemctl reload nginx
```

### 6. Monitoring Setup

Create a monitoring script:
```bash
sudo vi /usr/local/bin/monitor_multi_vm.sh
```

Add script content (see scripts/monitor_multi_vm.sh).

### 7. Security Hardening

On all servers:
```bash
# Update systems
sudo apt update
sudo apt upgrade -y

# Configure UFW
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Web/LB Servers
sudo ufw allow ssh
sudo ufw allow http
sudo ufw allow https

# Database Server
sudo ufw allow ssh
sudo ufw allow from web-server-1 to any port 3306

# Enable UFW
sudo ufw enable
```

## Expected Outcomes

- [x] Three VMs running different services
- [x] Secure communication between VMs
- [x] Working web application with database
- [x] Load balancer configuration
- [x] Basic monitoring setup

## Architecture Diagram

```
[Internet] --> [Load Balancer VM]
                      |
                      v
               [Web Server VM]
                      |
                      v
              [Database Server VM]
```

## Troubleshooting

### Common Issues

1. **Database Connection Failed**
   - Check MySQL bind address
   - Verify firewall rules
   - Test network connectivity
   ```bash
   nc -zv db-server-1 3306
   ```

2. **Load Balancer Issues**
   - Check Nginx configuration
   - Verify backend servers
   - Test backend connectivity
   ```bash
   curl -I http://web-server-1
   ```

3. **Security Issues**
   - Review firewall rules
   - Check server logs
   - Verify SSL certificates

## Performance Optimization

1. **Database Tuning**
```bash
# Edit MySQL configuration
sudo vi /etc/mysql/mysql.conf.d/mysqld.cnf

# Add performance settings
innodb_buffer_pool_size = 1G
innodb_log_file_size = 256M
max_connections = 1000
```

2. **Web Server Tuning**
```bash
# Configure Apache MPM
sudo vi /etc/apache2/mods-available/mpm_prefork.conf

# Adjust settings
<IfModule mpm_prefork_module>
    StartServers 5
    MinSpareServers 5
    MaxSpareServers 10
    MaxRequestWorkers 150
    MaxConnectionsPerChild 0
</IfModule>
```

3. **Load Balancer Optimization**
```bash
# Edit Nginx configuration
sudo vi /etc/nginx/nginx.conf

# Add performance settings
worker_processes auto;
worker_connections 2048;
keepalive_timeout 65;
```

## Career Tips

- Document your infrastructure
- Implement monitoring and alerts
- Use configuration management
- Practice scaling scenarios
- Understand security implications

## Additional Resources

Create deployment documentation:
```bash
# Generate infrastructure documentation
echo "# Infrastructure Documentation" > infrastructure.md
echo "## Server Inventory" >> infrastructure.md
gcloud compute instances list >> infrastructure.md
echo "## Network Configuration" >> infrastructure.md
gcloud compute firewall-rules list >> infrastructure.md
```

This practical demonstrates real-world deployment scenarios you'll encounter in cloud environments.