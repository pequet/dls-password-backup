---
type: overview
domain: system-state
subject: DLS Password Backup
status: active
summary: To modernize a legacy script for backing up password databases, aligning it with the new DLS architecture and standards.
---
# Project Brief: DLS Password Backup

## 1. Project Goal

*   **Primary Objective:** To modernize the legacy `password_databases.sh` script into a new, robust, professional, and elegant script named `password_backup.sh`, ensuring it aligns with the principles and quality standards of the broader DLS framework.

*   **Secondary Objectives:**
    *   To establish a clear, maintainable, and scalable structure for the script and its configuration.
    *   To provide comprehensive logging and error handling for reliable, unattended operation.
    *   To create a template for future DLS-related scripting projects.

## 2. Core Requirements & Functionality

*   **Requirement 1:** The script must copy specified password databases (e.g., `.kdbx`, `.opvault`) and backup files from various source locations to a designated local backup directory.
*   **Requirement 2:** The script's architecture, style, and configuration must be modeled directly after the `dls-sync-drives.sh` project, serving as a reference implementation.
*   **Requirement 3:** It must use a separate `password-backup.config` file for user-specific paths and a `password-backup.config.example` for guidance.
*   **Requirement 4:** Implement robust error handling (e.g., for missing files, locked files, failed copy operations) and clear, time-stamped logging.
*   **Requirement 5:** The associated `password-backup.config` and any generated log files must be excluded from version control via `.gitignore`.

## 3. Target Audience

The primary user is a security-conscious individual who wants to maintain an automated, additional layer of local redundancy for their critical password databases, supplementing cloud-based synchronization.

## 4. Scope (Inclusions & Exclusions)

### In Scope:

*   Development of the `scripts/password_backup.sh` shell script.
*   Creation of `scripts/password-backup.config` and `scripts/password-backup.config.example`.
*   Implementation of file-copying logic using `rsync`.
*   Implementation of logging, error handling, and a lock file mechanism to prevent concurrent execution.
*   Updating the project's `.gitignore` file.

### Out of Scope:

*   Cloud-to-cloud synchronization (this is handled by the `dls-sync-drives` project).
*   A graphical user interface (GUI).
*   Real-time file monitoring or synchronization.
*   Password management features (the script only copies database files).

## 5. Success Criteria & Key Performance Indicators (KPIs)

*   **Success Criteria:**
    *   The script reliably and correctly copies all specified files to the target directory.
    *   The code is clean, well-documented, and easy to maintain, successfully mirroring the quality of the reference project.
    *   The script handles common errors gracefully without crashing.
*   **KPIs:**
    *   Successful, error-free completion of scheduled script runs.
    *   Clarity and usefulness of log output for diagnostics.
    *   Ease of setup for a new user following the `config.example` file.

## 6. Assumptions

*   The user's environment is a Unix-like system (e.g., macOS, Linux) with a Bash shell.
*   `rsync` is installed and available in the system's PATH.
*   The user has the necessary read permissions for the source directories and write permissions for the destination directory.

## 7. Constraints & Risks

*   **Constraint:** The script will be written in Bash to maintain consistency with the reference project.
*   **Risk 1:** File locking. Password databases may be in use when the script runs, causing copy failures. (Mitigation: The script will check if a file is in use via `lsof` and log a clear warning before skipping it).
*   **Risk 2:** Configuration errors. Incorrect paths in the config file will cause the script to fail. (Mitigation: The script will validate that all configured source and destination paths exist before attempting to sync).

## 8. Stakeholders

*   **Project Sponsor:** Benjamin Pequet
*   **Product Owner:** Benjamin Pequet
*   **Lead Developer:** AI Assistant

