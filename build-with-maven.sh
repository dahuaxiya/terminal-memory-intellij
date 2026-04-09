#!/bin/bash
# 使用 Maven 构建（备用方案）

set -e

echo "========================================"
echo "  Terminal Memory - Maven Build"
echo "========================================"
echo ""

# 检查 Maven
if ! command -v mvn &> /dev/null; then
    echo "Maven not found. Installing..."
    if command -v brew &> /dev/null; then
        brew install maven
    else
        echo "Please install Maven manually:"
        echo "  macOS: brew install maven"
        echo "  Linux: sudo apt-get install maven"
        exit 1
    fi
fi

echo "✓ Maven found: $(mvn -version | head -1)"

# 创建 pom.xml（如果不存在）
if [ ! -f "pom.xml" ]; then
    echo "Creating pom.xml..."
    cat > pom.xml << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <groupId>com.terminalmemory</groupId>
    <artifactId>terminal-memory</artifactId>
    <version>0.1.0</version>
    <packaging>jar</packaging>

    <name>Terminal Memory</name>
    <description>Save and restore IDE integrated terminals and AI coding agent sessions</description>

    <properties>
        <maven.compiler.source>17</maven.compiler.source>
        <maven.compiler.target>17</maven.compiler.target>
        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
        <kotlin.version>1.9.22</kotlin.version>
        <intellij.version>232.8660.185</intellij.version>
    </properties>

    <repositories>
        <repository>
            <id>aliyunmaven</id>
            <name>Aliyun Maven</name>
            <url>https://maven.aliyun.com/repository/public</url>
        </repository>
        <repository>
            <id>jetbrains</id>
            <name>JetBrains</name>
            <url>https://www.jetbrains.com/intellij-repository/releases</url>
        </repository>
    </repositories>

    <dependencies>
        <dependency>
            <groupId>org.jetbrains.kotlin</groupId>
            <artifactId>kotlin-stdlib</artifactId>
            <version>${kotlin.version}</version>
        </dependency>
        <dependency>
            <groupId>com.google.code.gson</groupId>
            <artifactId>gson</artifactId>
            <version>2.10.1</version>
        </dependency>
        <dependency>
            <groupId>com.jetbrains.intellij.idea</groupId>
            <artifactId>ideaIC</artifactId>
            <version>${intellij.version}</version>
            <scope>provided</scope>
        </dependency>
    </dependencies>

    <build>
        <sourceDirectory>src/main/kotlin</sourceDirectory>
        <plugins>
            <plugin>
                <groupId>org.jetbrains.kotlin</groupId>
                <artifactId>kotlin-maven-plugin</artifactId>
                <version>${kotlin.version}</version>
                <executions>
                    <execution>
                        <id>compile</id>
                        <phase>compile</phase>
                        <goals>
                            <goal>compile</goal>
                        </goals>
                    </execution>
                </executions>
            </plugin>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-jar-plugin</artifactId>
                <version>3.3.0</version>
                <configuration>
                    <archive>
                        <manifestEntries>
                            <Implementation-Title>Terminal Memory</Implementation-Title>
                            <Implementation-Version>${project.version}</Implementation-Version>
                        </manifestEntries>
                    </archive>
                </configuration>
            </plugin>
        </plugins>
    </build>
</project>
EOF
fi

# 构建
echo ""
echo "Building with Maven..."
mvn clean compile package -DskipTests

echo ""
echo "========================================"
echo "  Build Complete!"
echo "========================================"
echo ""
echo "Output: target/terminal-memory-0.1.0.jar"
