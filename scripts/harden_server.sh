#!/bin/bash

# Server Hardening Script
# Usage: ./harden_server.sh <username>

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <username>"
    exit 1
fi

USERNAME=$1

# Function to check if command succeeded
check_status() {
    if [ $? -eq 0 ]; then
        echo "[✓] $1"
    else
        echo "[✗] $1"
        exit 1
    fi
}

# 1. Create user if not exists
if ! id "$USERNAME" &>/dev/null; then
    sudo adduser $USERNAME
    check_status "User creation"
fi

# 2. Add to sudo group
sudo usermod -aG sudo $USERNAME
check_status "Added user to sudo group"

# 3. Create SSH directory with correct permissions
sudo -u $USERNAME mkdir -p /home/$USERNAME/.ssh
sudo -u $USERNAME chmod 700 /home/$USERNAME/.ssh
check_status "SSH directory setup"

# 4. Create authorized_keys file
sudo -u $USERNAME touch /home/$USERNAME/.ssh/authorized_keys
sudo -u $USERNAME chmod 600 /home/$USERNAME/.ssh/authorized_keys
check_status "Authorized keys file setup"

# 5. Backup SSH config
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
check_status "SSH config backup"

# 6. Update SSH configuration
sudo sed -i 's/^PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sudo sed -i 's/^PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
check_status "SSH config hardening"

# 7. Restart SSH service
sudo systemctl restart sshd
check_status "SSH service restart"

echo "
Server hardening complete for user $USERNAME
Next steps:
1. Add your public key to: /home/$USERNAME/.ssh/authorized_keys
2. Test SSH login with your key
3. Verify that password authentication is disabled
"