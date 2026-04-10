#!/bin/bash
# 简化的自测脚本

echo "========================================"
echo "  Terminal Memory - Self Test"
echo "========================================"
echo ""

PASS=0
FAIL=0

test_pass() {
    echo "[PASS] $1"
    PASS=$((PASS + 1))
}

test_fail() {
    echo "[FAIL] $1"
    FAIL=$((FAIL + 1))
}

# 1. 检查 ZIP 文件
echo "1. Checking ZIP file..."
if [ -f "terminal-memory-0.1.0.zip" ]; then
    test_pass "ZIP file exists"
    ls -lh terminal-memory-0.1.0.zip
else
    test_fail "ZIP file not found"
    exit 1
fi

# 2. 解压并检查内容
echo ""
echo "2. Checking ZIP contents..."
TEST_DIR=$(mktemp -d)
unzip -q terminal-memory-0.1.0.zip -d "$TEST_DIR"

# 检查关键文件
FILES=(
    "terminal-memory/META-INF/plugin.xml"
    "terminal-memory/src/com/terminalmemory/actions/SaveSessionsAction.kt"
    "terminal-memory/src/com/terminalmemory/actions/RestoreSessionsAction.kt"
    "terminal-memory/src/com/terminalmemory/service/TerminalMemoryProjectService.kt"
    "terminal-memory/src/com/terminalmemory/ui/TerminalMemoryToolWindowFactory.kt"
)

for file in "${FILES[@]}"; do
    if [ -f "$TEST_DIR/$file" ]; then
        test_pass "Found: $file"
    else
        test_fail "Missing: $file"
    fi
done

# 3. 检查 plugin.xml
echo ""
echo "3. Validating plugin.xml..."
PLUGIN_XML="$TEST_DIR/terminal-memory/META-INF/plugin.xml"

# 检查图标引用问题
if grep -q 'icon="/icons/' "$PLUGIN_XML"; then
    test_fail "plugin.xml has icon references (will cause menu issues)"
    echo "       Found:"
    grep 'icon="/icons/' "$PLUGIN_XML" | head -3
else
    test_pass "No problematic icon references"
fi

# 检查 action 定义
if grep -q 'TerminalMemory.SaveSessions' "$PLUGIN_XML"; then
    test_pass "SaveSessions action defined"
else
    test_fail "SaveSessions action missing"
fi

if grep -q 'TerminalMemory.RestoreSessions' "$PLUGIN_XML"; then
    test_pass "RestoreSessions action defined"
else
    test_fail "RestoreSessions action missing"
fi

# 检查扩展点
if grep -q 'toolWindow' "$PLUGIN_XML"; then
    test_pass "Tool window extension defined"
else
    test_fail "Tool window extension missing"
fi

if grep -q 'projectService' "$PLUGIN_XML"; then
    test_pass "Project service extension defined"
else
    test_fail "Project service extension missing"
fi

# 检查依赖
if grep -q 'org.jetbrains.plugins.terminal' "$PLUGIN_XML"; then
    test_pass "Terminal plugin dependency declared"
else
    test_fail "Terminal plugin dependency missing"
fi

# 4. 检查 Kotlin 文件语法
echo ""
echo "4. Checking Kotlin files..."
SERVICE_KT="$TEST_DIR/terminal-memory/src/com/terminalmemory/service/TerminalMemoryProjectService.kt"
if grep -q "class TerminalMemoryProjectService" "$SERVICE_KT"; then
    test_pass "ProjectService class definition OK"
else
    test_fail "ProjectService class definition missing"
fi

if grep -q "saveSessions()" "$SERVICE_KT"; then
    test_pass "saveSessions() method found"
else
    test_fail "saveSessions() method missing"
fi

if grep -q "restoreSessions()" "$SERVICE_KT"; then
    test_pass "restoreSessions() method found"
else
    test_fail "restoreSessions() method missing"
fi

# 5. 检查 action 类
echo ""
echo "5. Checking action classes..."
SAVE_ACTION="$TEST_DIR/terminal-memory/src/com/terminalmemory/actions/SaveSessionsAction.kt"
if grep -q "class SaveSessionsAction" "$SAVE_ACTION"; then
    test_pass "SaveSessionsAction class OK"
else
    test_fail "SaveSessionsAction class missing"
fi

RESTORE_ACTION="$TEST_DIR/terminal-memory/src/com/terminalmemory/actions/RestoreSessionsAction.kt"
if grep -q "class RestoreSessionsAction" "$RESTORE_ACTION"; then
    test_pass "RestoreSessionsAction class OK"
else
    test_fail "RestoreSessionsAction class missing"
fi

# 清理
rm -rf "$TEST_DIR"

# 总结
echo ""
echo "========================================"
echo "  Test Summary"
echo "========================================"
echo ""
echo "Passed: $PASS"
echo "Failed: $FAIL"
echo ""

if [ $FAIL -eq 0 ]; then
    echo "All tests passed!"
    echo ""
    echo "The plugin package is ready for installation:"
    echo "  $(pwd)/terminal-memory-0.1.0.zip"
    echo ""
    echo "Size: $(ls -lh terminal-memory-0.1.0.zip | awk '{print $5}')"
    exit 0
else
    echo "Some tests failed!"
    echo "Please fix the issues before releasing."
    exit 1
fi
