# Terminal Memory - IntelliJ IDEA 快速使用指南

## 第一步：配置（必须）

1. 打开 **IntelliJ IDEA**
2. 点击菜单：**File** → **Settings**（或 **IntelliJ IDEA** → **Preferences** 在 macOS）
3. 在左侧搜索框输入 **Terminal Memory**，或找到 **Tools** → **Terminal Memory**

### 配置项：

| 配置项 | 填写内容 | 示例 |
|--------|----------|------|
| **Python Path** | Python 3 的路径 | `/opt/homebrew/bin/python3` |
| **Core Module Path** | 核心模块的绝对路径 | `/Users/dxm/github/memory-control-room/terminal-memory/core` |
| **Auto Save** | 关闭项目时自动保存 | ✅ 推荐开启 |
| **Auto Restore** | 打开项目时提示恢复 | ✅ 推荐开启 |
| **Confirm on Restore** | 恢复前确认 | ✅ 推荐开启 |

### 如何获取路径：

```bash
# 获取 Python 路径
which python3
# 输出: /opt/homebrew/bin/python3

# 获取核心模块路径（你的实际路径）
cd ~/github/memory-control-room/terminal-memory/core
pwd
# 输出: /Users/dxm/github/memory-control-room/terminal-memory/core
```

填好后点击 **Apply** → **OK**

---

## 第二步：打开终端并启动 AI

1. 打开内置终端：**View** → **Tool Windows** → **Terminal**（或按 `Alt+F12`）
2. 启动 Kimi：
   ```bash
   kimi
   ```
   或者启动 Claude：
   ```bash
   claude
   ```

---

## 第三步：保存终端状态

### 方法 1：使用菜单
1. 点击菜单：**Tools** → **Terminal Memory** → **Save Terminal Sessions**

### 方法 2：使用工具窗口
1. 看右侧边栏，找到 **Terminal Memory** 工具窗口
2. 点击 **Save** 按钮

### 方法 3：自动保存（推荐）
- 如果开启了 **Auto Save**，直接关闭项目即可自动保存

---

## 第四步：恢复终端状态

### 场景 1：重新打开项目时
如果开启了 **Auto Restore**，会弹出提示：
```
Found saved terminal sessions:
2 terminal(s) with AI agents: kimi: 1, claude: 1

[Restore] [Ignore]
```
点击 **Restore** 即可恢复

### 场景 2：手动恢复
1. 点击菜单：**Tools** → **Terminal Memory** → **Restore Terminal Sessions**
2. 或点击右侧工具窗口的 **Restore** 按钮

### 恢复效果：
- 自动创建新的终端
- 自动切换到之前的工作目录
- 自动执行 `kimi resume <token>` 或 `claude resume <id>`

---

## 第五步：查看状态

### 方法 1：工具窗口
看右侧 **Terminal Memory** 工具窗口，显示：
- 保存了几个终端
- 每个终端里是什么 AI Agent
- 最后保存时间

### 方法 2：菜单
点击：**Tools** → **Terminal Memory** → **Show Status**

会弹出窗口显示：
```
Saved Terminal Sessions
Terminals: 2
AI Agents:
  • kimi: 1
  • claude: 1
Last saved: 2026-04-09 14:30
```

---

## 完整使用流程示例

### 示例 1：工作场景

**周五下班前：**
1. 你在处理项目 A，开了 2 个终端：
   - 终端 1：运行 Kimi，正在重构代码
   - 终端 2：运行普通的 shell，查看日志
2. 直接关闭 IDEA（因为开启了 Auto Save）

**周一上班：**
1. 打开 IDEA
2. 弹出提示："找到 2 个保存的终端，是否恢复？"
3. 点击 **Restore**
4. 自动创建 2 个终端：
   - 终端 1：自动执行 `cd /项目A目录 && kimi resume xxx`
   - 终端 2：自动执行 `cd /项目A目录`
5. 继续工作！

---

## 常见问题

### Q1: 保存时提示 "No active terminals to save"

**原因**：你没有打开任何内置终端

**解决**：
1. 按 `Alt+F12` 打开终端
2. 在里面运行一些命令
3. 再尝试保存

### Q2: 恢复后终端是空的，没有 Kimi

**原因**：
1. 保存时可能没有正确获取到 resume token
2. Kimi CLI 可能不支持 resume

**解决**：
1. 确保 Kimi CLI 版本支持 `kimi resume` 命令
2. 检查 `~/.kimi/sessions/` 目录是否存在

### Q3: 提示 "Failed to execute Python CLI"

**原因**：Python 路径或 Core Module Path 配置错误

**解决**：
1. 检查 Settings → Terminal Memory 中的路径
2. 测试 Python 模块是否正常：
   ```bash
   cd /你的/core模块路径
   python3 cli.py has_state test
   ```

### Q4: 右侧没有看到 Terminal Memory 工具窗口

**原因**：工具窗口可能被关闭或隐藏

**解决**：
1. **View** → **Tool Windows** → **Terminal Memory**
2. 或 **Window** → **Active Tool Window** → **Terminal Memory**

### Q5: 自动保存没有生效

**检查**：
1. Settings → Terminal Memory → **Auto Save** 是否开启
2. 关闭项目时是否有权限访问 `~/.terminal-memory/state.db`

---

## 快捷键设置

你可以给常用操作设置快捷键：

1. **Settings** → **Keymap**
2. 搜索 "Terminal Memory"
3. 右键点击操作 → **Add Keyboard Shortcut**

推荐设置：
| 操作 | 快捷键 |
|------|--------|
| Save Terminal Sessions | `Cmd+Shift+S` |
| Restore Terminal Sessions | `Cmd+Shift+R` |
| Show Status | `Cmd+Shift+T` |

---

## 验证安装

运行以下测试验证是否正常工作：

```bash
# 1. 测试 Python 模块
cd /你的/core模块路径
python3 tests/test_agent_detector.py
# 应该显示所有测试通过

# 2. 测试状态存储
python3 tests/test_integration.py
# 应该显示所有测试通过
```

如果测试都通过，说明核心模块正常，问题可能在插件配置上。

---

## 需要帮助？

查看详细文档：
- `BUILD_GUIDE.md` - 构建指南
- `README.md` - 项目说明
- GitHub Issues: https://github.com/dahuaxiya/terminal-memory-intellij/issues
