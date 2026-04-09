# Terminal Memory - 构建指南

## 快速安装（无需构建）

如果你不想构建，可以直接在 IntelliJ IDEA 中加载源码：

1. 打开 IntelliJ IDEA
2. **File** → **New** → **Project from Existing Sources**
3. 选择 `~/github/terminal-memory-intellij` 目录
4. 选择 **Create project from existing sources**
5. 等待 IDEA 加载项目
6. 配置 Python 路径：
   - **Settings** → **Terminal Memory**
   - Python Path: `/usr/bin/python3`
   - Core Module Path: `/path/to/terminal-memory/core`
7. 点击右上角的 **Run Plugin** 运行

## 方法 1: 使用 IntelliJ IDEA 构建（推荐）

### 步骤

1. 用 IntelliJ IDEA 打开项目
2. 确保已安装 **Kotlin** 插件
3. 配置项目 SDK：
   - **File** → **Project Structure** → **Project**
   - SDK: 选择 JDK 17
4. 添加 IntelliJ Platform SDK：
   - **File** → **Project Structure** → **Platform Settings** → **SDKs**
   - 点击 **+** → **Add IntelliJ Platform Plugin SDK**
   - 选择你的 IntelliJ IDEA 安装目录
5. 构建：
   - **Build** → **Build Project**
6. 打包：
   - **Build** → **Prepare Plugin Module 'terminal-memory' for Deployment**
   - 生成的 ZIP 文件在 `~/github/terminal-memory-intellij/terminal-memory-0.1.0.zip`

## 方法 2: 使用 Gradle（需要代理）

### 配置代理

编辑 `gradle.properties`：

```properties
# HTTP 代理
systemProp.http.proxyHost=127.0.0.1
systemProp.http.proxyPort=7890
systemProp.https.proxyHost=127.0.0.1
systemProp.https.proxyPort=7890

# SOCKS 代理（推荐）
systemProp.socksProxyHost=127.0.0.1
systemProp.socksProxyPort=7890
```

### 构建

```bash
./setup-and-build.sh
```

或者手动：

```bash
# 安装 Gradle
brew install gradle

# 构建
gradle clean buildPlugin

# 输出在 build/distributions/terminal-memory-0.1.0.zip
```

## 方法 3: 使用 Maven

```bash
# 安装 Maven
brew install maven

# 构建
./build-with-maven.sh
```

## 方法 4: 手动打包（已生成）

已经生成了 `terminal-memory-0.1.0.zip`，这是一个源码包，包含：

- `META-INF/plugin.xml` - 插件配置
- `src/` - Kotlin 源代码
- `lib/` - 依赖库（可选）

你可以：
1. 直接在 IDEA 中作为项目打开
2. 或者在 IDEA 的 Plugin DevKit 中加载

## 安装插件

无论用哪种方法构建，安装方式相同：

1. 打开 IntelliJ IDEA
2. **Settings** → **Plugins** → 齿轮图标 → **Install Plugin from Disk**
3. 选择生成的 `.zip` 文件
4. 重启 IDEA
5. 配置插件：
   - **Settings** → **Terminal Memory**
   - Python Path: `/usr/bin/python3`
   - Core Module Path: `/path/to/terminal-memory/core`

## 验证安装

安装成功后：

1. 右侧应该出现 **Terminal Memory** 工具窗口
2. **Tools** 菜单应该有 **Terminal Memory** 子菜单
3. 打开一个终端，运行 `kimi`，然后点击 **Save**
4. 关闭项目，重新打开
5. 应该提示是否恢复终端

## 常见问题

### Q: 构建时报 "Cannot find IntelliJ Platform SDK"

**A**: 需要配置 IntelliJ Platform SDK：
1. File → Project Structure → Platform Settings → SDKs
2. 点击 + → Add IntelliJ Platform Plugin SDK
3. 选择你的 IDEA 安装目录（如 `/Applications/IntelliJ IDEA.app/Contents`）

### Q: Kotlin 代码报红

**A**: 确保已安装 Kotlin 插件，并且项目 SDK 配置正确。

### Q: 运行时提示找不到 Python 模块

**A**: 在 Settings → Terminal Memory 中配置正确的：
- Python Path: 运行 `which python3` 获取
- Core Module Path: terminal-memory/core 目录的绝对路径

### Q: 依赖下载慢

**A**: 在 `build.gradle.kts` 或 `pom.xml` 中已配置阿里云镜像。如果仍然慢：
1. 配置全局代理
2. 或者使用方法一（直接用 IDEA 打开源码运行）

## 联系

如有问题，请提交 Issue 到 GitHub 仓库。
