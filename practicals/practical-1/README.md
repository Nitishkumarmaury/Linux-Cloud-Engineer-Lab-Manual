# Practical 1: Server Setup & Security Hardening

## 🎯 Learning Objectives

After completing this practical, you will be able to:
- Set up a secure cloud server from scratch
- Implement SSH key-based authentication
- Apply industry-standard security practices
- Troubleshoot common server access issues

## 🔧 Technical Skills Covered

- Linux server administration
- SSH configuration and security
- User management
- System hardening
- Cloud VM management

## 📋 Prerequisites

1. A GCP (Google Cloud Platform) account with billing enabled
2. Basic command line knowledge
3. gcloud CLI installed on your local machine

## 🚀 Step-by-Step Implementation Guide

### Step 1: Setting Up Your Cloud Environment
```bash
# First, authenticate with Google Cloud
gcloud auth login

# Set your project ID
gcloud config set project your-project-id

# List available regions and zones
gcloud compute regions list
```

**💡 Explanation:** 
- `gcloud auth login`: Initiates secure OAuth2 authentication with Google Cloud
- `gcloud config set project`: Associates commands with your project
- This step ensures you're working in the right environment

### Step 2: Creating a Virtual Machine
```bash
# Create a new VM instance with specific configurations
gcloud compute instances create secure-server-1 \
    --machine-type=e2-micro \
    --zone=us-central1-a \
    --image-family=ubuntu-2004-lts \
    --image-project=ubuntu-os-cloud \
    --tags=allow-ssh \
    --metadata=enable-oslogin=false

# Verify instance creation
gcloud compute instances describe secure-server-1 \
    --zone=us-central1-a
```

**💡 Explanation:**
- `--machine-type=e2-micro`: Cost-effective for learning
- `--image-family=ubuntu-2004-lts`: Latest LTS version for stability
- `--tags=allow-ssh`: Enables firewall rules automatically
- Real-world tip: In production, always use labels for resource tracking

### Step 3: Initial System Setup
```bash
# SSH into the VM
gcloud compute ssh secure-server-1 --zone=us-central1-a

# Update system packages
sudo apt update && sudo apt upgrade -y

# Install essential security tools
sudo apt install -y \
    fail2ban \
    ufw \
    unattended-upgrades \
    vim
```

**💡 Explanation:**
- Always update system first for security patches
- `fail2ban`: Protects against brute-force attacks
- `ufw`: Simple firewall configuration
- `unattended-upgrades`: Automatic security updates

### Step 4: Creating and Configuring Admin User
```bash
# Create new admin user with secure password
sudo adduser --gecos "" admin_user

# Add user to sudo group for administrative access
sudo usermod -aG sudo admin_user

# Verify sudo access
sudo -l -U admin_user

# Switch to new user
sudo su - admin_user
```

**💡 Explanation:**
- `--gecos ""`: Skips unnecessary user information
- `-aG sudo`: Adds to sudo group while preserving existing groups
- Best Practice: Always use descriptive usernames in production

### Step 5: Setting Up SSH Key Authentication

#### On Your Local Machine:
```bash
# Generate a strong SSH key pair using Ed25519 (modern, secure algorithm)
ssh-keygen -t ed25519 -C "your-email@example.com" -f ~/.ssh/secure_server

# Set correct permissions for maximum security
chmod 600 ~/.ssh/secure_server
chmod 644 ~/.ssh/secure_server.pub

# Display public key (you'll need this for the server)
cat ~/.ssh/secure_server.pub
```

**💡 Explanation:**
- `ed25519`: More secure and efficient than older RSA
- `chmod 600`: Only owner can read/write private key
- `chmod 644`: Public key readable by all (safe)

#### On the Server (as admin_user):
```bash
# Create and secure SSH directory
mkdir -p ~/.ssh
chmod 700 ~/.ssh
touch ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys

# Add your public key (replace with actual public key)
echo "ssh-ed25519 AAAA..." > ~/.ssh/authorized_keys

# Verify file contents
cat ~/.ssh/authorized_keys
```

**💡 Security Best Practices:**
- Never share private keys
- Use unique keys for different servers
- Regularly rotate keys in production
- Store private keys securely

### Step 6: Advanced Security Hardening

#### 6.1 SSH Configuration Hardening
```bash
# Backup original SSH config
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak

# Edit SSH configuration
sudo vim /etc/ssh/sshd_config
```

Add or modify these security settings:
```conf
# Authentication Settings
PermitRootLogin no
PasswordAuthentication no
PubkeyAuthentication yes
PermitEmptyPasswords no
MaxAuthTries 3

# Session Settings
ClientAliveInterval 300
ClientAliveCountMax 2
LoginGraceTime 30

# Access Restrictions
AllowUsers admin_user
Protocol 2
```

```bash
# Verify SSH configuration
sudo sshd -t

# Restart SSH service
sudo systemctl restart sshd
```

**💡 Explanation:**
- `PermitRootLogin no`: Prevents root login attempts
- `MaxAuthTries 3`: Limits brute force attempts
- `ClientAliveInterval`: Manages idle connections

#### 6.2 Configuring Firewall
```bash
# Set default policies
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Allow SSH specifically
sudo ufw allow ssh

# Enable firewall
sudo ufw enable

# Verify rules
sudo ufw status verbose
```

**💡 Explanation:**
- Default deny: Security first approach
- Allow only necessary services
- Always verify rules after changes

### Step 7: Security Verification and Testing

#### 7.1 Testing SSH Key Access
```bash
# Test SSH connection with key (should work)
ssh -i ~/.ssh/secure_server admin_user@[VM-IP]

# Test password authentication (should fail)
ssh admin_user@[VM-IP]

# Test root login (should fail)
ssh root@[VM-IP]
```

#### 7.2 Verify Security Configurations
```bash
# Check SSH settings
sudo sshd -T | grep -E 'passwordauthentication|permitrootlogin|maxauthtries'

# Verify firewall status
sudo ufw status numbered

# Check active SSH sessions
who
w
```

**💡 Testing Tips:**
- Always test from a new terminal
- Verify both positive and negative cases
- Check system logs for issues

## ✅ Success Criteria

### Required Outcomes
- [x] SSH key-based authentication working
- [x] Password authentication disabled
- [x] Root login prevented
- [x] Firewall properly configured
- [x] Admin user with sudo access set up
- [x] Security configurations tested

### Security Audit Checklist
- [ ] SSH using strong encryption (Ed25519/RSA 4096)
- [ ] All system packages updated
- [ ] Fail2ban configured and active
- [ ] UFW rules properly set
- [ ] File permissions correct
- [ ] No unnecessary services running

## 🔍 Troubleshooting Guide

### 1. SSH Connection Issues
```bash
# Check SSH service status
sudo systemctl status sshd

# View SSH logs
sudo tail -f /var/log/auth.log

# Test SSH configuration
sudo sshd -T

# Check firewall status
sudo ufw status
```

### 2. Permission Problems
```bash
# Check SSH directory permissions
ls -la ~/.ssh/

# Fix common permission issues
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
chmod 600 ~/.ssh/secure_server
```

### 3. Key Authentication Failures
```bash
# Enable verbose SSH debugging
ssh -vv -i ~/.ssh/secure_server admin_user@[VM-IP]

# Verify key contents
cat ~/.ssh/secure_server.pub
cat ~/.ssh/authorized_keys

# Check selinux context (if applicable)
ls -Z ~/.ssh/
```

**💡 Common Solutions:**
- Remove extra newlines in authorized_keys
- Check for hidden characters
- Verify correct key is being used

## 🛡️ Security Best Practices

### 1. Key Management
- Use Ed25519 or RSA 4096-bit keys minimum
- Store private keys securely (consider hardware security keys)
- Rotate keys regularly in production
- Use different keys for different environments

### 2. System Security
```bash
# Enable automatic security updates
sudo dpkg-reconfigure --priority=low unattended-upgrades

# Monitor authentication attempts
sudo tail -f /var/log/auth.log

# Regular security audits
sudo apt install lynis
sudo lynis audit system
```

### 3. Monitoring and Maintenance
```bash
# Check for failed login attempts
sudo grep "Failed password" /var/log/auth.log

# Monitor system resources
top -c
htop
```

## 💼 Career Development

### Key Skills Demonstrated
- Linux system administration
- Security hardening
- SSH configuration
- Firewall management
- System monitoring

### Interview Topics
1. **SSH Security:**
   - Why use key-based over password authentication?
   - How does public-key cryptography work?
   - Explain the importance of file permissions

2. **System Hardening:**
   - What is defense in depth?
   - How do you secure a new Linux server?
   - Explain the principle of least privilege

### Salary Insights (2025)
- Junior Linux Admin: $70,000 - $90,000
- Cloud Security Engineer: $120,000 - $180,000
- DevOps Engineer: $130,000 - $200,000
- Security Architect: $150,000 - $220,000

## 📚 Additional Resources

### Documentation
- [OpenSSH Security Guide](https://www.openssh.com/security.html)
- [Ubuntu Server Guide](https://ubuntu.com/server/docs)
- [Google Cloud Security Best Practices](https://cloud.google.com/security)

### Practice Environments
- [Katacoda Interactive Labs](https://www.katacoda.com/)
- [Linux Academy](https://linuxacademy.com/)
- [HackTheBox](https://www.hackthebox.eu/)