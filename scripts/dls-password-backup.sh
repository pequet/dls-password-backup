#!/bin/bash

# Standard Error Handling
set -e
set -u
set -o pipefail

# █████  DLS Password Backup: On-demand backup for critical files
# █  ██  Version: 1.0.0
# █ ███  Author: Benjamin Pequet 
# █████  GitHub: https://github.com/pequet/dls-password-backup
#
# Purpose:
#   This script performs a robust, on-demand backup of specified files
#   (typically password databases) from various source locations to a single
#   destination directory. It is designed to be run manually from a portable
#   drive, providing an extra layer of physical, offline-capable redundancy.
#
# Usage:
#   ./dls-password-backup.sh
#   The script is configured via 'password-backup.config' in the same directory.
#
# Dependencies:
#   - rsync: Must be installed and available in the system's PATH.
#   - flock: Used for lock file mechanism to prevent concurrent runs.
#   - lsof: Used to check if files are currently in use.

# --- Global Variables ---
# Resolve the true script directory, following symlinks
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
SCRIPT_DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"

CONFIG_FILE="${SCRIPT_DIR}/password-backup.config"
LOCK_FILE="/tmp/dls-password-backup.lock"
LOG_DIR="${SCRIPT_DIR}/logs"
LOG_FILE_PATH="${LOG_DIR}/backup.log"

# Source shared utilities
source "${SCRIPT_DIR}/utils/logging_utils.sh"
source "${SCRIPT_DIR}/utils/messaging_utils.sh"

# --- Function Definitions ---

# *
# * Utility Functions
# *
get_mod_time() {
    local file_path="$1"
    # The command to get epoch time varies between macOS and Linux
    if [[ "$(uname)" == "Darwin" ]]; then
        stat -f %m "$file_path"
    else
        stat -c %Y "$file_path"
    fi
}

# *
# * Configuration Management
# *
load_config() {
    if [[ ! -f "$CONFIG_FILE" ]]; then
        print_error "Configuration file not found."
        print_error "Please copy password-backup.config.example to password-backup.config and edit it."
        exit 1
    fi
    
    # shellcheck source=./password-backup.config.example
    if ! source "$CONFIG_FILE"; then
        print_error "Failed to load configuration from ${CONFIG_FILE}"
        exit 1
    fi
}

# *
# * Configuration Validation
# *
validate_config() {
    if [[ -z "${SCRIPT_TITLE:-}" ]]; then
        print_error "Config error: SCRIPT_TITLE is not defined in the config file."
        exit 1
    fi

    if [[ -z "${DEST_DIR:-}" ]]; then
        print_error "Config error: DEST_DIR is not defined in the config file."
        exit 1
    fi

    if ! declare -p SOURCE_FILES | grep -q "declare -a"; then
        print_error "Config error: SOURCE_FILES is not defined as an array in your config file."
        print_error "Please ensure it looks like: SOURCE_FILES=(\"/path/one\" \"/path/two\")"
        exit 1
    fi

    if [ ${#SOURCE_FILES[@]} -eq 0 ]; then
        print_error "Config error: SOURCE_FILES array is empty in your config file."
        print_error "Please add at least one file path to back up."
        exit 1
    fi
}

# *
# * Dependency Validation
# *
check_dependencies() {
    if ! command -v rsync &> /dev/null; then
        print_error "rsync not found. Please install it."
        exit 1
    fi
    
    if ! command -v flock &> /dev/null; then
        print_error "flock not found. Please install it (e.g., brew install flock)."
        exit 1
    fi

    if ! command -v lsof &> /dev/null; then
        print_error "lsof not found. It is usually pre-installed on macOS and Linux."
        exit 1
    fi

    if ! command -v hostname &> /dev/null; then
        print_error "hostname not found. It is usually pre-installed on macOS and Linux."
        exit 1
    fi
}

# *
# * Core Backup Logic
# *
run_backup() {
    local patterns_with_no_files=0
    local copied_count=0
    local skipped_in_use=0
    local failed_count=0
    local all_found_files=()
    local unmatched_patterns=()

    print_header "${SCRIPT_TITLE}"
    log_message "INFO" "Starting backup process."

    # --- PHASE 1A: Scan all sources and gather all found files ---
    for src_pattern in "${SOURCE_FILES[@]}"; do
        print_info "Searching for files matching: ${src_pattern}"
        local files_found_for_pattern=()
        local src_pattern_expanded="${src_pattern/#\~/$HOME}"
        local dir_part file_pattern
        dir_part=$(dirname "$src_pattern_expanded")
        file_pattern=$(basename "$src_pattern_expanded")
        
        while IFS= read -r line; do
            files_found_for_pattern+=("$line")
        done < <(find "${dir_part}" -maxdepth 1 -name "${file_pattern}" -type f 2>/dev/null)

        if [ ${#files_found_for_pattern[@]} -eq 0 ]; then
            ((patterns_with_no_files++))
            unmatched_patterns+=("${src_pattern}")
        else
            for file in "${files_found_for_pattern[@]}"; do
                all_found_files+=("$file")
            done
        fi
    done

    # --- PHASE 1B: Filter for the newest version of each unique file ---
    local unique_files_to_copy=()
    local seen_basenames=()

    for file_path in "${all_found_files[@]}"; do
        local basename
        basename=$(basename "$file_path")

        local found_index=-1
        for i in "${!seen_basenames[@]}"; do
            if [[ "${seen_basenames[$i]}" == "$basename" ]]; then
                found_index=$i
                break
            fi
        done

        if [[ $found_index -ne -1 ]]; then
            # We've seen this basename before. Compare modification times.
            local existing_file_path="${unique_files_to_copy[$found_index]}"
            local existing_mod_time
            local current_mod_time
            existing_mod_time=$(get_mod_time "$existing_file_path")
            current_mod_time=$(get_mod_time "$file_path")

            if [[ "$current_mod_time" -gt "$existing_mod_time" ]]; then
                # The current file is newer, so we replace the old one.
                unique_files_to_copy[$found_index]="$file_path"
            fi
        else
            # This is the first time we've seen this basename. Add it.
            seen_basenames+=("$basename")
            unique_files_to_copy+=("$file_path")
        fi
    done
    
    local total_to_process=${#unique_files_to_copy[@]}
    print_info "Found ${total_to_process} unique file(s) to back up from ${#SOURCE_FILES[@]} locations."

    # --- PHASE 2: Process the collected files ---
    local full_dest_dir="${SCRIPT_DIR}/${DEST_DIR}"
    if ! mkdir -p "${full_dest_dir}"; then
        print_error "Could not create destination directory: ${full_dest_dir}"
        exit 1
    fi
    full_dest_dir=$(realpath "${full_dest_dir}")

    for src_file in "${unique_files_to_copy[@]}"; do
        local basename
        basename=$(basename "$src_file")

        if lsof "$src_file" > /dev/null 2>&1; then
            print_status_line "- [INFO]" "${basename}" "SKIPPED (in use)"
            log_message "WARN" "Skipped ${basename} because it is in use."
            ((skipped_in_use++))
            continue
        fi

        local rsync_stderr
        # Using -au: archive mode, update only. This is quiet on success.
        if ! rsync_stderr=$(rsync -au "${src_file}" "${full_dest_dir}/" 2>&1); then
            print_status_line "- [COPYING]" "${basename}" "FAILED"
            print_error "Rsync failed for '${basename}'. Details: ${rsync_stderr}"
            ((failed_count++))
        else
            print_status_line "- [COPYING]" "${basename}" "SUCCESS"
            log_message "SUCCESS" "Copied '${src_file}' to '${full_dest_dir}'"
            ((copied_count++))
        fi
    done

    # --- PHASE 3: Summary ---
    print_separator
    print_completed "Backup complete."
    
    local summary_line="Copied: ${copied_count} | Failed: ${failed_count}"
    if [ "$skipped_in_use" -gt 0 ]; then
        summary_line+=" | Skipped (in use): ${skipped_in_use}"
    fi
    if [ "$patterns_with_no_files" -gt 0 ]; then
        summary_line+=" | Unmatched patterns: ${patterns_with_no_files}"
    fi
    print_info "${summary_line}"
    log_message "INFO" "Summary: ${summary_line}"

    if [ ${#unmatched_patterns[@]} -gt 0 ]; then
        print_warning "The following patterns did not match any files:"
        for pattern in "${unmatched_patterns[@]}"; do
            print_info "- ${pattern}"
        done
    fi

    print_footer
}

# *
# * Main Execution
# *
main() {
    ensure_log_directory
    log_message "INFO" "=== DLS Password Backup starting ==="
    
    load_config
    validate_config
    check_dependencies
    
    (
        if ! flock -n 200; then
            print_error "Another instance is already running. Check lock file: ${LOCK_FILE}"
            exit 1
        fi
        
        run_backup
        
    ) 200>"${LOCK_FILE}"
    
    log_message "INFO" "=== DLS Password Backup completed ==="
}

# --- Script Entrypoint ---
main "$@" 