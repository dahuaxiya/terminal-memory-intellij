#!/bin/bash
# 使用 Maven 构建 IntelliJ 插件

set -e

echo "========================================"
echo "  Terminal Memory - Maven Build"
echo "========================================"
echo ""

# 检查 Maven
if ! command -v mvn &> /dev/null; then
    echo "Maven not found. Please install Maven:"
    echo "  macOS: brew install maven"
    echo "  Linux: sudo apt-get install maven"
    exit 1
fi

echo "✓ Maven found: $(mvn -version | head -1)"

# 检查 Java
if ! command -v java &> /dev/null; then
    echo "Java not found. Please install JDK 17+"
    exit 1
fi

echo "✓ Java found: $(java -version 2>&1 | head -1)"
echo ""

# 清理之前的构建
echo "Cleaning previous builds..."
rm -rf target/
rm -f terminal-memory-0.1.0.zip

# 编译 Kotlin 代码
echo ""
echo "========================================"
echo "  Step 1: Compile Kotlin Sources"
echo "========================================"
echo ""

# 创建输出目录
mkdir -p target/classes
mkdir -p target/plugin/terminal-memory/lib
mkdir -p target/plugin/terminal-memory/META-INF

# 下载依赖
echo "Downloading dependencies..."
mkdir -p target/dependency

# 下载 Kotlin stdlib
if [ ! -f "target/dependency/kotlin-stdlib-1.9.22.jar" ]; then
    echo "Downloading Kotlin stdlib..."
    curl -L --progress-bar "https://repo1.maven.org/maven2/org/jetbrains/kotlin/kotlin-stdlib/1.9.22/kotlin-stdlib-1.9.22.jar" \
        -o "target/dependency/kotlin-stdlib-1.9.22.jar" || {
        echo "Failed to download Kotlin stdlib"
        exit 1
    }
fi

# 下载 Gson
if [ ! -f "target/dependency/gson-2.10.1.jar" ]; then
    echo "Downloading Gson..."
    curl -L --progress-bar "https://repo1.maven.org/maven2/com/google/code/gson/gson/2.10.1/gson-2.10.1.jar" \
        -o "target/dependency/gson-2.10.1.jar" || {
        echo "Failed to download Gson"
        exit 1
    }
fi

echo "✓ Dependencies downloaded"

# 检查 Kotlin 编译器
if command -v kotlinc &> /dev/null; then
    echo "✓ Kotlin compiler found"
    
    # 编译 Kotlin 文件
    echo ""
    echo "Compiling Kotlin files..."
    kotlinc -d target/classes \
        -cp "target/dependency/*" \
        src/main/kotlin/com/terminalmemory/actions/*.kt \
        src/main/kotlin/com/terminalmemory/service/*.kt \
        src/main/kotlin/com/terminalmemory/ui/*.kt \
        2>&1 | head -20
    
    COMPILE_SUCCESS=$?
else
    echo "⚠️  Kotlin compiler not found. Including source files only."
    echo "   User will need to compile in IDEA."
    COMPILE_SUCCESS=1
fi

# 复制资源文件
echo ""
echo "========================================"
echo "  Step 2: Package Plugin"
echo "========================================"
echo ""

# 复制 plugin.xml
cp src/main/resources/META-INF/plugin.xml target/plugin/terminal-memory/META-INF/

# 如果有编译好的类，复制它们
if [ $COMPILE_SUCCESS -eq 0 ] && [ -d "target/classes/com" ]; then
    echo "✓ Compiled classes found"
    mkdir -p target/plugin/terminal-memory/classes
    cp -r target/classes/com target/plugin/terminal-memory/classes/
    
    # 创建 JAR
    cd target/plugin/terminal-memory
    jar cf ../lib/terminal-memory-0.1.0.jar -C classes .
    cd ../../..
    
    # 复制依赖
    cp target/dependency/*.jar target/plugin/terminal-memory/lib/
    
    echo "✓ JAR created: target/lib/terminal-memory-0.1.0.jar"
else
    echo "⚠️  No compiled classes. Creating source-only package."
    
    # 复制源代码
    mkdir -p target/plugin/terminal-memory/src/com/terminalmemory
    cp -r src/main/kotlin/com/terminalmemory/* target/plugin/terminal-memory/src/com/terminalmemory/
    
    # 复制依赖（用户可以在 IDEA 中引用）
    cp target/dependency/*.jar target/plugin/terminal-memory/lib/
fi

# 创建 README
cat > target/plugin/terminal-memory/README.txt << 'EOF'
Terminal Memory Plugin
======================

Installation:
1. If compiled JAR exists in lib/: Install directly
2. If only src/ exists: Open in IDEA as project and build

Configuration:
1. Settings → Terminal Memory
2. Set Python Path (e.g., /usr/bin/python3)
3. Set Core Module Path (path to terminal-memory/core)
4. Enable Auto Save and Auto Restore

Usage:
1. Tools → Terminal Memory → Save Terminal Sessions
2. Tools → Terminal Memory → Restore Terminal Sessions
EOF

# 打包成 ZIP
echo ""
echo "Creating ZIP archive..."
cd target/plugin
zip -r ../../terminal-memory-0.1.0.zip terminal-memory/ -x "*.DS_Store"
cd ../..

# 验证
echo ""
echo "========================================"
echo "  Build Complete!"
echo "========================================"
echo ""

if [ -f "terminal-memory-0.1.0.zip" ]; then
    echo "✅ Plugin package created successfully!"
    echo ""
    echo "File: $(pwd)/terminal-memory-0.1.0.zip"
    echo "Size: $(ls -lh terminal-memory-0.1.0.zip | awk '{print $5}')"
    echo ""
    echo "Contents:"
    unzip -l terminal-memory-0.1.0.zip | tail -10
    echo ""
    echo "Installation:"
    echo "  Settings → Plugins → Install Plugin from Disk"
    echo "  Select: $(pwd)/terminal-memory-0.1.0.zip"
    exit 0
else
    echo "❌ Build failed!"
    exit 1
fi
