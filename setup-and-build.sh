#!/bin/bash
# 安装 Gradle 并构建插件

set -e

echo "========================================"
echo "  Terminal Memory - Setup & Build"
echo "========================================"
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# 检查 Java
if ! command -v java &> /dev/null; then
    echo "${RED}Java not found. Please install JDK 17 or higher.${NC}"
    echo "macOS: brew install openjdk@17"
    exit 1
fi

JAVA_VERSION=$(java -version 2>&1 | head -1 | cut -d'"' -f2 | cut -d'.' -f1)
if [ "$JAVA_VERSION" != "17" ] && [ "$JAVA_VERSION" != "21" ]; then
    echo "${YELLOW}Warning: Java version is $JAVA_VERSION. Recommended: 17 or 21${NC}"
fi

echo "✓ Java found: $(java -version 2>&1 | head -1)"

# 安装 Gradle（如果没有）
if ! command -v gradle &> /dev/null; then
    echo ""
    echo "Gradle not found. Installing..."
    
    # 使用 Homebrew 安装
    if command -v brew &> /dev/null; then
        echo "Installing via Homebrew..."
        brew install gradle
    else
        # 手动下载安装
        GRADLE_VERSION="8.5"
        echo "Downloading Gradle $GRADLE_VERSION..."
        cd /tmp
        curl -L "https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip" -o gradle.zip
        unzip -q gradle.zip
        mv "gradle-${GRADLE_VERSION}" ~/gradle
        export PATH="$HOME/gradle/bin:$PATH"
        cd ~/github/terminal-memory-intellij
    fi
fi

echo "✓ Gradle found: $(gradle --version | head -1)"

# 构建插件
echo ""
echo "========================================"
echo "  Building Plugin"
echo "========================================"
echo ""

gradle clean buildPlugin

if [ $? -eq 0 ]; then
    echo ""
    echo "${GREEN}========================================${NC}"
    echo "${GREEN}  Build Successful!${NC}"
    echo "${GREEN}========================================${NC}"
    echo ""
    
    PLUGIN_FILE=$(find build/distributions -name "*.zip" | head -1)
    if [ -f "$PLUGIN_FILE" ]; then
        echo "Plugin location:"
        echo "  $PWD/$PLUGIN_FILE"
        echo ""
        echo "To install:"
        echo "  1. Open IntelliJ IDEA"
        echo "  2. Settings → Plugins → Gear Icon"
        echo "  3. Install Plugin from Disk"
        echo "  4. Select: $PWD/$PLUGIN_FILE"
        echo ""
        
        # 显示文件大小
        ls -lh "$PLUGIN_FILE"
    fi
else
    echo "${RED}Build failed!${NC}"
    exit 1
fi
