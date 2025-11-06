#!/bin/bash

#=================================================================
# Practical 1: Basic Linux Commands
# Purpose: Demonstrate and practice essential Linux commands
# Created: November 7, 2025
#=================================================================

# Function to display directory contents with details
show_dir_info() {
    echo "Directory listing with details:"
    ls -lah
    echo -e "\nDisk usage:"
    du -sh *
}

# Function to demonstrate file operations
file_operations() {
    echo "Creating test files and directories..."
    mkdir -p test_dir
    touch test_dir/file{1..3}.txt
    echo "Hello World" > test_dir/file1.txt
    echo "Linux Practice" > test_dir/file2.txt
    
    echo -e "\nFile contents:"
    cat test_dir/file1.txt
    cat test_dir/file2.txt
    
    echo -e "\nSearching for files:"
    find . -name "file*.txt"
    
    echo -e "\nCopying and moving files:"
    cp test_dir/file1.txt test_dir/file1_backup.txt
    mv test_dir/file2.txt test_dir/file2_renamed.txt
}

# Function to demonstrate text processing
text_processing() {
    echo -e "\nText processing examples:"
    echo "Line 1" > test_dir/sample.txt
    echo "Line 2" >> test_dir/sample.txt
    echo "Line 3" >> test_dir/sample.txt
    
    echo "File content with line numbers:"
    cat -n test_dir/sample.txt
    
    echo -e "\nGrep example:"
    grep "Line" test_dir/sample.txt
    
    echo -e "\nWord count:"
    wc -l test_dir/sample.txt
}

# Function to show system information
system_info() {
    echo -e "\nSystem Information:"
    echo "Current user: $(whoami)"
    echo "Current directory: $(pwd)"
    echo "System uptime: $(uptime)"
    echo "Memory usage:"
    free -h
    echo -e "\nDisk usage:"
    df -h
}

# Main menu
while true; do
    echo -e "\n=== Linux Commands Practice Menu ==="
    echo "1. Directory Operations"
    echo "2. File Operations"
    echo "3. Text Processing"
    echo "4. System Information"
    echo "5. Clean Up"
    echo "6. Exit"
    
    read -p "Choose an option (1-6): " choice
    
    case $choice in
        1) show_dir_info ;;
        2) file_operations ;;
        3) text_processing ;;
        4) system_info ;;
        5) 
            echo "Cleaning up..."
            rm -rf test_dir
            ;;
        6) 
            echo "Exiting..."
            exit 0
            ;;
        *) echo "Invalid option" ;;
    esac
done