---
type: overview
domain: system-state
subject: DLS Password Backup
status: active
summary: Technologies, setup, and technical constraints of the project.
---
# Technical Context

## 1. Technologies Used
List significant technologies, frameworks, libraries, tools.

*   **Language:** Bash
*   **Core Utility:** `rsync` for file copying.
*   **Supporting Utilities:** `lsof` for checking open files, `flock` for concurrency control, `hostname` for system identification.
*   **Version Control:** Git
*   **Hosting:** GitHub
*   **Documentation:** Markdown

## 2. Development Setup & Environment
How to set up the dev environment.

*   **Prerequisites:**
    *   A Unix-like environment (macOS, Linux).
    *   `rsync`, `lsof`, `flock`, and `hostname` must be available in the system's PATH.
    *   Git installed and configured for version control.
*   **Setup Steps:**
    1.  Clone the repository, ideally onto the portable drive where backups will be stored.
    2.  Create the configuration file: `cp scripts/password-backup.config.example scripts/password-backup.config`.
    3.  Edit `scripts/password-backup.config` with the absolute paths to your source database files and the desired destination directory.
    4.  Make the main script executable: `chmod +x scripts/password_backup.sh`.

## 3. Technical Constraints
List known technical limitations.

*   **Bash Scripting:** Limited to the capabilities of Bash and standard command-line utilities. The script is structured modularly, sourcing helper functions from a `utils` directory.
*   **Filesystem Access:** The script is dependent on having correct read/write permissions for source and destination paths.
*   **No GUI:** The script is command-line only.
*   **Error Handling:** Relies on parsing exit codes from `rsync` and other commands, which may not cover all edge cases.

## 4. Dependencies & Integrations (Technical Details)
Key technical details for dependencies/integrations.

*   **`rsync`:** Used for its efficient differential file copying capabilities. The script will check for a version that supports `--info=progress2` for better progress display, falling back to older progress flags if necessary.
*   **`lsof`:** Used to check if a file is open before attempting to copy it, preventing potential corruption of the source or copied file.

## 5. Code & Branching Strategy
Describe the version control system, branching model, and code review process.

*   **VCS:** Git
*   **Hosting:** GitHub
*   **Branching Model:** Feature Branch Workflow (e.g., `feature/improve-logging`).
*   **Code Review:** Pull requests for all changes to the `main` branch.
*   **Commit Messages:** Conventional Commits standard is preferred.

## 6. Build & Deployment Process
Describe the build process, deployment pipeline, and hosting environment.

*   **N/A:** This project has no build or deployment process. It is designed to be run directly from the source code cloned or copied onto a user's machine or portable drive. There is no installation step.

---
**How to Use This File Effectively:**
This document details the technical landscape of your project. Use it to understand the tools, setup procedures, constraints, and deployment workflows. Keep it updated as new technologies are adopted, setup steps change, or the deployment process evolves. It's essential for developer onboarding and maintaining a shared understanding of the tech stack.
