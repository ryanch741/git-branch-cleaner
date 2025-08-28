# 🚀 Git Branch Cleanup Tool

<p align="center">
  <img src="https://img.shields.io/badge/Version-4.0-blue.svg" alt="Version">
  <img src="https://img.shields.io/badge/Shell-Bash-green.svg" alt="Shell">
  <img src="https://img.shields.io/badge/License-MIT-orange.svg" alt="License">
  <img src="https://img.shields.io/badge/PRs-Welcome-brightgreen.svg" alt="PRs Welcome">
</p>

<p align="center">
  <strong>An interactive Git branch cleanup tool powered by shell script.</strong>
  <br>
  一款强大、安全且人性化的交互式 Git 分支清理工具。
</p>

---

[**English**](#-english) | [**中文**](#-中文)

---

## 🇬🇧 English

### ✨ Overview

In a typical Git workflow, development teams create numerous branches like `feature/`, `fix/`, or `hotfix/`. Over time, many merged branches accumulate in both local and remote repositories, leading to clutter and making it difficult to navigate.

This tool automates the cleanup process. It intelligently identifies branches that have been merged into a target branch (e.g., `develop` or `main`) and interactively guides you through a safe and efficient cleanup process, keeping your repository tidy and clean.

### 🌟 Key Features

-   **🎯 Smart Matching**: Automatically finds all local and remote branches matching a specified prefix (e.g., `feature/`).
-   **✅ Safe by Design**: Rigorously checks if each branch is fully merged into your target branch. **It will never delete unmerged branches.**
-   **🤝 Interactive Confirmation**: For every deletable branch, it clearly prompts for your confirmation, giving you full control and preventing accidental deletions.
-   **🧠 Memory Function**: Remembers the last "branch prefix" and "target branch" you used, setting them as defaults for the next run to boost your efficiency.
-   **🔄 Unified Handling**: Seamlessly processes both local and remote branches in a safe order (local first, then remote).
-   **📊 Clear Reporting**: After execution, it provides a detailed, categorized summary report (Deleted, Skipped by user, Unmerged) so you know exactly what happened.
-   **🛡️ Pre-flight Checks**: Automatically syncs with the remote, checks for uncommitted changes, and ensures the target branch is up-to-date before performing any actions.

### 🚀 Installation

1.  **Clone or Download**:
    Get the script `git-cleanup.sh` from this repository.

    ```bash
    git clone https://github.com/YOUR_USERNAME/YOUR_REPOSITORY.git
    cd YOUR_REPOSITORY
    ```

2.  **Make it Executable**:
    Give the script execution permissions.
    ```bash
    chmod +x git-cleanup.sh
    ```

3.  **(Recommended) Add to Your PATH**:
    For easy access from any repository on your system, move it to a directory in your system's PATH.
    ```bash
    sudo mv git-cleanup.sh /usr/local/bin/git-cleanup
    ```
    Now, you can simply run `git-cleanup` anywhere.

### 💡 How to Use

1.  Navigate to your Git project directory in the terminal.
2.  Run the script:
    ```bash
    # If in the current directory
    ./git-cleanup.sh

    # If installed in your PATH
    git-cleanup
    ```
3.  Follow the interactive prompts:
    *   **Enter the branch prefix to check**: e.g., `feature/` or `fix/`.
    *   **Enter the target branch name for comparison**: e.g., `develop` or `main`.
4.  The script will then check each branch and ask for confirmation before deleting any that are merged. Simply type `y` to delete or press `Enter` to skip.

### 🤖 AI Integration (with Gemini CLI)

You can also trigger this script using AI like Google's Gemini CLI.

1.  **Create `tool_config.json`**:
    In your project directory, create a `tool_config.json` file with the following content:
    ```json
    {
      "tool_config": {
        "function_declarations": [
          {
            "name": "start_interactive_git_cleanup",
            "description": "Starts a local, interactive script to clean up Git branches. The script will guide the user through all subsequent steps.",
            "parameters": {"type": "OBJECT", "properties": {}, "required": []}
          }
        ]
      },
      "tool_execution_config": {
        "local_tool_execution": {
          "command_specifications": [
            {
              "function_name": "start_interactive_git_cleanup",
              "command": ["./git-cleanup.sh"]
            }
          ]
        }
      }
    }
    ```

2.  **Run with Gemini CLI**:
    Start the chat session by pointing to your tool configuration file.
    ```bash
    gemini chat --tool_config_file=tool_config.json
    ```

3.  **Interact with AI**:
    Now, you can ask Gemini to run the tool for you.
    ```
    You: Help me clean up my git branches.

    (Gemini will execute the script, and you can continue the process in your terminal.)
    ```

---

## 🇨🇳 中文

### ✨ 概述

在日常的 Git 工作流中，团队会创建大量的 `feature/`, `fix/` 或 `hotfix/` 分支。随着时间推移，许多已经合并的分支会堆积在本地和远程仓库中，造成信息冗余，干扰开发视线。

本工具旨在自动化地解决这一问题。它能够智能地识别已合并的分支，并通过交互式的方式，安全、高效地帮助您清理这些不再需要的分支，让您的仓库保持整洁。

### 🌟 核心功能

-   **🎯 智能匹配**: 自动查找所有匹配指定前缀（如 `feature/`）的本地和远程分支。
-   **✅ 安全第一**: 严格校验每个分支是否已完全合并到您指定的目标分支。**绝不删除未合并的分支**。
-   **🤝 交互式确认**: 对每一个可删除的分支，都会清晰地询问您是否执行删除操作，给予您完全的控制权，防止误删。
-   **🧠 记忆功能**: 自动记住您上次使用的“分支前缀”和“目标分支”，下次运行时直接作为默认值，大幅提升效率。
-   **🔄 统一处理**: 无缝处理本地与远程分支，并采用先删本地、后删远程的安全顺序。
-   **📊 清晰报告**: 脚本执行完毕后，提供一份详细的分类统计报告（已删除、用户跳过、未合并），让您对清理结果一目了然。
-   **🛡️ 环境预检**: 在执行核心逻辑前，会自动同步远程数据、检查工作区状态，并确保目标分支处于最新状态，避免在错误的环境下执行操作。

### 🚀 安装指南

1.  **克隆或下载**:
    从本仓库获取 `git-cleanup.sh` 脚本。
    ```bash
    git clone https://github.com/YOUR_USERNAME/YOUR_REPOSITORY.git
    cd YOUR_REPOSITORY
    ```

2.  **添加执行权限**:
    ```bash
    chmod +x git-cleanup.sh
    ```

3.  **(推荐) 加入系统路径**:
    为了方便在任何项目中使用，可以将其移动到您的系统路径下。
    ```bash
    sudo mv git-cleanup.sh /usr/local/bin/git-cleanup
    ```
    之后，您就可以在任何 Git 仓库中直接通过 `git-cleanup` 命令来运行它。

### 💡 如何使用

1.  在终端中，进入您需要清理的 Git 项目目录。
2.  运行脚本：
    ```bash
    # 如果脚本在当前目录
    ./git-cleanup.sh

    # 如果已安装到系统路径
    git-cleanup
    ```
3.  根据交互式提示，依次输入信息：
    *   **分支前缀**: 您想要清理的分支的共同前缀，例如 `feature/`。
    *   **目标分支**: 用来判断其他分支是否已合并的基准分支，例如 `develop`。
4.  脚本会开始检查，并对每个已合并的分支逐一询问您是否删除。输入 `y` 删除，或按回车键跳过。

### 🤖 AI 集成 (使用 Gemini CLI)

您也可以通过像 Google Gemini CLI 这样的 AI 工具来触发此脚本。

1.  **创建 `tool_config.json` 文件**:
    在您的项目目录中，创建 `tool_config.json` 文件并填入以下内容：
    ```json
    {
      "tool_config": {
        "function_declarations": [
          {
            "name": "start_interactive_git_cleanup",
            "description": "启动一个本地的、交互式的脚本来清理 Git 分支。该脚本将引导用户完成所有后续步骤。",
            "parameters": {"type": "OBJECT", "properties": {}, "required": []}
          }
        ]
      },
      "tool_execution_config": {
        "local_tool_execution": {
          "command_specifications": [
            {
              "function_name": "start_interactive_git_cleanup",
              "command": ["./git-cleanup.sh"]
            }
          ]
        }
      }
    }
    ```

2.  **运行 Gemini CLI**:
    通过指定工具配置文件来启动聊天会话。
    ```bash
    gemini chat --tool_config_file=tool_config.json
    ```

3.  **与 AI 交互**:
    现在，您可以让 AI 帮您运行这个工具了。
    ```
    你: 帮我清理一下 git 分支

    (Gemini 将会执行脚本，之后您可以在终端中继续交互式操作。)
    ```

---

### 📜 License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

### 🙌 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
