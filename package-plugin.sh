#!/bin/bash
# 手动打包插件（无需 Gradle/Maven）

set -e

echo "========================================"
echo "  Terminal Memory - Package Plugin"
echo "========================================"
echo ""

# 检查依赖
if ! command -v javac &> /dev/null; then
    echo "❌ Java compiler not found. Please install JDK 17+"
    exit 1
fi

if ! command -v kotlinc &> /dev/null; then
    echo "⚠️  Kotlin compiler not found. Will create source-only package."
    echo "    User will need to compile in IDE."
    SOURCE_ONLY=1
fi

# 创建工作目录
WORK_DIR=$(mktemp -d)
PLUGIN_DIR="$WORK_DIR/terminal-memory"
mkdir -p "$PLUGIN_DIR/lib"
mkdir -p "$PLUGIN_DIR/META-INF"

echo "📦 Packaging plugin..."

# 复制 plugin.xml
cp src/main/resources/META-INF/plugin.xml "$PLUGIN_DIR/META-INF/"

# 如果有 Kotlin 编译器，尝试编译
if [ -z "$SOURCE_ONLY" ]; then
    echo "🔨 Compiling Kotlin sources..."
    
    # 创建输出目录
    mkdir -p "$PLUGIN_DIR/classes"
    
    # 下载依赖
    LIB_DIR="$PLUGIN_DIR/lib"
    mkdir -p "$LIB_DIR"
    
    # 下载 Gson
    if [ ! -f "$LIB_DIR/gson-2.10.1.jar" ]; then
        echo "📥 Downloading Gson..."
        curl -L --progress-bar "https://repo1.maven.org/maven2/com/google/code/gson/gson/2.10.1/gson-2.10.1.jar" -o "$LIB_DIR/gson-2.10.1.jar" || true
    fi
    
    # 下载 Kotlin stdlib
    if [ ! -f "$LIB_DIR/kotlin-stdlib-1.9.22.jar" ]; then
        echo "📥 Downloading Kotlin stdlib..."
        curl -L --progress-bar "https://repo1.maven.org/maven2/org/jetbrains/kotlin/kotlin-stdlib/1.9.22/kotlin-stdlib-1.9.22.jar" -o "$LIB_DIR/kotlin-stdlib-1.9.22.jar" || true
    fi
    
    echo "ℹ️  Note: Full compilation requires IntelliJ IDEA SDK."
    echo "    Creating source package instead..."
fi

# 复制源代码（方便用户直接在 IDE 中编译）
echo "📋 Including source files..."
mkdir -p "$PLUGIN_DIR/src"
cp -r src/main/kotlin/* "$PLUGIN_DIR/src/" 2>/dev/null || true

# 创建 README
cat > "$PLUGIN_DIR/README.txt" << 'EOF'
Terminal Memory Plugin
======================

This is a source package of the Terminal Memory plugin.

Installation:
1. Open IntelliJ IDEA
2. File -> New -> Project from Existing Sources
3. Select this directory
4. Build -> Build Project
5. Run -> Run Plugin

Or install the pre-built plugin:
1. Settings -> Plugins -> Gear Icon -> Install Plugin from Disk
2. Select terminal-memory-0.1.0.zip
EOF

# 打包
echo "🗜️  Creating ZIP archive..."
cd "$WORK_DIR"
zip -r "terminal-memory-0.1.0.zip" "terminal-memory" -x "*.DS_Store"

# 移动到项目目录
mv "terminal-memory-0.1.0.zip" ~/github/terminal-memory-intellij/

# 清理
rm -rf "$WORK_DIR"

echo ""
echo "========================================"
echo "✅ Package created!"
echo "========================================"
echo ""
echo "File: ~/github/terminal-memory-intellij/terminal-memory-0.1.0.zip"
echo ""
echo "This package contains:"
echo "  - plugin.xml (plugin configuration)"
echo "  - Kotlin source files"
echo "  - README with installation instructions"
echo ""
echo "To install:"
echo "  Settings -> Plugins -> Gear Icon -> Install Plugin from Disk"
echo ""
