# Git Branch Cleanup Tool

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A powerful, smart, and safe batch cleanup tool for Git branches, designed to help developers say goodbye to cluttered branch lists.

[中文版](./README_cn.md)

---

Have you ever been troubled by the large number of merged `feature/`, `fix/`, or `hotfix/` branches in your project? Manually checking and deleting them one by one is both tedious and error-prone.

**This tool is your solution!** It automates the process of finding, checking, and interactively cleaning up branches that have served their purpose, keeping your repository tidy.

## Demo

Here is a demonstration of the tool in action:

```bash
# The script's UI is in Chinese, as shown below.
=== Git 分支清理工具 ===

本工具将帮助您清理已经合并到目标分支的本地和远程分支。
流程如下:
  1. 您需要提供一个分支前缀 (如: feature/)
  2. 您需要提供一个用于比较的目标分支 (如: develop)
  3. 脚本会自动检查、同步，并逐一询问您是否删除已合并的分支。
------------------------------------------------------------------

请输入要检查的分支前缀 (默认为: feature/): feature/
请输入比较的目标分支名 (默认为: develop): develop
✓ 已将输入保存为下次的默认值

正在同步远程分支信息 (fetch --prune)...
正在切换并更新目标分支 'develop'...
develop 分支状态检查通过

正在查找匹配前缀 'feature/' 的所有分支...
找到以下待检查分支:
feature/add-login-form
feature/fix-payment-bug
feature/user-profile-refactor

--- 正在检查分支: feature/add-login-form ---
✓ 已合并: 'feature/add-login-form' 的更改已包含在 'develop' 中
  是否删除 本地和远程 分支 'feature/add-login-form'? (y/N): y
  正在删除本地分支...
  正在删除远程分支...
  ✓ 已删除

--- 正在检查分支: feature/fix-payment-bug ---
✗ 未合并: 'feature/fix-payment-bug' 的更改尚未完全合并，已跳过

--- 正在检查分支: feature/user-profile-refactor ---
✓ 已合并: 'feature/user-profile-refactor' 的更改已包含在 'develop' 中
  是否删除 本地和远程 分支 'feature/user-profile-refactor'? (y/N): n
  ✗ 用户选择跳过

==================================================================
执行完成 - 最终报告
==================================================================
  总共检查分支数: 3
  成功删除: 1
  用户跳过: 1
  未 合 并: 1

已删除的分支列表:
  - feature/add-login-form (本地+远程)

用户跳过的分支 (已合并但未删除):
  - feature/user-profile-refactor

未合并的分支 (需要您手动检查):
  - feature/fix-payment-bug

脚本执行完毕。
```

## ✨ Key Features

*   **Smart Discovery**: Automatically scans and lists all local and remote branches that match a specified prefix (e.g., `feature/`).
*   **Accurate Merge Checking**: Uses `git merge-base --is-ancestor` for its core logic, ensuring that only branches **fully merged** into the target are marked for deletion. This avoids potential misjudgments from `git branch --merged` in complex histories.
*   **Interactive & Safe Deletion**: Prompts for confirmation for each merged branch, giving you the final say and preventing accidental deletion of important branches.
*   **Unified Local & Remote Handling**: No need to differentiate between local and remote. The tool auto-detects the existence of each and uses a safe deletion order (local first, then remote).
*   **Input Persistence**: Remembers the last branch prefix and target branch you used. Next time, just press Enter to reuse them, significantly improving efficiency.
*   **Pre-run Safety Checks**: Before performing any actions, the script verifies:
    *   If the current directory is a Git repository.
    *   If the target branch has uncommitted or unpushed changes, preventing operations on an inconsistent state.
*   **Clear Summary Report**: After execution, it provides a detailed, categorized report showing which branches were deleted, skipped by the user, or kept because they were unmerged.
*   **Color-coded Output**: Uses different colors to distinguish between states (success, warning, error), making the output easy to read at a glance.

## 🚀 Installation

You can install the script using any of the following methods.

### Option 1: Using curl (Recommended)

Open your terminal and run the following command to download the script and make it executable.

```bash
# Replace YOUR_USERNAME and YOUR_REPO with your actual details
curl -o git-cleanup.sh https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/git-cleanup.sh
chmod +x git-cleanup.sh
```
> **Tip**: To use the script from anywhere, move it to a directory included in your system's `$PATH`, such as `/usr/local/bin`.
> ```bash
> # Optional: Make it globally accessible
> sudo mv git-cleanup.sh /usr/local/bin/git-cleanup
> ```

### Option 2: Manual Download

1.  Find the script file `git-cleanup.sh` in this repository.
2.  Click the "Raw" button, then copy the entire content (Ctrl+A, Ctrl+C).
3.  Create a new file on your local machine, paste the content, and save it as `git-cleanup.sh`.
4.  In your terminal, grant it executable permissions:
    ```bash
    chmod +x git-cleanup.sh
    ```

## 💡 Usage

1.  **Navigate to your Git repository**:
    ```bash
    cd /path/to/your/project
    ```
2.  **Run the script**:
    *   If it's in the current directory: `./git-cleanup.sh`
    *   If installed globally: `git-cleanup`
3.  **Follow the prompts**:
    *   **Enter the branch prefix**: e.g., `feature/`, `fix/`, or `hotfix-`.
    *   **Enter the target branch**: e.g., `develop`, `main`, or `master`. This is the base branch for checking if others are merged.
    *   For each merged branch, type `y` or `Y` to confirm deletion, or simply press Enter to skip.

## ⚙️ Configuration

*   **Memory File**: The script creates a file at `~/.git_cleanup_script.conf` in your home directory to store your last inputs. You can edit or delete this file at any time.
*   **Remote Name**: The script defaults to using `origin` as the remote name. If your remote is named something else, you can change the `REMOTE_NAME` variable at the top of the script.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a pull request or create an issue to improve this tool.

1.  Fork the Project
2.  Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3.  Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4.  Push to the Branch (`git push origin feature/AmazingFeature`)
5.  Open a Pull Request

## 📄 License

This project is licensed under the [MIT License](LICENSE).
