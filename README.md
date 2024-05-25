# System Update and Cleanup Script

This script is designed to automate the process of updating and cleaning up a Debian-based Linux system. It performs the following tasks:

- Updates package lists to get the latest version information.
- Upgrades all installed packages to their latest versions.
- Fixes broken packages if any.
- Performs a distribution upgrade, which handles system upgrades.
- Installs available firmware updates.
- Removes unnecessary packages and dependencies.
- Cleans up the local repository of retrieved package files.
- Removes orphaned packages (packages that were installed as dependencies but are no longer needed).
- Clears systemd journal logs (to free up disk space).
- Removes old kernels, keeping only the current and the latest one.
- Removes temporary files from /tmp and /var/tmp.
- Checks and removes any unused Snap packages.
- Updates Snap packages.
- Checks for and updates Flatpak packages (if Flatpak is installed).
- Provides a comprehensive log of actions performed in /var/log/update_and_cleanup.log.

## Usage

To use the script, simply run it with root privileges:

```bash
sudo ./update_and_cleanup.sh
```

## Ensure that the script is executable by running:

```bash
chmod +x update_and_cleanup.sh
```

## NOTE

- This script is specifically designed for Debian-based systems (such as Debian and Ubuntu) and may require modification to work on other Linux distributions.
- Review the script and README carefully before running the script on your system to ensure it meets your requirements and expectations.
