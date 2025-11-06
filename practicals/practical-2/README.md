# Practical 2: User and Permission Management in Linux

## 🎯 Learning Objectives

After completing this practical, you will be able to:
- Create and manage users and groups
- Implement file permission strategies
- Configure sudo access securely
- Set up advanced access control using ACLs
- Understand Linux ownership concepts

## 🔧 Technical Skills Covered

- User account management
- File permissions and ownership
- Access Control Lists (ACLs)
- Sudo configuration
- Security policies implementation

## 📋 Prerequisites

1. Linux server (Ubuntu 20.04 LTS recommended)
2. Root or sudo access
3. Basic command line knowledge
4. Text editor (vim/nano)

## 🚀 Step-by-Step Implementation Guide

### Step 1: Understanding Linux Users and Groups

```bash
# View current user and group information
id
groups

# View all users on the system
cat /etc/passwd

# View all groups on the system
cat /etc/group
```

**💡 Explanation:**
- `/etc/passwd`: Stores user account information
- `/etc/group`: Contains group definitions
- `id` command shows current user's UID, GID, and groups

### Step 2: Creating and Managing Users

```bash
# Create a new user with home directory
sudo useradd -m -s /bin/bash developer1

# Set password for the new user
sudo passwd developer1

# Create another user for testing
sudo useradd -m -s /bin/bash developer2

# View user details
sudo chage -l developer1
```

**💡 Explanation:**
- `-m`: Creates home directory
- `-s /bin/bash`: Sets default shell
- `chage`: Manages user password expiry

### Step 3: Group Management

```bash
# Create development team group
sudo groupadd dev-team

# Create operations team group
sudo groupadd ops-team

# Add users to groups
sudo usermod -aG dev-team developer1
sudo usermod -aG ops-team developer2

# Verify group memberships
groups developer1
groups developer2
```

**💡 Best Practices:**
- Use descriptive group names
- Plan group hierarchy carefully
- Document group purposes

### Step 4: Understanding File Permissions

```bash
# Create test directories
sudo mkdir -p /projects/{dev,ops}

# View default permissions
ls -l /projects/

# Understanding permission notation:
# r (read) = 4
# w (write) = 2
# x (execute) = 1

# Examples:
# 777 = rwxrwxrwx (full access for all - rarely used)
# 755 = rwxr-xr-x (owner full access, others read/execute)
# 644 = rw-r--r-- (owner read/write, others read)
```

**💡 Permission Breakdown:**
- First triplet: Owner permissions
- Second triplet: Group permissions
- Third triplet: Others permissions

### Step 5: Setting Up Project Directories

```bash
# Set ownership and permissions
sudo chown root:dev-team /projects/dev
sudo chmod 770 /projects/dev

sudo chown root:ops-team /projects/ops
sudo chmod 770 /projects/ops

# Create test files
sudo -u developer1 touch /projects/dev/dev1.txt
sudo -u developer2 touch /projects/ops/ops1.txt
```

**💡 Security Tips:**
- Always use least privilege principle
- Regularly audit permissions
- Document special permissions

### Step 6: Implementing ACLs

```bash
# Install ACL package if not present
sudo apt update
sudo apt install acl -y

# Set ACL for specific user
sudo setfacl -m u:developer2:rx /projects/dev
sudo setfacl -m u:developer1:rx /projects/ops

# View ACLs
getfacl /projects/dev
getfacl /projects/ops
```

**💡 ACL Benefits:**
- Fine-grained access control
- Beyond traditional permissions
- Flexible user/group permissions

### Step 7: Sudo Access Configuration

```bash
# Create sudoers file for dev team
sudo visudo -f /etc/sudoers.d/dev-team

# Add following content:
%dev-team ALL=(ALL) /usr/bin/apt update, /usr/bin/apt install
```

**💡 Sudo Best Practices:**
- Use visudo to edit
- Grant minimal necessary permissions
- Always specify full paths

### Step 8: Testing and Verification

```bash
# Test file access
sudo -u developer1 touch /projects/dev/test.txt
sudo -u developer2 touch /projects/dev/test2.txt  # Should fail

# Test sudo permissions
sudo -u developer1 apt update  # Should work
sudo -u developer1 apt upgrade  # Should fail

# View audit logs
sudo tail -f /var/log/auth.log
```

## ✅ Success Criteria

### Required Outcomes
- [x] Users created and configured correctly
- [x] Groups set up with correct memberships
- [x] File permissions properly set
- [x] ACLs implemented and tested
- [x] Sudo access configured securely
- [x] All tests passed successfully

### Security Audit Checklist
- [ ] All passwords set and complex
- [ ] Group permissions verified
- [ ] ACLs tested and working
- [ ] Sudo access limited appropriately
- [ ] Audit logging enabled
- [ ] No unnecessary permissions granted

## 🔍 Troubleshooting Guide

### 1. Permission Denied Issues
```bash
# Check current permissions
ls -la /path/to/file

# View effective permissions
namei -l /path/to/file

# Check ACLs
getfacl /path/to/file

# Check SELinux context (if enabled)
ls -Z /path/to/file
```

### 2. Group Access Problems
```bash
# Verify group membership
groups username

# Check group existence
getent group groupname

# Verify file group ownership
ls -l /path/to/file
```

### 3. Sudo Access Issues
```bash
# Check sudo configuration
sudo -l -U username

# View sudo logs
sudo grep sudo /var/log/auth.log

# Test sudo access
sudo -u username sudo -l
```

## 💼 Career Development

### Key Skills Demonstrated
- Linux user management
- Access control implementation
- Security policy enforcement
- System administration
- Troubleshooting methodology
- Security best practices

### Interview Topics
1. **Linux Permissions:**
   - Explain the difference between owner, group, and others
   - How do ACLs extend traditional permissions?
   - When would you use SUID/SGID bits?
   - Describe the security implications of 777 permissions

2. **User Management:**
   - Describe the user creation process
   - How do you implement password policies?
   - Explain sudo vs root access
   - How would you handle user termination?

### Sample Interview Questions
1. How would you secure a shared directory for multiple teams?
2. What's the difference between ACL and traditional permissions?
3. How do you audit user activities in Linux?
4. Explain the concept of privilege escalation

### Salary Insights (2025)
- Linux System Administrator: $85,000 - $120,000
- Security Engineer: $120,000 - $180,000
- DevOps Engineer: $130,000 - $190,000
- Cloud Security Architect: $160,000 - $220,000

## 📚 Additional Resources

### Documentation
- [Linux User Management Guide](https://www.linux.org)
- [ACL Documentation](https://documentation.suse.com/sles/15-SP1/html/SLES-all/cha-security-acls.html)
- [Sudo Manual](https://www.sudo.ws/man/1.8.27/sudo.man.html)

### Practice Materials
- [Linux Academy](https://linuxacademy.com)
- [OverTheWire Bandit](https://overthewire.org/wargames/bandit/)
- [Linux Journey](https://linuxjourney.com)

### Security Standards
- [CIS Benchmarks](https://www.cisecurity.org/cis-benchmarks/)
- [NIST Guidelines](https://www.nist.gov/cyberframework)
- [Linux Security Module Documentation](https://www.kernel.org/doc/html/latest/admin-guide/LSM/index.html)

## 🔄 Next Steps

1. Study advanced permission scenarios
2. Learn about SELinux/AppArmor
3. Practice user management automation
4. Explore PAM configuration
5. Implement role-based access control (RBAC)

## 📝 Practice Exercises

1. Create a shared directory structure for three teams
2. Implement fine-grained ACLs for specific use cases
3. Set up automated user management scripts
4. Configure and test sudo access policies
5. Perform a security audit of the system

Remember: Proper user and permission management is crucial for system security!

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