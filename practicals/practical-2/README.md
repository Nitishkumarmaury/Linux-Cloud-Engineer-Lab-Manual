# Practical 2: Deploying a Static Website with Nginx

This practical demonstrates how to set up and configure a web server, a common task in cloud environments.

## Objectives

- Install and configure Nginx web server
- Deploy a basic static website
- Configure firewall rules
- Understand service management

## Prerequisites

- Completed Practical 1 (secure VM setup)
- Basic understanding of HTTP protocol
- Familiarity with text editors (vi/vim)

## Step-by-Step Guide

### 1. System Preparation

```bash
# Update package lists
sudo apt update

# Upgrade installed packages
sudo apt upgrade -y
```

### 2. Nginx Installation

```bash
# Install Nginx
sudo apt install nginx -y

# Verify installation
sudo systemctl status nginx
```

Expected output should show: `active (running)`

### 3. Configure Firewall

```bash
# Allow HTTP traffic (port 80)
sudo ufw allow 'Nginx HTTP'

# Verify firewall status
sudo ufw status
```

### 4. Configure GCP Firewall

```bash
# Add firewall rule for HTTP
gcloud compute firewall-rules create allow-http \
    --direction=INGRESS \
    --priority=1000 \
    --network=default \
    --action=ALLOW \
    --rules=tcp:80 \
    --source-ranges=0.0.0.0/0 \
    --target-tags=http-server
```

### 5. Website Deployment

1. Remove default page:
```bash
sudo rm /var/www/html/index.nginx-debian.html
```

2. Create new index.html:
```bash
sudo vi /var/www/html/index.html
```

Add this content:
```html
<!DOCTYPE html>
<html>
<head>
    <title>My Cloud Server</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            line-height: 1.6;
            margin: 40px;
        }
        .container {
            max-width: 800px;
            margin: 0 auto;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>Welcome to my Cloud Server!</h1>
        <p>This server was configured as part of my Linux cloud engineering practicals.</p>
        <p>Skills demonstrated:</p>
        <ul>
            <li>Web server installation and configuration</li>
            <li>Service management</li>
            <li>Firewall configuration</li>
            <li>Basic HTML deployment</li>
        </ul>
    </div>
</body>
</html>
```

### 6. Testing

1. Get your VM's public IP:
```bash
curl ifconfig.me
```

2. Test locally:
```bash
curl localhost
```

3. Test from browser: Visit `http://[YOUR-VM-IP]`

## Service Management

Common Nginx service commands:
```bash
# Check status
sudo systemctl status nginx

# Stop service
sudo systemctl stop nginx

# Start service
sudo systemctl start nginx

# Restart service
sudo systemctl restart nginx

# Reload configuration
sudo systemctl reload nginx
```

## File Locations

Important Nginx files and directories:
```
/var/www/html/          # Web root directory
/etc/nginx/             # Configuration directory
/var/log/nginx/         # Log files
/etc/nginx/sites-available/  # Site configurations
/etc/nginx/sites-enabled/    # Enabled site configurations
```

## Expected Outcomes

- [x] Nginx installed and running
- [x] Custom webpage accessible via HTTP
- [x] Firewall properly configured
- [x] Understanding of service management

## Troubleshooting

### Common Issues

1. **Website Not Accessible**
   - Check Nginx service status
   - Verify firewall rules (both UFW and GCP)
   - Check error logs: `sudo tail -f /var/log/nginx/error.log`

2. **Permission Issues**
   - Verify ownership of files in /var/www/html
   - Check file permissions
   - Default ownership should be www-data:www-data

3. **502 Bad Gateway**
   - Check Nginx configuration syntax
   - Verify backend services if using reverse proxy

## Security Best Practices

1. Regular updates:
```bash
sudo apt update && sudo apt upgrade -y
```

2. Secure file permissions:
```bash
sudo chown -R www-data:www-data /var/www/html
sudo chmod -R 755 /var/www/html
```

3. Remove server version display:
```bash
sudo vi /etc/nginx/nginx.conf
# Add or modify: server_tokens off;
```

## Career Tips

- Learn to read and understand Nginx logs
- Practice troubleshooting using logs
- Understand HTTP status codes
- Learn basic performance optimization