#!/bin/bash

#=================================================================
# Practical 2: User and Permission Management
# Purpose: Manage users, groups, and file permissions
# Created: November 7, 2025
#=================================================================

# Function to check if script is run as root
check_root() {
    if [ "$EUID" -ne 0 ]; then
        echo "Please run this script as root or with sudo"
        exit 1
    fi
}

# Function to create a new user
create_user() {
    read -p "Enter username to create: " username
    if id "$username" >/dev/null 2>&1; then
        echo "User $username already exists"
    else
        # Create user with home directory
        useradd -m -s /bin/bash "$username"
        # Set password
        passwd "$username"
        echo "User $username created successfully"
    fi
}

# Function to create a new group
create_group() {
    read -p "Enter group name to create: " groupname
    if grep -q "^$groupname:" /etc/group; then
        echo "Group $groupname already exists"
    else
        groupadd "$groupname"
        echo "Group $groupname created successfully"
    fi
}

# Function to add user to group
add_user_to_group() {
    read -p "Enter username: " username
    read -p "Enter group name: " groupname
    
    # Check if user and group exist
    if ! id "$username" >/dev/null 2>&1; then
        echo "User $username does not exist"
        return 1
    fi
    
    if ! grep -q "^$groupname:" /etc/group; then
        echo "Group $groupname does not exist"
        return 1
    fi
    
    usermod -a -G "$groupname" "$username"
    echo "Added $username to group $groupname"
}

# Function to demonstrate file permissions
manage_permissions() {
    # Create test directory and files
    mkdir -p /tmp/permission_test
    echo "Test file content" > /tmp/permission_test/test_file.txt
    
    echo "Current permissions:"
    ls -l /tmp/permission_test
    
    # Change ownership
    read -p "Enter user to own the file: " owner
    read -p "Enter group to own the file: " group
    
    chown "$owner:$group" /tmp/permission_test/test_file.txt
    
    # Change permissions
    echo "Change permissions:"
    echo "1. Read only (444)"
    echo "2. Read and write (666)"
    echo "3. Full access (777)"
    read -p "Choose permission set (1-3): " perm_choice
    
    case $perm_choice in
        1) chmod 444 /tmp/permission_test/test_file.txt ;;
        2) chmod 666 /tmp/permission_test/test_file.txt ;;
        3) chmod 777 /tmp/permission_test/test_file.txt ;;
        *) echo "Invalid choice" ;;
    esac
    
    echo "New permissions:"
    ls -l /tmp/permission_test
}

# Function to list users and groups
list_users_and_groups() {
    echo "System Users:"
    echo "------------"
    cut -d: -f1,3 /etc/passwd | grep -v "^#"
    
    echo -e "\nSystem Groups:"
    echo "-------------"
    cut -d: -f1 /etc/group | grep -v "^#"
    
    echo -e "\nUser Groups:"
    read -p "Enter username to see their groups: " username
    groups "$username"
}

# Function to delete user
delete_user() {
    read -p "Enter username to delete: " username
    read -p "Delete home directory? (y/n): " delete_home
    
    if [ "$delete_home" = "y" ]; then
        userdel -r "$username"
    else
        userdel "$username"
    fi
    echo "User $username deleted"
}

# Main menu
check_root

while true; do
    echo -e "\n=== User and Permission Management ==="
    echo "1. Create new user"
    echo "2. Create new group"
    echo "3. Add user to group"
    echo "4. Manage file permissions"
    echo "5. List users and groups"
    echo "6. Delete user"
    echo "7. Exit"
    
    read -p "Choose an option (1-7): " choice
    
    case $choice in
        1) create_user ;;
        2) create_group ;;
        3) add_user_to_group ;;
        4) manage_permissions ;;
        5) list_users_and_groups ;;
        6) delete_user ;;
        7) 
            echo "Cleaning up..."
            rm -rf /tmp/permission_test
            echo "Exiting..."
            exit 0
            ;;
        *) echo "Invalid option" ;;
    esac
done