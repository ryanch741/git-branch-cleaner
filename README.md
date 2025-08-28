# Git Branch Cleanup Tool

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A powerful, smart, and safe batch cleanup tool for Git branches, designed to help developers say goodbye to cluttered branch lists.

[中文版](./README_cn.md)

---

Are you tired of a long, messy list of merged `feature/`, `fix/`, or `hotfix/` branches in your project? Manually checking and deleting them is tedious and error-prone.

**This tool is your solution!** It automates the process of finding, checking, and interactively cleaning up branches that have served their purpose, keeping your repository tidy and professional.

## Demo

Here is a demonstration of the tool in action:

```bash
=== Git Branch Cleanup Tool ===

This tool will help you clean up local and remote branches that have been merged into a target branch.
The process is as follows:
  1. You will provide a branch prefix (e.g., feature/)
  2. You will provide a target branch for comparison (e.g., develop)
  3. The script will automatically check, sync, and ask for confirmation before deleting each merged branch.
------------------------------------------------------------------

Enter the branch prefix to check (default: feature/): feature/
Enter the target branch for comparison (default: develop): develop
✓ Inputs saved as defaults for the next run.

Syncing remote branch information (fetch --prune)...
Switching to and updating target branch 'develop'...
✓ Status check for 'develop' passed.

Finding all branches matching the prefix 'feature/'...
Found the following branches to check:
feature/add-login-form
feature/fix-payment-bug
feature/user-profile-refactor

--- Checking branch: feature/add-login-form ---
✓ Merged: Changes from 'feature/add-login-form' are included in 'develop'.
  Delete local and remote branch 'feature/add-login-form'? (y/N): y
  Deleting local branch...
  Deleting remote branch...
  ✓ Deleted.

--- Checking branch: feature/fix-payment-bug ---
✗ Unmerged: Changes from 'feature/fix-payment-bug' are not fully merged. Skipped.

--- Checking branch: feature/user-profile-refactor ---
✓ Merged: Changes from 'feature/user-profile-refactor' are included in 'develop'.
  Delete local and remote branch 'feature/user-profile-refactor'? (y/N): n
  ✗ Skipped by user.

==================================================================
Execution Complete - Final Report
==================================================================
  Total branches checked: 3
  Successfully deleted: 1
  Skipped by user:      1
  Unmerged:             1

List of deleted branches:
  - feature/add-login-form (local+remote)

Branches skipped by user (merged but not deleted):
  - feature/user-profile-refactor

Unmerged branches (require manual review):
  - feature/fix-payment-bug

Script finished.
```

## ✨ Key Features

*   **Smart Discovery**: Automatically scans and lists all local and remote branches that match a specified prefix (e.g., `feature/`).
*   **Accurate Merge Checking**: Uses `git merge-base --is-ancestor` for its core logic, ensuring that only branches **fully merged** into the target are marked for deletion. This is more reliable than other methods in complex histories.
*   **Interactive & Safe Deletion**: Prompts for confirmation for each merged branch, giving you the final say and preventing accidental deletion.
*   **Unified Local & Remote Handling**: Auto-detects if a branch exists locally, remotely, or both, and uses a safe deletion order (local first, then remote).
*   **Input Persistence**: Remembers the last branch prefix and target branch you used, speeding up subsequent runs.
*   **Pre-run Safety Checks**: Verifies that the current directory is a Git repo and that the target branch has no uncommitted or unpushed changes before proceeding.
*   **Clear Summary Report**: Provides a detailed, categorized report after execution, showing exactly what was deleted, skipped, or left for manual review.
*   **Color-coded Output**: Uses colors to clearly distinguish between success, warning, and error messages for a better user experience.

## 🚀 Installation

### Option 1: Using curl (Recommended)

```bash
# Replace YOUR_USERNAME and YOUR_REPO with your actual details
curl -o git-cleanup.sh https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/git-cleanup.sh
chmod +x git-cleanup.sh
# Optional: Make it globally accessible
sudo mv git-cleanup.sh /usr/local/bin/git-cleanup
```

### Option 2: Manual Download
1.  Find the `git-cleanup.sh` script file in this repository.
2.  Click the "Raw" button and copy the entire content.
3.  Create a new file on your local machine, paste the content, and save it as `git-cleanup.sh`.
4.  In your terminal, grant it executable permissions: `chmod +x git-cleanup.sh`.


## 💡 Usage

1.  **Navigate to your Git repository**: `cd /path/to/your/project`
2.  **Run the script**: `./git-cleanup.sh` (or `git-cleanup` if installed globally).
3.  **Follow the prompts**: Enter the branch prefix and target branch, then confirm deletions with `y`.

## ⚙️ Configuration

*   **Memory File**: The script creates a file at `~/.git_cleanup_script.conf` to store your last inputs.
*   **Remote Name**: The remote is hardcoded as `origin`. You can change the `REMOTE_NAME` variable at the top of the script if you use a different name.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a pull request or create an issue to improve this tool.

1.  Fork the Project
2.  Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3.  Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4.  Push to the Branch (`git push origin feature/AmazingFeature`)
5.  Open a Pull Request

## ❤️ Sponsor

If you find this tool helpful and it saves you time, please consider buying me a coffee!

Your support is a great motivator for me to continue maintaining and improving this project. Thank you!

  | WeChat Pay | Alipay |
  | :---: | :---: |
  | <img src="https://raw.githubusercontent.com/ryanch741/git-branch-cleaner/main/wx_pay_qr.jpg" alt="WeChat Pay QR Code" width="200"> | <img src="https://raw.githubusercontent.com/ryanch741/git-branch-cleaner/main/ali_pay_qr.jpg" alt="Alipay QR Code" width="200"> |



## 📄 License

This project is licensed under the [MIT License](LICENSE).
```
