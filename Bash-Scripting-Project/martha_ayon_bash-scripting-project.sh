#!/bin/bash

# =============================
# Bash Scripting Project
# Author: Martha Ayon
# Description: Basic system health and security audit script
# =============================

# Set variables
DATE=$(date +"%Y-%m-%d_%H-%M-%S")
REPORT="$HOME/Desktop/system_report_$DATE.txt"
THRESHOLD=80  # disk usage warning threshold

# Start writing to the report file
echo "System Audit Report - $DATE" > "$REPORT"
echo "=============================" >> "$REPORT"
echo "" >> "$REPORT"

# 1. System Info
echo "System Information:" >> "$REPORT"
echo "--------------------" >> "$REPORT"
echo "Hostname: $(hostname)" >> "$REPORT"
echo "IP Address: $(hostname -I | cut -d' ' -f1)" >> "$REPORT"
echo "Uptime: $(uptime -p)" >> "$REPORT"
echo "Kernel Version: $(uname -r)" >> "$REPORT"
echo "" >> "$REPORT"

# 2. Disk Usage
echo "Disk Usage:" >> "$REPORT"
echo "------------" >> "$REPORT"
df -h >> "$REPORT"
echo "" >> "$REPORT"

# 3. Check for high disk usage
echo "Disk Usage Alerts (>$THRESHOLD%):" >> "$REPORT"
df -h | awk -v limit=$THRESHOLD 'NR>1 {gsub("%","",$5); if ($5+0 >= limit) print $0;}' >> "$REPORT"
echo "" >> "$REPORT"

# 4. Logged-in Users
echo "Currently Logged-In Users:" >> "$REPORT"
echo "---------------------------" >> "$REPORT"
who >> "$REPORT"
echo "" >> "$REPORT"

# 5. Users with empty passwords
echo "User Accounts with Empty Passwords:" >> "$REPORT"
echo "-----------------------------------" >> "$REPORT"
awk -F: '($2 == "") {print $1}' /etc/shadow >> "$REPORT"
echo "" >> "$REPORT"

# 6. Top Memory Processes
echo "Top 5 Memory-Using Processes:" >> "$REPORT"
echo "-----------------------------" >> "$REPORT"
ps aux --sort=-%mem | head -n 6 >> "$REPORT"
echo "" >> "$REPORT"

# 7. Check if essential services are running
echo "Essential Services Status:" >> "$REPORT"
echo "---------------------------" >> "$REPORT"
for service in systemd auditd cron systemd-journald ufw
do
  systemctl is-active --quiet $service
  if [ $? -eq 0 ]; then
    echo "$service is running" >> "$REPORT"
  else
    echo "$service is NOT running" >> "$REPORT"
  fi
done
echo "" >> "$REPORT"

# 8. Failed Login Attempts
echo "Recent Failed Login Attempts:" >> "$REPORT"
echo "-----------------------------" >> "$REPORT"
grep "Failed password" /var/log/auth.log | tail -n 10 >> "$REPORT"
echo "" >> "$REPORT"

# Done
echo "Audit complete! Report saved to: $REPORT"
