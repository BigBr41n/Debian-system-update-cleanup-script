#!/bin/bash

# Ensure the script is run as root (sudo)
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root or with sudo"
  exit 1
fi

# Log file location
LOGFILE="/var/log/update_and_cleanup.log"

# Create or clear the log file
echo "Starting system update and cleanup at $(date)" > $LOGFILE

# Update package lists to get the latest version information
echo "Updating package lists..." | tee -a $LOGFILE
apt-get update -y >> $LOGFILE 2>&1

# Upgrade all installed packages to their latest versions
echo "Upgrading installed packages..." | tee -a $LOGFILE
apt-get upgrade -y >> $LOGFILE 2>&1

# Fix broken packages if any
echo "Fixing broken packages..." | tee -a $LOGFILE
apt-get install -f >> $LOGFILE 2>&1

# Perform a distribution upgrade, which handles system upgrades
echo "Performing distribution upgrade..." | tee -a $LOGFILE
apt-get dist-upgrade -y >> $LOGFILE 2>&1

# Install available firmware updates
echo "Installing firmware updates..." | tee -a $LOGFILE
apt-get install --install-recommends linux-firmware -y >> $LOGFILE 2>&1

# Remove unnecessary packages and dependencies
echo "Removing unnecessary packages..." | tee -a $LOGFILE
apt-get autoremove -y >> $LOGFILE 2>&1

# Clean up the local repository of retrieved package files
echo "Cleaning up package cache..." | tee -a $LOGFILE
apt-get clean >> $LOGFILE 2>&1

# Remove orphaned packages (packages that were installed as dependencies but are no longer needed)
echo "Removing orphaned packages..." | tee -a $LOGFILE
apt-get autoclean >> $LOGFILE 2>&1

# Clear systemd journal logs (this can free up some space)
echo "Clearing systemd journal logs older than 2 weeks..." | tee -a $LOGFILE
journalctl --vacuum-time=2weeks >> $LOGFILE 2>&1

# Remove old kernels (keep only the current and the latest one)
echo "Removing old kernels..." | tee -a $LOGFILE
CURRENT_KERNEL=$(uname -r)
OLD_KERNELS=$(dpkg --list | grep 'linux-image-[0-9]' | awk '{ print $2 }' | grep -v $CURRENT_KERNEL | head -n -1)
if [ -n "$OLD_KERNELS" ]; then
  apt-get remove --purge $OLD_KERNELS -y >> $LOGFILE 2>&1
fi

# Remove temporary files
echo "Removing temporary files from /tmp..." | tee -a $LOGFILE
rm -rf /tmp/* >> $LOGFILE 2>&1

# Remove user-specific temporary files
echo "Removing user-specific temporary files from /var/tmp..." | tee -a $LOGFILE
rm -rf /var/tmp/* >> $LOGFILE 2>&1

# Check and remove any unused Snap packages
echo "Cleaning up unused Snap packages..." | tee -a $LOGFILE
snap list --all | awk '/disabled/{print $1, $3}' | while read snapname revision; do
  snap remove "$snapname" --revision="$revision"
done >> $LOGFILE 2>&1

# Update Snap packages
echo "Updating Snap packages..." | tee -a $LOGFILE
snap refresh >> $LOGFILE 2>&1

# Check for and update Flatpak packages if Flatpak is installed
if command -v flatpak &> /dev/null; then
  echo "Updating Flatpak packages..." | tee -a $LOGFILE
  flatpak update -y >> $LOGFILE 2>&1

  # Clean up old Flatpak runtimes
  echo "Removing old Flatpak runtimes..." | tee -a $LOGFILE
  flatpak uninstall --unused -y >> $LOGFILE 2>&1
fi

# Output a message indicating the cleanup is complete
echo "System update and cleanup complete at $(date)." | tee -a $LOGFILE
