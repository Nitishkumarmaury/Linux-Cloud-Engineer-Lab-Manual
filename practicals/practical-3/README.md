# Practical 3: Managing Project Teams with Users & Groups

This practical demonstrates how to manage users and groups for project team collaboration, a crucial skill for system administration in cloud environments.

## Objectives

- Create and manage user accounts
- Set up project groups
- Configure directory permissions
- Implement secure file sharing

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