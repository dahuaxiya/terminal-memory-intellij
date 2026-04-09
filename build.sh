#!/bin/bash
# IntelliJ Plugin Build Script

set -e

echo "========================================"
echo "  Terminal Memory - IntelliJ Plugin"
echo "  Build Script"
echo "========================================"
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Check if gradle is installed
if ! command -v gradle &> /dev/null; then
    echo "${RED}Gradle not found. Please install Gradle.${NC}"
    echo "macOS: brew install gradle"
    exit 1
fi

echo "✓ Gradle found"

# Build
echo ""
echo "Building plugin..."
echo "----------------------------------------"

if gradle buildPlugin; then
    echo ""
    echo "${GREEN}✓ Build successful!${NC}"
    echo ""
    echo "Plugin location:"
    echo "  build/distributions/terminal-memory-0.1.0.zip"
    echo ""
    echo "To install:"
    echo "  1. Open IntelliJ IDEA"
    echo "  2. Settings → Plugins → Gear Icon"
    echo "  3. Install Plugin from Disk"
    echo "  4. Select the ZIP file above"
    echo ""
    echo "To run in development mode:"
    echo "  gradle runIde"
else
    echo ""
    echo "${RED}✗ Build failed${NC}"
    exit 1
fi
