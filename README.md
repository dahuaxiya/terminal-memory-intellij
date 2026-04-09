# Terminal Memory - IntelliJ IDEA Plugin

保存和恢复 IDE 内置终端及 AI coding agent（Kimi、Claude、Codex）会话状态的 IntelliJ IDEA 插件。

## 功能特性

- 💾 **自动保存**：关闭项目时自动捕获终端状态
- 🔄 **一键恢复**：打开项目后恢复所有终端和 AI 会话
- 🤖 **AI Agent 支持**：Kimi、Claude、Codex
- 📊 **状态面板**：侧边栏显示保存的终端信息
- ⚙️ **可配置**：自定义 Python 路径和核心模块路径

## 前置要求

1. **IntelliJ IDEA** 2023.2 或更高版本
2. **Python 3.8+**
3. **Terminal Memory Core** Python 模块

## 安装

### 1. 安装 Python 核心模块

```bash
# 克隆核心模块（如果还没有）
git clone https://github.com/yourusername/terminal-memory-core.git ~/terminal-memory-core
cd ~/terminal-memory-core

# 创建虚拟环境
python3 -m venv venv
source venv/bin/activate

# 安装依赖
pip install -r requirements.txt
```

### 2. 构建插件

```bash
# 克隆本仓库
git clone https://github.com/yourusername/terminal-memory-intellij.git
cd terminal-memory-intellij

# 构建
./build.sh
# 或: gradle buildPlugin
```

### 3. 安装到 IntelliJ IDEA

1. 打开 IntelliJ IDEA
2. **Settings** → **Plugins** → 齿轮图标 → **Install Plugin from Disk**
3. 选择 `build/distributions/terminal-memory-0.1.0.zip`
4. 重启 IDE

### 4. 配置插件

1. 打开 **Settings** → **Terminal Memory**
2. 设置以下路径：
   - **Python Path**: `/usr/bin/python3`（或 `which python3` 的结果）
   - **Core Module Path**: `~/terminal-memory-core`（核心模块的绝对路径）
3. 可选：启用 **Auto Save** 和 **Auto Restore**

## 使用方法

### 保存终端会话

**手动保存：**
- **Tools** → **Terminal Memory** → **Save Terminal Sessions**
- 或点击右侧工具窗口的 **Save** 按钮

**自动保存：**
- 在设置中开启 **Auto Save**
- 关闭项目时会自动保存

### 恢复终端会话

**手动恢复：**
- **Tools** → **Terminal Memory** → **Restore Terminal Sessions**
- 或点击右侧工具窗口的 **Restore** 按钮

**自动恢复：**
- 在设置中开启 **Auto Restore**
- 打开项目时会提示是否恢复

### 查看状态

- 打开右侧的 **Terminal Memory** 工具窗口
- 或执行 **Tools** → **Terminal Memory** → **Show Status**

## 项目结构

```
terminal-memory-intellij/
├── build.gradle.kts              # Gradle 构建配置
├── settings.gradle.kts           # Gradle 设置
├── gradle.properties             # Gradle 属性
├── gradlew                       # Gradle wrapper
├── build.sh                      # 构建脚本
├── README.md                     # 本文件
├── .gitignore                    # Git 忽略配置
└── src/main/
    ├── kotlin/com/terminalmemory/
    │   ├── actions/              # 菜单动作
    │   │   ├── SaveSessionsAction.kt
    │   │   ├── RestoreSessionsAction.kt
    │   │   ├── ShowStatusAction.kt
    │   │   └── ClearSavedStateAction.kt
    │   ├── service/              # 核心服务
    │   │   ├── TerminalMemoryProjectService.kt
    │   │   └── TerminalMemoryProjectListener.kt
    │   └── ui/                   # UI 组件
    │       ├── TerminalMemoryToolWindowFactory.kt
    │       ├── TerminalMemoryToolWindowPanel.kt
    │       └── TerminalMemorySettingsConfigurable.kt
    └── resources/
        ├── META-INF/
        │   └── plugin.xml        # 插件配置
        └── icons/                # 图标资源
```

## 开发

### 环境要求

- **JDK 17** 或更高版本
- **Kotlin 1.9**
- **Gradle 8.0+**
- **IntelliJ IDEA 2023.2+**

### 运行调试

```bash
# 启动测试 IDE
gradle runIde
```

### 构建发布

```bash
# 构建插件
gradle buildPlugin

# 输出: build/distributions/terminal-memory-0.1.0.zip
```

### 发布到 JetBrains Marketplace

```bash
# 需要设置 PUBLISH_TOKEN 环境变量
gradle publishPlugin
```

## 技术栈

- **语言**: Kotlin 1.9
- **构建工具**: Gradle + IntelliJ Platform Gradle Plugin
- **SDK**: IntelliJ Platform SDK 2023.2
- **依赖插件**: Terminal Plugin

## 相关项目

- [Terminal Memory Core](https://github.com/yourusername/terminal-memory-core) - Python 核心模块
- [Terminal Memory VS Code](https://github.com/yourusername/terminal-memory-vscode) - VS Code/Cursor 扩展

## 许可证

MIT License
