# Practical 1: Server Setup & Hardening

This practical focuses on setting up and securing a new cloud VM, a fundamental skill for cloud engineers.

## Objectives

- Launch and access a cloud VM
- Create and configure a non-root user
- Implement SSH key authentication
- Apply basic security hardening

## Prerequisites

- GCP account with billing enabled
- gcloud CLI installed and configured
- Basic command line knowledge

## Step-by-Step Guide

### 1. VM Creation

```bash
# Create a new VM instance
gcloud compute instances create secure-server-1 \
    --machine-type=e2-micro \
    --zone=us-central1-a \
    --image-family=ubuntu-2004-lts \
    --image-project=ubuntu-os-cloud
```

### 2. Initial Access

```bash
# SSH into the VM (GCP will handle the initial authentication)
gcloud compute ssh secure-server-1
```

### 3. Create Non-Root User

```bash
# Create new user
sudo adduser nitish

# Add user to sudo group
sudo usermod -aG sudo nitish
```

### 4. SSH Key Setup

On your local machine:
```bash
# Generate SSH key pair
ssh-keygen -t rsa -b 4096 -C "your-email@example.com"

# Display public key to copy
cat ~/.ssh/id_rsa.pub
```

On the VM:
```bash
# As nitish user
sudo su - nitish
mkdir -p ~/.ssh
chmod 700 ~/.ssh
touch ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys

# Add your public key to authorized_keys
echo "your-public-key-here" > ~/.ssh/authorized_keys
```

### 5. Security Hardening

Edit SSH configuration:
```bash
# Open SSH config in vi
sudo vi /etc/ssh/sshd_config
```

Make these changes:
```
PasswordAuthentication no
PermitRootLogin no
```

Restart SSH service:
```bash
sudo systemctl restart sshd
```

### 6. Verification

1. Log out of the VM
2. Try to SSH in as nitish user:
```bash
ssh nitish@[VM-IP]
```

3. Verify you can't:
   - SSH as root
   - Use password authentication
   - Access without your SSH key

## Expected Outcomes

- [x] Successfully connect using SSH key
- [x] Password authentication disabled
- [x] Root login disabled
- [x] Non-root user with sudo access configured

## Troubleshooting

### Common Issues

1. **SSH Connection Refused**
   - Check if sshd service is running
   - Verify firewall rules allow port 22

2. **Permission Denied**
   - Verify correct permissions on ~/.ssh directory (700)
   - Verify correct permissions on authorized_keys file (600)

3. **Public Key Authentication Failed**
   - Check if public key is correctly copied to authorized_keys
   - Verify no extra newlines or spaces were added

## Security Best Practices

1. Always use strong SSH keys (minimum 4096 bits)
2. Never share private keys
3. Keep system updated:
```bash
sudo apt update
sudo apt upgrade -y
```

## Career Tips

- Document the steps you took (like this guide!)
- Understand why each security measure is important
- Be able to explain the concept of "defense in depth"