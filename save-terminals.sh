#!/bin/bash
# IntelliJ IDEA 保存终端会话脚本
# 在 IntelliJ 中配置为 External Tool 使用

# 获取项目路径
PROJECT_PATH="${1:-$(pwd)}"
PROJECT_NAME=$(basename "$PROJECT_PATH")
WORKSPACE_ID=$(echo -n "$PROJECT_PATH" | md5 | cut -c1-16)

# 设置环境变量
export WORKSPACE_ID="$WORKSPACE_ID"
export IDE_TYPE="intellij"
export PROJECT_PATH="$PROJECT_PATH"

# 调用 Python 模块
python3 "/Users/dxm/github/memory-control-room/terminal-memory/core/cli.py" \
    capture \
    "$WORKSPACE_ID" \
    "{\"ide_type\":\"intellij\",\"project_path\":\"$PROJECT_PATH\"}"

echo ""
echo "Terminal sessions saved for project: $PROJECT_NAME"
