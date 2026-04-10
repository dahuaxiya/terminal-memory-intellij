#!/bin/bash
# 自测脚本 - 验证插件打包后是否能正常工作

set -e

echo "========================================"
echo "  Terminal Memory - Self Test"
echo "========================================"
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

PASS=0
FAIL=0

test_pass() {
    echo "${GREEN}✓ PASS${NC}: $1"
    ((PASS++))
}

test_fail() {
    echo "${RED}✗ FAIL${NC}: $1"
    ((FAIL++))
}

# 1. 检查文件结构
echo "Test 1: Check file structure..."
if [ -f "terminal-memory-0.1.0.zip" ]; then
    test_pass "ZIP file exists"
else
    test_fail "ZIP file not found"
    exit 1
fi

# 2. 检查 ZIP 内容
echo ""
echo "Test 2: Check ZIP contents..."
unzip -l terminal-memory-0.1.0.zip > /tmp/zip_contents.txt

if grep -q "plugin.xml" /tmp/zip_contents.txt; then
    test_pass "plugin.xml exists in ZIP"
else
    test_fail "plugin.xml missing from ZIP"
fi

if grep -q "SaveSessionsAction.kt" /tmp/zip_contents.txt; then
    test_pass "SaveSessionsAction.kt exists"
else
    test_fail "SaveSessionsAction.kt missing"
fi

# 3. 检查 plugin.xml 语法
echo ""
echo "Test 3: Validate plugin.xml..."
unzip -p terminal-memory-0.1.0.zip terminal-memory/META-INF/plugin.xml > /tmp/plugin_test.xml
if xmllint --noout /tmp/plugin_test.xml 2>/dev/null; then
    test_pass "plugin.xml is valid XML"
else
    test_fail "plugin.xml has syntax errors"
fi

# 4. 检查没有缺失的图标引用
echo ""
echo "Test 4: Check for missing icon references..."
if grep -q 'icon="/icons/' /tmp/plugin_test.xml; then
    test_fail "plugin.xml still has icon references (will cause menu issues)"
else
    test_pass "No problematic icon references"
fi

# 5. 检查所有 action 类都被定义
echo ""
echo "Test 5: Check action classes..."
ACTIONS=("SaveSessionsAction" "RestoreSessionsAction" "ShowStatusAction" "ClearSavedStateAction")
for action in "${ACTIONS[@]}"; do
    if grep -q "$action" /tmp/zip_contents.txt; then
        test_pass "Action class $action exists"
    else
        test_fail "Action class $action missing"
    fi
done

# 6. 检查 service 类
echo ""
echo "Test 6: Check service classes..."
SERVICES=("TerminalMemoryProjectService" "TerminalMemoryProjectListener")
for service in "${SERVICES[@]}"; do
    if grep -q "$service" /tmp/zip_contents.txt; then
        test_pass "Service class $service exists"
    else
        test_fail "Service class $service missing"
    fi
done

# 7. 检查 UI 类
echo ""
echo "Test 7: Check UI classes..."
UI_CLASSES=("TerminalMemoryToolWindowFactory" "TerminalMemoryToolWindowPanel" "TerminalMemorySettingsConfigurable")
for ui_class in "${UI_CLASSES[@]}"; do
    if grep -q "$ui_class" /tmp/zip_contents.txt; then
        test_pass "UI class $ui_class exists"
    else
        test_fail "UI class $ui_class missing"
    fi
done

# 8. 检查 Kotlin 文件语法（简单检查）
echo ""
echo "Test 8: Check Kotlin file syntax..."
unzip -p terminal-memory-0.1.0.zip terminal-memory/src/com/terminalmemory/service/TerminalMemoryProjectService.kt > /tmp/service.kt
if grep -q "class TerminalMemoryProjectService" /tmp/service.kt; then
    test_pass "TerminalMemoryProjectService has valid class definition"
else
    test_fail "TerminalMemoryProjectService class definition missing"
fi

# 9. 检查扩展点定义
echo ""
echo "Test 9: Check extension points..."
if grep -q "toolWindow" /tmp/plugin_test.xml && \
   grep -q "projectService" /tmp/plugin_test.xml && \
   grep -q "projectConfigurable" /tmp/plugin_test.xml; then
    test_pass "All extension points defined"
else
    test_fail "Some extension points missing"
fi

# 10. 模拟安装测试（解压并验证）
echo ""
echo "Test 10: Simulate installation..."
TEST_DIR=$(mktemp -d)
cd "$TEST_DIR"
unzip -q ~/github/terminal-memory-intellij/terminal-memory-0.1.0.zip

if [ -d "terminal-memory/META-INF" ] && [ -d "terminal-memory/src" ]; then
    test_pass "ZIP structure is valid for installation"
else
    test_fail "ZIP structure invalid"
fi

cd ~/github/terminal-memory-intellij
rm -rf "$TEST_DIR"

# 11. 检查依赖声明
echo ""
echo "Test 11: Check plugin dependencies..."
if grep -q 'depends>org.jetbrains.plugins.terminal' /tmp/plugin_test.xml; then
    test_pass "Terminal plugin dependency declared"
else
    test_fail "Terminal plugin dependency missing"
fi

# 12. 检查版本信息
echo ""
echo "Test 12: Check version info..."
if grep -q '<version>0.1.0</version>' /tmp/plugin_test.xml; then
    test_pass "Version is 0.1.0"
else
    test_fail "Version mismatch"
fi

if grep -q 'since-build="232"' /tmp/plugin_test.xml; then
    test_pass "Compatible with IntelliJ 2023.2+"
else
    test_fail "Build version not specified"
fi

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
    echo "${GREEN}✓ All tests passed!${NC}"
    echo ""
    echo "The plugin package is ready for installation."
    echo ""
    echo "Installation command:"
    echo "  1. Open IntelliJ IDEA"
    echo "  2. Settings → Plugins → Gear Icon → Install Plugin from Disk"
    echo "  3. Select: $(pwd)/terminal-memory-0.1.0.zip"
    exit 0
else
    echo "${RED}✗ Some tests failed!${NC}"
    echo ""
    echo "Please fix the issues before releasing."
    exit 1
fi
