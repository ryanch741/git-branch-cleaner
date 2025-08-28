#!/bin/bash

# ==============================================================================
# Git 分支清理工具 (Git Branch Cleanup Tool)
# 版本: 4.4
#
# 功能:
#   - 自动查找匹配指定前缀的本地和远程分支。
#   - 检查这些分支是否已经合并到指定的目标分支。
#   - 对已合并的分支，交互式地询问用户是否删除。
#   - 统一处理本地和远程分支，并采用安全的删除顺序（先本地后远程）。
#   - 记忆上次输入的分支前缀和目标分支，提升效率。
#   - 提供清晰的分类统计报告（已删除、用户跳过、未合并）。
# ==============================================================================

set -e

# 强制设置脚本的区域设置为UTF-8，以确保正确处理包含中文等非ASCII字符的分支名。
export LC_ALL=en_US.UTF-8

# --- 全局配置与常量 ---

# 记忆输入的配置文件路径
readonly CONFIG_FILE="$HOME/.git_cleanup_script.conf"
# 远程仓库的名称 (硬编码为 origin，可根据需要修改)
readonly REMOTE_NAME="origin"

# --- 颜色定义 ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# --- 函数定义 ---

# 功能: 显示欢迎信息和使用说明
display_usage() {
    echo -e "${BLUE}=== Git 分支清理工具 ===${NC}"
    echo
    echo "本工具将帮助您清理已经合并到目标分支的本地和远程分支。"
    echo "流程如下:"
    echo "  1. 您需要提供一个分支前缀 (如: feature/)"
    echo "  2. 您需要提供一个用于比较的目标分支 (如: develop)"
    echo "  3. 脚本会自动检查、同步，并逐一询问您是否删除已合并的分支。"
    echo "------------------------------------------------------------------"
    echo
}

# --- 主逻辑开始 ---

# 1. 环境检查
# ------------------------------------------------------------------------------
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo -e "${RED}错误: 当前目录不是一个Git仓库${NC}"
    exit 1
fi

# 显示欢迎和说明信息
display_usage

# 2. 获取用户输入 (带记忆功能)
# ------------------------------------------------------------------------------
LAST_PREFIX=""
LAST_TARGET=""
# 如果配置文件存在，则加载其中保存的变量
if [[ -f "$CONFIG_FILE" ]]; then
    source "$CONFIG_FILE"
fi

read -p "请输入要检查的分支前缀 (默认为: ${LAST_PREFIX:-无}): " input_prefix
branch_prefix=${input_prefix:-$LAST_PREFIX}

read -p "请输入比较的目标分支名 (默认为: ${LAST_TARGET:-develop}): " input_target
target_branch=${input_target:-$LAST_TARGET}

# 3. 验证与保存输入
# ------------------------------------------------------------------------------
if [[ -z "$branch_prefix" ]]; then
    echo -e "${RED}错误: 分支前缀不能为空${NC}"; exit 1;
fi
if [[ -z "$target_branch" ]]; then
    echo -e "${RED}错误: 目标分支名不能为空${NC}"; exit 1;
fi
if ! git show-ref --verify --quiet refs/heads/"$target_branch"; then
    echo -e "${RED}错误: 本地分支 '$target_branch' 不存在${NC}"; exit 1;
fi

# 验证通过后，将本次的输入写入配置文件，供下次使用
echo "LAST_PREFIX='$branch_prefix'" > "$CONFIG_FILE"
echo "LAST_TARGET='$target_branch'" >> "$CONFIG_FILE"
echo -e "${GREEN}✓ 已将输入保存为下次的默认值${NC}"
echo

# 4. 同步远程状态并检查工作区
# ------------------------------------------------------------------------------
echo -e "${YELLOW}正在同步远程分支信息 (fetch --prune)...${NC}"
git fetch "$REMOTE_NAME" --prune

echo -e "${YELLOW}正在切换并更新目标分支 '$target_branch'...${NC}"
git checkout "$target_branch"
git pull "$REMOTE_NAME" "$target_branch"

# 检查本地是否有未提交的更改
if ! git diff-index --quiet HEAD --; then
    echo -e "${RED}错误: $target_branch 分支有未提交的更改，请先处理${NC}"; exit 1;
fi
# 检查本地目标分支是否与远程同步
local_commit=$(git rev-parse HEAD)
remote_commit=$(git rev-parse "$REMOTE_NAME/$target_branch")
if [[ "$local_commit" != "$remote_commit" ]]; then
    echo -e "${RED}错误: $target_branch 分支有未推送的提交，请先推送${NC}"; exit 1;
fi

echo -e "${GREEN}$target_branch 分支状态检查通过${NC}"
echo

# 5. 查找所有相关分支
# ------------------------------------------------------------------------------
echo -e "${YELLOW}正在查找匹配前缀 '$branch_prefix' 的所有分支...${NC}"

# 使用 git for-each-ref 代替 'git branch | grep'，更健壮可靠
local_branches=$(git -c core.quotepath=false for-each-ref --format='%(refname)' "refs/heads/$branch_prefix" | sed 's|^refs/heads/||')
remote_branches=$(git -c core.quotepath=false for-each-ref --format='%(refname)' "refs/remotes/$REMOTE_NAME/$branch_prefix" | sed "s|^refs/remotes/$REMOTE_NAME/||")

# 合并并去重，排除目标分支自身
all_branches=$(echo -e "${local_branches}\n${remote_branches}" | grep -v "^$target_branch$" | LC_ALL=C sort -u)

if [[ -z "$all_branches" ]]; then
    echo -e "${YELLOW}没有找到匹配前缀 '$branch_prefix' 的可清理分支${NC}"
    exit 0
fi

echo -e "${BLUE}找到以下待检查分支:${NC}"
echo "$all_branches"
echo

# 6. 循环检查并处理每个分支
# ------------------------------------------------------------------------------
deleted_branches=()
skipped_branches=()
unmerged_branches=()
# 使用更可靠的方式计算行数，以防all_branches为空时wc返回错误
if [[ -n "$all_branches" ]]; then
    total_count=$(echo "$all_branches" | wc -l)
else
    total_count=0
fi

# 使用文件描述符3进行循环读取，避免与内部的read命令冲突
while IFS= read -r -u 3 branch; do
    # 跳过空行
    [[ -z "$branch" ]] && continue

    echo -e "${BLUE}--- 正在检查分支: $branch ---${NC}"

    # 精确判断分支在本地和远程的存在状态
    local_exists=$(git show-ref --verify --quiet "refs/heads/$branch" && echo "true" || echo "false")
    remote_exists=$(git show-ref --verify --quiet "refs/remotes/$REMOTE_NAME/$branch" && echo "true" || echo "false")

    # 确定用于检查合并状态的commit，优先使用远程分支
    commit_to_check=""
    if [[ "$remote_exists" == "true" ]]; then
        commit_to_check=$(git rev-parse "refs/remotes/$REMOTE_NAME/$branch")
    elif [[ "$local_exists" == "true" ]]; then
        commit_to_check=$(git rev-parse "refs/heads/$branch")
    else
        echo -e "${RED}警告: 无法找到分支 '$branch' 的任何引用，已跳过。${NC}"
        continue
    fi

    # 核心判断：检查分支的commit是否为当前目标分支的祖先
    if git merge-base --is-ancestor "$commit_to_check" HEAD; then
        echo -e "${GREEN}✓ 已合并: '$branch' 的更改已包含在 '$target_branch' 中${NC}"

        # 优雅地构建提示信息
        prompt_parts=()
        log_parts=()
        [[ "$local_exists" == "true" ]] && { prompt_parts+=("本地"); log_parts+=("本地"); }
        [[ "$remote_exists" == "true" ]] && { prompt_parts+=("远程"); log_parts+=("远程"); }
        prompt_string=$(IFS='和'; echo "${prompt_parts[*]}")

        read -p "  是否删除 ${prompt_string} 分支 '$branch'? (y/N): " confirm

        if [[ "$confirm" =~ ^[Yy]$ ]]; then
            # 安全删除顺序：先本地，后远程
            if [[ "$local_exists" == "true" ]]; then
                echo -e "  ${YELLOW}正在删除本地分支...${NC}"
                git branch -D "$branch"
            fi
            if [[ "$remote_exists" == "true" ]]; then
                echo -e "  ${YELLOW}正在删除远程分支...${NC}"
                git push "$REMOTE_NAME" --delete "$branch"
            fi
            deleted_branches+=("$branch ($(IFS='+'; echo "${log_parts[*]}"))")
            echo -e "  ${GREEN}✓ 已删除${NC}"
        else
            skipped_branches+=("$branch")
            echo -e "  ${YELLOW}✗ 用户选择跳过${NC}"
        fi
    else
        unmerged_branches+=("$branch")
        echo -e "${YELLOW}✗ 未合并: '$branch' 的更改尚未完全合并，已跳过${NC}"
    fi
    echo
done 3<<< "$all_branches"

# 7. 显示最终的统计报告
# ------------------------------------------------------------------------------
echo "=================================================================="
echo -e "${BLUE}执行完成 - 最终报告${NC}"
echo "=================================================================="
echo "  总共检查分支数: $total_count"
echo -e "  ${GREEN}成功删除: ${#deleted_branches[@]}${NC}"
echo -e "  ${YELLOW}用户跳过: ${#skipped_branches[@]}${NC}"
echo -e "  ${RED}未 合 并: ${#unmerged_branches[@]}${NC}"
echo

if [[ ${#deleted_branches[@]} -gt 0 ]]; then
    echo -e "${GREEN}已删除的分支列表:${NC}"
    for branch in "${deleted_branches[@]}"; do echo "  - $branch"; done
    echo
fi

if [[ ${#skipped_branches[@]} -gt 0 ]]; then
    echo -e "${YELLOW}用户跳过的分支 (已合并但未删除):${NC}"
    for branch in "${skipped_branches[@]}"; do echo "  - $branch"; done
    echo
fi

if [[ ${#unmerged_branches[@]} -gt 0 ]]; then
    echo -e "${RED}未合并的分支 (需要您手动检查):${NC}"
    for branch in "${unmerged_branches[@]}"; do echo "  - $branch"; done
    echo
fi

echo -e "${GREEN}脚本执行完毕。${NC}"
