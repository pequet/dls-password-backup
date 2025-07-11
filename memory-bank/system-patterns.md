---
type: overview
domain: system-state
subject: DLS Password Backup
status: active
summary: High-level architecture, key design decisions, and system-wide patterns for the backup script.
---
# System Patterns

## 1. System Architecture Overview

*   **Overall architecture & justification?** *(e.g., Monolithic, Microservices, Client-Server)*

    The project is a single, self-contained Bash script that sources helpers from a `utils` directory. This monolithic-script architecture was chosen for maximum portability, simplicity, and transparency. The goal is a tool that can be run from anywhere, like a USB drive, without dependencies beyond standard Unix utilities. The core logic is contained in the main script, with functions for logging and messaging externalized into utility scripts for better modularity and reuse.

*   **High-Level Diagram Link (Recommended):**

    N/A - The architecture is simple enough not to require a diagram. It is a linear script: Load Utils -> Load Config -> Validate -> Loop through Sources -> Copy File -> Log Result.

## 2. Key Architectural Decisions & Rationales

List significant decisions and why they were made.

*   **Decision 1:** Use a single Bash script.
    *   **Rationale:** To ensure maximum portability and minimize dependencies. The script can be easily run on any macOS or Linux system without a complex setup or installation process.
*   **Decision 2:** Separate configuration into a `.config` file.
    *   **Rationale:** This decouples the user's specific paths from the script's logic, making the script reusable and preventing sensitive path information from being committed to version control.
*   **Decision 3:** Use `rsync` for file copying.
    *   **Rationale:** `rsync` is a mature, reliable, and efficient tool for file transfer, providing features like progress indicators and checksum verification.
*   **Decision 4:** Implement a file-based lock using `flock`.
    *   **Rationale:** To prevent accidental simultaneous executions of the script, which could lead to corrupted files or inconsistent state.

## 3. Design Patterns in Use

List key software design patterns and where they are used.

*   **Pattern 1:** Template Method Pattern (Conceptual).
    *   **Example:** The script follows a consistent, linear workflow for each file it processes: validate, check if open, copy, log. This provides a predictable structure for its main loop.
*   **Pattern 2:** Configuration File.
    *   **Example:** User-specific settings (`SOURCE_FILES`, `DEST_DIR`) are externalized into `password-backup.config`, a classic configuration pattern.

## 4. Component Relationships & Interactions

Describe how major components interact.

*   **Interaction 1:** The main `scripts/password_backup.sh` script sources (loads) variables from the `scripts/password-backup.config` file at runtime.
*   **Interaction 2:** The main script sources helper functions from `scripts/utils/logging_utils.sh` and `scripts/utils/messaging_utils.sh`.
*   **Interaction 3:** The script calls external command-line utilities like `rsync`, `lsof`, `dirname`, `basename`, and `date` to perform its tasks.
*   **Interaction 4:** The script writes log output to a file (e.g., `logs/backup.log`) and also prints status messages to standard output for the user.

## 5. Data Management & Storage

*   **Primary Datastore & Rationale:**

    The local filesystem is the only datastore.
    *   **Rationale:** The script's entire purpose is to read from and write to the filesystem. No other database or storage mechanism is needed.

*   **Data Schema Overview/Link:**

    N/A

*   **Data Caching Strategies:**

    N/A

*   **Data Backup/Recovery Plan:**

    This script *is* the backup plan. Recovery is a manual process of copying files from the backup destination back to their original locations.

## 6. Integration Points with External Systems

List external services/systems integrations.

*   The script integrates only with the local operating system's file system and standard command-line utilities. It has no network or external API integrations.
