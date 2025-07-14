# DLS Password Backup

A robust script for creating on-demand local backups of critical password database files.

## Overview

This script provides a standardized method for creating timestamped, encrypted backups of critical password databases and other sensitive files. It is designed to be run from an encrypted USB drive, facilitating a robust offline backup strategy.

## Architectural Context

While this script is a standalone tool, its full significance is best understood as part of a larger security architecture. Each DLS script serves as the practical implementation of a core security principle, from ensuring data integrity (`dls-icloud-backup-integrity`) and managing redundancy (`dls-sync-drives`) to securing critical assets (`dls-password-backup`). 

## Features

-   **On-Demand Backups:** Designed for deliberate, user-initiated backups rather than automated, background execution.
-   **Finds Newest Files:** Can intelligently find the most recent file matching a pattern (e.g., `Backup-*.kdbx`), which is perfect for versioned backup files.
-   **Local Configuration Management:** Configuration is handled via a `password-backup.config` file located in the same directory. A `password-backup.config.example` is provided as a starting point.
-   **Comprehensive Local Logging:** Generates detailed, timestamped logs in a `logs` directory, aiding in monitoring and troubleshooting.
-   **Concurrency Control:** Implements a file-based lock (`flock`) to prevent multiple instances from running concurrently.
-   **Robust Error Handling:** Performs validation of configuration files and paths and checks if files are in use (`lsof`) before copying.

## How It Works

The script performs a **safe, one-way copy** from your specified source locations to the destination directory.

1.  It reads the `SOURCE_FILES` array and the `DEST_DIR` from `password-backup.config`.
2.  For each entry in `SOURCE_FILES`, it determines the exact file to copy. If a wildcard (`*`) is used, it finds the most recently modified file that matches the pattern.
3.  It checks that the source file exists and is not currently in use.
4.  It uses `rsync` to copy the file to the `DEST_DIR`.
5.  It provides a clear "ok" or "FAILED" status for each file on-screen and records detailed results in the log file.

### Key Behaviors:
- **One-Way Copy**: This is a backup script, not a sync script. It only copies files *from* source locations *to* the destination.
- **Newer Files Win**: If a file with the same name already exists in the destination, `rsync` will overwrite it if the source file is newer.
- **No Automatic Deletion**: The script will never delete files from your source or destination directories.

## Setup & Usage

The script is designed to be run directly without any installation.

1.  **Place the Files:**
    Copy the entire project folder to your desired location, such as an encrypted USB flash drive.

2.  **Configure the Script:**
    Navigate to the script's directory, then copy the example configuration file and edit it with the **absolute paths** to your password databases.

```bash
# Navigate to the script's directory
cd /path/to/dls-password-backup

# Create your personal config file
cp scripts/password-backup.config.example scripts/password-backup.config

# Edit the new config file with your paths
nano scripts/password-backup.config
```

    Example `password-backup.config` contents:

```bash
# A list of absolute paths to the files you want to back up.
# Use wildcards to find the newest file matching a pattern.
SOURCE_FILES=(
    "$HOME/Library/CloudStorage/GoogleDrive-[your@email]/My Drive/Security/*.kdbx"
    "$HOME/Library/Mobile Documents/com~apple~CloudDocs/Security/.kdbx"
    "$HOME/Documents/Backups/KeePass-Backup-*.kdbx"
)

# The destination directory for your backups.
# A relative path like "./Password Databases/" will place it inside the project folder.
DEST_DIR="./Password Databases/"
```

3.  **Run the Backup:**
    Make the script executable (you only need to do this once), then run it to back up your files.

```bash
chmod +x scripts/dls-password-backup.sh
./scripts/dls-password-backup.sh
```

## Manual Usage

Every time you want to back up your files, simply navigate to the script's directory and execute it:

```bash
./scripts/dls-password-backup.sh
```

Monitor the backup process by tailing the log file in another terminal window:

```bash
tail -f logs/backup.log
```

## Troubleshooting

- **Configuration Issues:** Most errors are caused by incorrect paths in `scripts/password-backup.config`. Ensure all paths are absolute and correct. Verify that the specified source files and destination directory exist.
- **Dependency Errors:** The script requires `rsync` and `lsof`. On macOS, these are typically pre-installed. On Linux, you may need to install them (`sudo apt-get install rsync lsof`).
- **Permission Problems:** Ensure the script has execute permissions (`chmod +x scripts/dls-password-backup.sh`). You must also have read permissions for the source files and write permissions for the destination directory.
- **Lock File Conflicts:** If the script fails to start due to a lock file, check `/tmp/dls-password-backup.lock`. If you are certain the script is not running, you can manually remove this file.

## License

This project is licensed under the MIT License.

## Support the Project

If you find this project useful and would like to show your appreciation, you can:

- [Buy Me a Coffee](https://buymeacoffee.com/pequet)
- [Sponsor on GitHub](https://github.com/sponsors/pequet)
- [Deploy on DigitalOcean](https://www.digitalocean.com/?refcode=51594d5c5604) (affiliate link $) 

Your support helps in maintaining and improving this project. 

