#!/bin/bash
# 使用 Kotlin 编译器构建插件

set -e

echo "========================================"
echo "  Terminal Memory - Build with Kotlin"
echo "========================================"
echo ""

# 设置代理
export HTTP_PROXY="http://127.0.0.1:7890"
export HTTPS_PROXY="http://127.0.0.1:7890"
export ALL_PROXY="socks5://127.0.0.1:7890"

# 设置 Kotlin 编译器路径
export PATH="/tmp/kotlinc/bin:$PATH"

echo "✓ Kotlin compiler: $(kotlinc -version 2>&1)"

# 工作目录
cd ~/github/terminal-memory-intellij

# 清理
rm -rf target/
rm -f terminal-memory-0.1.0.zip
mkdir -p target/classes
mkdir -p target/plugin/terminal-memory/lib
mkdir -p target/plugin/terminal-memory/META-INF
mkdir -p target/dependency

echo ""
echo "=== Step 1: Downloading dependencies ==="

# 下载依赖
download_dep() {
    local url=$1
    local output=$2
    if [ ! -f "$output" ]; then
        echo "Downloading $(basename $output)..."
        curl -L --progress-bar "$url" -o "$output" || {
            echo "Failed to download $url"
            return 1
        }
    else
        echo "✓ $(basename $output) already exists"
    fi
}

# Kotlin stdlib
download_dep \
    "https://repo1.maven.org/maven2/org/jetbrains/kotlin/kotlin-stdlib/1.9.22/kotlin-stdlib-1.9.22.jar" \
    "target/dependency/kotlin-stdlib-1.9.22.jar"

# Gson
download_dep \
    "https://repo1.maven.org/maven2/com/google/code/gson/gson/2.10.1/gson-2.10.1.jar" \
    "target/dependency/gson-2.10.1.jar"

# IntelliJ annotations (optional but good to have)
download_dep \
    "https://repo1.maven.org/maven2/org/jetbrains/annotations/24.0.1/annotations-24.0.1.jar" \
    "target/dependency/annotations-24.0.1.jar" || true

echo ""
echo "=== Step 2: Compiling Kotlin sources ==="

# 编译 Kotlin 文件
KOTLIN_FILES=$(find src/main/kotlin -name "*.kt")

echo "Found $(echo "$KOTLIN_FILES" | wc -l) Kotlin files"
echo ""

kotlinc -d target/classes \
    -cp "target/dependency/*" \
    -jvm-target 17 \
    $KOTLIN_FILES 2>&1

if [ $? -eq 0 ]; then
    echo "✓ Compilation successful"
    
    # 显示编译的类
    echo ""
    echo "Generated classes:"
    find target/classes -name "*.class" | head -10
    echo "... ($(find target/classes -name "*.class" | wc -l) classes total)"
else
    echo "✗ Compilation failed"
    exit 1
fi

echo ""
echo "=== Step 3: Packaging plugin ==="

# 创建 JAR
cd target/classes
jar cf ../plugin/terminal-memory/lib/terminal-memory-0.1.0.jar \
    com/terminalmemory/*/*/*.class \
    com/terminalmemory/*/*.class \
    2>/dev/null || \
jar cf ../plugin/terminal-memory/lib/terminal-memory-0.1.0.jar \
    $(find . -name "*.class") 2>/dev/null

cd ../..

# 复制依赖
cp target/dependency/*.jar target/plugin/terminal-memory/lib/

# 复制 plugin.xml
cp src/main/resources/META-INF/plugin.xml target/plugin/terminal-memory/META-INF/

# 创建 README
cat > target/plugin/terminal-memory/README.txt << 'EOF'
Terminal Memory Plugin v0.1.0
==============================

This is a COMPILED plugin package.

Installation:
1. Settings → Plugins → Gear Icon → Install Plugin from Disk
2. Select terminal-memory-0.1.0.zip
3. Restart IDEA
4. Configure: Settings → Terminal Memory

Files:
- lib/terminal-memory-0.1.0.jar - Compiled plugin classes
- lib/kotlin-stdlib-1.9.22.jar - Kotlin runtime
- lib/gson-2.10.1.jar - JSON library
- META-INF/plugin.xml - Plugin configuration
EOF

echo ""
echo "=== Step 4: Creating ZIP archive ==="

cd target/plugin
zip -r ../../terminal-memory-0.1.0.zip terminal-memory/ -x "*.DS_Store" -q
cd ../..

echo ""
echo "========================================"
echo "  Build Complete!"
echo "========================================"
echo ""

if [ -f "terminal-memory-0.1.0.zip" ]; then
    ls -lh terminal-memory-0.1.0.zip
    echo ""
    echo "✅ Plugin is ready for installation!"
    echo ""
    echo "To install:"
    echo "  Settings → Plugins → Install Plugin from Disk"
    echo "  Select: $(pwd)/terminal-memory-0.1.0.zip"
    echo ""
    
    # 显示 ZIP 内容
    echo "Package contents:"
    unzip -l terminal-memory-0.1.0.zip | grep -E "(lib/|META-INF/)" | tail -10
    
    exit 0
else
    echo "✗ Build failed - ZIP not created"
    exit 1
fi
