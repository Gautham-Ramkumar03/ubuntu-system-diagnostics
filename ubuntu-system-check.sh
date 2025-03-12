#!/bin/bash

# Ubuntu System Diagnostic Script
# For Ubuntu 22.04 LTS
# This script requires sudo privileges but implements safety checks

# Ensure script is run with sudo
if [ "$EUID" -ne 0 ]; then 
    echo "Please run this script with sudo"
    exit 1
fi

# Set safe shell options
set -euo pipefail

# Create output directory and file with timestamp
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
OUTPUT_DIR="/var/log/system_diagnostics"
OUTPUT_FILE="${OUTPUT_DIR}/diagnostic_${TIMESTAMP}.txt"
JOURNAL_LINES=1000  # Number of journal lines to check

# Create output directory safely
mkdir -p "$OUTPUT_DIR"
chmod 755 "$OUTPUT_DIR"

# Function to safely execute commands and log output
run_check() {
    local cmd="$1"
    local description="$2"
    
    echo -e "\n=== ${description} ===" >> "$OUTPUT_FILE"
    echo "Command: ${cmd}" >> "$OUTPUT_FILE"
    echo "----------------------------------------" >> "$OUTPUT_FILE"
    
    if ! eval "$cmd" >> "$OUTPUT_FILE" 2>&1; then
        echo "Warning: Command failed: ${cmd}" >> "$OUTPUT_FILE"
    fi
    echo "----------------------------------------" >> "$OUTPUT_FILE"
}

# Initialize the report
echo "Ubuntu 22.04 System Diagnostic Report" > "$OUTPUT_FILE"
echo "Generated on: $(date)" >> "$OUTPUT_FILE"
echo "Hostname: $(hostname)" >> "$OUTPUT_FILE"
echo "----------------------------------------" >> "$OUTPUT_FILE"

# System Information
run_check "uname -a" "Kernel Information"
run_check "lsb_release -a" "Ubuntu Version Information"

# Kernel Checks
run_check "dmesg | tail -n 100" "Recent Kernel Messages"
run_check "journalctl -p err..emerg --since '24 hours ago'" "System Errors (Last 24 Hours)"
run_check "journalctl -k --since '24 hours ago' | grep -i 'error\|fail\|warning'" "Kernel Errors and Warnings"

# File System Checks
echo -e "\n=== File System Status ===" >> "$OUTPUT_FILE"
for fs in $(mount | grep '^/dev' | cut -d' ' -f1); do
    run_check "df -h $fs" "Disk Space for $fs"
    # Only run fsck in read-only mode for safety
    run_check "fsck -nv $fs" "File System Check for $fs (Read-only)"
done

# SMART Disk Checks
echo -e "\n=== SMART Disk Status ===" >> "$OUTPUT_FILE"
for disk in $(lsblk -d -o name | grep -E '^sd|^nvme' | grep -v NAME); do
    if [[ -b "/dev/$disk" ]]; then
        run_check "smartctl -H /dev/$disk" "SMART Health for /dev/$disk"
    fi
done

# Memory Checks
run_check "free -h" "Memory Usage"
run_check "vmstat 1 5" "Virtual Memory Statistics"
run_check "swapon -s" "Swap Usage"

# GRUB Checks
run_check "ls -l /boot/grub" "GRUB Files"
run_check "grep -v '^#' /etc/default/grub" "GRUB Configuration"
run_check "ls -l /boot/grub/grub.cfg" "GRUB Config File Status"

# Package System
run_check "dpkg -l | grep -i error" "Package Errors"
run_check "apt-get check" "APT Database Check"

# Service Status
run_check "systemctl list-units --state=failed" "Failed Services"
run_check "systemctl status" "System Services Status"

# Hardware Information
run_check "lspci" "PCI Devices"
run_check "lsusb" "USB Devices"
run_check "lsblk" "Block Devices"

# Temperature and Sensor Data (if available)
if command -v sensors > /dev/null; then
    run_check "sensors" "System Temperatures"
fi

# Network Status
run_check "ip addr" "Network Interfaces"
run_check "netstat -tuln" "Open Ports"

# Security Checks
run_check "aa-status" "AppArmor Status"
run_check "ufw status" "Firewall Status"

# Final Summary
echo -e "\n=== Diagnostic Summary ===" >> "$OUTPUT_FILE"
echo "Report generated successfully" >> "$OUTPUT_FILE"
echo "Full report available at: $OUTPUT_FILE" >> "$OUTPUT_FILE"

# Set appropriate permissions on the output file
chmod 640 "$OUTPUT_FILE"

echo "Diagnostic complete. Report saved to $OUTPUT_FILE"
echo "Please review the report for any warnings or errors."

# Optional: Create a compressed backup of the report
gzip -k "$OUTPUT_FILE"
echo "Compressed report saved as ${OUTPUT_FILE}.gz"
