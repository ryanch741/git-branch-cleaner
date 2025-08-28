# Git 分支清理工具 (Git Branch Cleanup Tool)

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

一个强大、智能且安全的 Git 分支批量清理工具，旨在帮助开发者告别杂乱无章的分支列表。

[English Version](./README.md)

---

你是否也曾被项目中大量已合并的 `feature/`、`fix/` 或 `hotfix/` 分支所困扰？手动逐一检查和删除它们既繁琐又容易出错。

**这个工具就是你的解决方案！** 它能自动化地查找、检查并以交互方式清理那些已经完成使命的分支，让你的仓库保持整洁。

## 演示 (Demo)

```bash
=== Git 分支清理工具 ===

本工具将帮助您清理已经合并到目标分支的本地和远程分支。
流程如下:
  1. 您需要提供一个分支前缀 (如: feature/)
  2. 您需要提供一个用于比较的目标分支 (如: develop)
  3. 脚本会自动检查、同步，并逐一询问您是否删除已合并的分支。
------------------------------------------------------------------

请输入要检查的分支前缀 (默认为: feature/): feature/
请输入比较的目标分支名 (默认为: develop): develop
...
```

## ✨ 主要特性 (Key Features)

*   **智能查找**: 自动扫描并列出所有匹配指定前缀（如 `feature/`）的本地和远程分支。
*   **精确的合并检查**: 使用 `git merge-base --is-ancestor` 进行核心判断，确保只有被**完全合并**的分支才会被标记为可删除。
*   **交互式安全删除**: 对每一个已合并的分支，都会逐一询问用户，给你最终的决定权。
*   **统一处理**: 无需区分本地和远程，工具会自动检测并采用先本地后远程的安全删除顺序。
*   **记忆功能**: 自动记住你上次使用的配置，极大提升效率。
*   **环境安全检查**: 在执行前会检查仓库状态，防止在不一致的状态下进行操作。
*   **清晰的总结报告**: 脚本执行完毕后，提供详细的分类报告。
*   **色彩高亮**: 通过不同颜色的输出来区分状态，信息一目了然。

## 🚀 安装 (Installation)

### 方式一: 使用 curl (推荐)

```bash
# 替换 YOUR_USERNAME 和 YOUR_REPO
curl -o git-cleanup.sh https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/git-cleanup.sh
chmod +x git-cleanup.sh
# 可选步骤：全局安装
sudo mv git-cleanup.sh /usr/local/bin/git-cleanup
```

### 方式二: 手动下载
1.  在本仓库中找到脚本文件 `git-cleanup.sh`。
2.  点击 "Raw" 按钮，复制全部内容。
3.  在本地创建 `git-cleanup.sh` 文件并粘贴内容。
4.  添加可执行权限: `chmod +x git-cleanup.sh`。


## 💡 使用方法 (Usage)

1.  **进入你的 Git 仓库目录**: `cd /path/to/your/project`
2.  **运行脚本**: `./git-cleanup.sh` (或全局安装后的 `git-cleanup`)
3.  **按照提示操作**。

## ⚙️ 配置 (Configuration)

*   **记忆文件**: 脚本会在 `~/.git_cleanup_script.conf` 保存你的上次输入。
*   **远程仓库名**: 默认使用 `origin`，可修改脚本顶部的 `REMOTE_NAME` 变量。

## 🤝 贡献 (Contributing)

欢迎通过提交 Pull Request 或创建 Issue 来帮助改进这个工具！

1.  Fork 本仓库
2.  创建你的功能分支 (`git checkout -b feature/AmazingFeature`)
3.  提交你的更改 (`git commit -m 'Add some AmazingFeature'`)
4.  推送到分支 (`git push origin feature/AmazingFeature`)
5.  打开一个 Pull Request

## ❤️ 支持作者 (Sponsor)

如果你觉得这个项目对你有帮助，节省了你的时间，可以考虑请我喝杯咖啡！

你的支持是我持续维护和改进项目的巨大动力，感谢你！

  | 微信支付 (WeChat Pay) | 支付宝 (Alipay) |
  | :---: | :---: |
  | <img src="https://raw.githubusercontent.com/ryanch741/git-branch-cleaner/main/wx_pay_qr.jpg" alt="微信赞赏码" width="200"> | <img src="https://raw.githubusercontent.com/ryanch741/git-branch-cleaner/main/ali_pay_qr.jpg" alt="支付宝赞赏码" width="200"> |


## 📄 许可证 (License)

本项目采用 [MIT License](LICENSE) 授权。
```

### 方案亮点：

1.  **位置优雅**：放在 `贡献` 和 `许可证` 之间，既表达了感谢，又不影响核心信息的阅读。
2.  **折叠设计 (`<details>`)**：默认将二维码折叠起来，让页面保持整洁。感兴趣的用户可以主动点击展开，体验非常好。
3.  **清晰的引导语**：“请我喝杯咖啡”是一种轻松、友好的说法，更容易被接受。
4.  **明确的提示**：在代码中留下了清晰的注释，提醒你替换链接和图片，非常贴心。
5.  **表格布局**：同时支持微信和支付宝，布局美观。如果只有一个，可以很方便地删掉其中一列。
