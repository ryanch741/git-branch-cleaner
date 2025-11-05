#!/bin/bash

# ==============================================================================
# Git Branch Cleanup Tool
# Version: 4.4
#
# Features:
#   - Automatically finds local and remote branches matching a specified prefix.
#   - Checks if these branches have been merged into a specified target branch.
#   - For merged branches, interactively asks the user for deletion confirmation.
#   - Handles both local and remote branches uniformly, using a safe deletion
#     order (local first, then remote).
#   - Remembers the last entered branch prefix and target branch to improve
#     efficiency.
#   - Provides a clear, categorized summary report (deleted, skipped by user,
#     unmerged).
# ==============================================================================

set -e

# Force script's locale to UTF-8 to correctly handle branch names with non-ASCII characters.
export LC_ALL=en_US.UTF-8

# --- Global Configuration & Constants ---

# Path to the configuration file for remembering inputs
readonly CONFIG_FILE="$HOME/.git_cleanup_script.conf"
# Name of the remote repository (hardcoded to origin, can be changed if needed)
readonly REMOTE_NAME="origin"

# --- Color Definitions ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# --- Function Definitions ---

# Function: Displays a welcome message and usage instructions
display_usage() {
    echo -e "${BLUE}=== Git Branch Cleanup Tool ===${NC}"
    echo
    echo "This tool will help you clean up local and remote branches that have been merged into a target branch."
    echo "The process is as follows:"
    echo "  1. You will provide a branch prefix (e.g., feature/)"
    echo "  2. You will provide a target branch for comparison (e.g., develop)"
    echo "  3. The script will automatically check, sync, and ask for confirmation before deleting each merged branch."
    echo "  4. before deleting a branch, the script will print the branch's last commit message to the console."
    echo "------------------------------------------------------------------"
    echo
}

# --- Main Logic Start ---

# 1. Environment Check
# ------------------------------------------------------------------------------
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo -e "${RED}Error: The current directory is not a Git repository.${NC}"
    exit 1
fi

# Display welcome message and instructions
display_usage

# 2. Get User Input (with memory feature)
# ------------------------------------------------------------------------------
LAST_PREFIX=""
LAST_TARGET=""
# If the config file exists, load the saved variables from it
if [[ -f "$CONFIG_FILE" ]]; then
    source "$CONFIG_FILE"
fi

read -p "Enter the branch prefix to check (default: ${LAST_PREFIX:-none}): " input_prefix
branch_prefix=${input_prefix:-$LAST_PREFIX}

read -p "Enter the target branch for comparison (default: ${LAST_TARGET:-develop}): " input_target
target_branch=${input_target:-$LAST_TARGET}

# 3. Validate and Save Input
# ------------------------------------------------------------------------------
if [[ -z "$branch_prefix" ]]; then
    echo -e "${RED}Error: Branch prefix cannot be empty.${NC}"; exit 1;
fi
if [[ -z "$target_branch" ]]; then
    echo -e "${RED}Error: Target branch name cannot be empty.${NC}"; exit 1;
fi
if ! git show-ref --verify --quiet refs/heads/"$target_branch"; then
    echo -e "${RED}Error: Local branch '$target_branch' does not exist.${NC}"; exit 1;
fi

# After validation, save the current input to the config file for the next run
echo "LAST_PREFIX='$branch_prefix'" > "$CONFIG_FILE"
echo "LAST_TARGET='$target_branch'" >> "$CONFIG_FILE"
echo -e "${GREEN}✓ Inputs saved as defaults for the next run.${NC}"
echo

# 4. Sync Remote State and Check Workspace
# ------------------------------------------------------------------------------
echo -e "${YELLOW}Syncing remote branch information (fetch --prune)...${NC}"
git fetch "$REMOTE_NAME" --prune

echo -e "${YELLOW}Switching to and updating target branch '$target_branch'...${NC}"
git checkout "$target_branch"
git pull "$REMOTE_NAME" "$target_branch"

# Check for uncommitted changes in the local working directory
if ! git diff-index --quiet HEAD --; then
    echo -e "${RED}Error: The '$target_branch' branch has uncommitted changes. Please stash or commit them first.${NC}"; exit 1;
fi
# Check if the local target branch is in sync with the remote
local_commit=$(git rev-parse HEAD)
remote_commit=$(git rev-parse "$REMOTE_NAME/$target_branch")
if [[ "$local_commit" != "$remote_commit" ]]; then
    echo -e "${RED}Error: The '$target_branch' branch has unpushed commits. Please push them first.${NC}"; exit 1;
fi

echo -e "${GREEN}✓ Status check for '$target_branch' passed.${NC}"
echo

# 5. Find All Relevant Branches
# ------------------------------------------------------------------------------
echo -e "${YELLOW}Finding all branches matching the prefix '$branch_prefix'...${NC}"

# Use 'git for-each-ref' instead of 'git branch | grep' for more robustness and reliability
local_branches=$(git -c core.quotepath=false for-each-ref --format='%(refname)' "refs/heads/$branch_prefix" | sed 's|^refs/heads/||')
remote_branches=$(git -c core.quotepath=false for-each-ref --format='%(refname)' "refs/remotes/$REMOTE_NAME/$branch_prefix" | sed "s|^refs/remotes/$REMOTE_NAME/||")

# Merge, deduplicate, and exclude the target branch itself
all_branches=$(echo -e "${local_branches}\n${remote_branches}" | grep -v "^$target_branch$" | LC_ALL=C sort -u)

if [[ -z "$all_branches" ]]; then
    echo -e "${YELLOW}No cleanable branches found matching the prefix '$branch_prefix'.${NC}"
    exit 0
fi

echo -e "${BLUE}Found the following branches to check:${NC}"
echo "$all_branches"
echo

# 6. Loop Through and Process Each Branch
# ------------------------------------------------------------------------------
deleted_branches=()
skipped_branches=()
unmerged_branches=()
# Use a more reliable way to count lines to prevent 'wc' errors if all_branches is empty
if [[ -n "$all_branches" ]]; then
    total_count=$(echo "$all_branches" | wc -l)
else
    total_count=0
fi

# Use file descriptor 3 for the loop to avoid conflicts with the 'read' command inside
while IFS= read -r -u 3 branch; do
    # Skip empty lines
    [[ -z "$branch" ]] && continue

    echo -e "${BLUE}--- Checking branch: $branch ---${NC}"

    # Accurately determine if the branch exists locally and remotely
    local_exists=$(git show-ref --verify --quiet "refs/heads/$branch" && echo "true" || echo "false")
    remote_exists=$(git show-ref --verify --quiet "refs/remotes/$REMOTE_NAME/$branch" && echo "true" || echo "false")

    # Determine the commit to check for merge status, preferring the remote branch
    commit_to_check=""
    if [[ "$remote_exists" == "true" ]]; then
        commit_to_check=$(git rev-parse "refs/remotes/$REMOTE_NAME/$branch")
    elif [[ "$local_exists" == "true" ]]; then
        commit_to_check=$(git rev-parse "refs/heads/$branch")
    else
        echo -e "${RED}Warning: Could not find any reference for branch '$branch'. Skipped.${NC}"
        continue
    fi

    # Core logic: Check if the branch's commit is an ancestor of the current target branch (HEAD)
    if git merge-base --is-ancestor "$commit_to_check" HEAD; then
        echo -e "${GREEN}✓ Merged: Changes from '$branch' are included in '$target_branch'.${NC}"

        commit_message=$(git log -1 --pretty=format:"%s" "$commit_to_check")
        echo -e "  ${CYAN}Last commit: id:$commit_to_check, message: $commit_message${NC}"

        # Gracefully build the prompt message
        prompt_parts=()
        log_parts=()
        [[ "$local_exists" == "true" ]] && { prompt_parts+=("local"); log_parts+=("local"); }
        [[ "$remote_exists" == "true" ]] && { prompt_parts+=("remote"); log_parts+=("remote"); }
        prompt_string=$(IFS=' and '; echo "${prompt_parts[*]}")

        read -p "  Delete ${prompt_string} branch '$branch'? (y/N): " confirm

        if [[ "$confirm" =~ ^[Yy]$ ]]; then
            # Safe deletion order: local first, then remote
            if [[ "$local_exists" == "true" ]]; then
                echo -e "  ${YELLOW}Deleting local branch...${NC}"
                git branch -D "$branch"
            fi
            if [[ "$remote_exists" == "true" ]]; then
                echo -e "  ${YELLOW}Deleting remote branch...${NC}"
                git push "$REMOTE_NAME" --delete "$branch"
            fi
            deleted_branches+=("$branch ($(IFS='+'; echo "${log_parts[*]}"))")
            echo -e "  ${GREEN}✓ Deleted.${NC}"
        else
            skipped_branches+=("$branch")
            echo -e "  ${YELLOW}✗ Skipped by user.${NC}"
        fi
    else
        unmerged_branches+=("$branch")
        echo -e "${YELLOW}✗ Unmerged: Changes from '$branch' are not fully merged. Skipped.${NC}"
    fi
    echo
done 3<<< "$all_branches"

# 7. Display Final Summary Report
# ------------------------------------------------------------------------------
echo "=================================================================="
echo -e "${BLUE}Execution Complete - Final Report${NC}"
echo "=================================================================="
echo "  Total branches checked: $total_count"
echo -e "  ${GREEN}Successfully deleted: ${#deleted_branches[@]}${NC}"
echo -e "  ${YELLOW}Skipped by user:      ${#skipped_branches[@]}${NC}"
echo -e "  ${RED}Unmerged:             ${#unmerged_branches[@]}${NC}"
echo

if [[ ${#deleted_branches[@]} -gt 0 ]]; then
    echo -e "${GREEN}List of deleted branches:${NC}"
    for branch in "${deleted_branches[@]}"; do echo "  - $branch"; done
    echo
fi

if [[ ${#skipped_branches[@]} -gt 0 ]]; then
    echo -e "${YELLOW}Branches skipped by user (merged but not deleted):${NC}"
    for branch in "${skipped_branches[@]}"; do echo "  - $branch"; done
    echo
fi

if [[ ${#unmerged_branches[@]} -gt 0 ]]; then
    echo -e "${RED}Unmerged branches (require manual review):${NC}"
    for branch in "${unmerged_branches[@]}"; do echo "  - $branch"; done
    echo
fi

echo -e "${GREEN}Script finished.${NC}"
