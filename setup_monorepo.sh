#!/bin/bash

# Setup script for iMessageUSDC monorepo with EthereumKit
# Run this from your project root directory

set -e  # Exit on error

echo "🚀 Setting up iMessageUSDC Monorepo Structure..."
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to check if file exists
check_file() {
    if [ -f "$1" ]; then
        echo -e "${GREEN}✓${NC} Found: $1"
        return 0
    else
        echo -e "${RED}✗${NC} Missing: $1"
        return 1
    fi
}

echo "📋 Checking Project Structure..."
echo ""

# Check main project files
check_file "iMessageUSDC.xcodeproj/project.pbxproj" || echo "  → Run this script from your project root"

# Check EthereumKit
if [ -d "EthereumKit" ]; then
    echo -e "${GREEN}✓${NC} Found: EthereumKit/"
    check_file "EthereumKit/Package.swift"
    check_file "EthereumKit/Sources/EthereumKit/JSONRPCClient.swift"
    check_file "EthereumKit/Sources/EthereumKit/EthereumService.swift"
    check_file "EthereumKit/Sources/EthereumKit/HexUtils.swift"
else
    echo -e "${RED}✗${NC} Missing: EthereumKit/"
    echo "  → Make sure EthereumKit package is in your project root"
fi

echo ""
echo "📝 Setting up .gitignore files..."
echo ""

# Setup main project .gitignore
if [ ! -f ".gitignore" ]; then
    echo "Creating root .gitignore..."
    cp MainProject-gitignore.txt .gitignore
    echo -e "${GREEN}✓${NC} Created .gitignore"
else
    echo -e "${YELLOW}⚠${NC}  .gitignore already exists"
    echo "  → Review MainProject-gitignore.txt and merge if needed"
fi

# Setup EthereumKit .gitignore
if [ -d "EthereumKit" ]; then
    if [ ! -f "EthereumKit/.gitignore" ]; then
        echo "Creating EthereumKit/.gitignore..."
        cp EthereumKit-gitignore.txt EthereumKit/.gitignore
        echo -e "${GREEN}✓${NC} Created EthereumKit/.gitignore"
    else
        echo -e "${YELLOW}⚠${NC}  EthereumKit/.gitignore already exists"
        echo "  → Review EthereumKit-gitignore.txt and merge if needed"
    fi
fi

echo ""
echo "🗂️  Checking for files that should be ignored..."
echo ""

# Check for files that should be in .gitignore
if [ -d ".build" ]; then
    echo -e "${YELLOW}⚠${NC}  Found .build/ directory (should be ignored)"
fi

if [ -d "DerivedData" ]; then
    echo -e "${YELLOW}⚠${NC}  Found DerivedData/ directory (should be ignored)"
fi

if [ -d "xcuserdata" ]; then
    echo -e "${YELLOW}⚠${NC}  Found xcuserdata/ directory (should be ignored)"
fi

if [ -f ".DS_Store" ]; then
    echo -e "${YELLOW}⚠${NC}  Found .DS_Store files (should be ignored)"
fi

echo ""
echo "🧹 Cleaning up unnecessary files..."
echo ""

# Remove common files that shouldn't be committed
find . -name ".DS_Store" -delete 2>/dev/null && echo "Removed .DS_Store files" || true
find . -name "*.swp" -delete 2>/dev/null && echo "Removed swap files" || true

echo ""
echo "📦 Recommended Git Workflow:"
echo ""
echo "1. Initialize git (if not already done):"
echo -e "   ${BLUE}git init${NC}"
echo ""
echo "2. Add EthereumKit as part of your repo:"
echo -e "   ${BLUE}git add EthereumKit/${NC}"
echo ""
echo "3. Check what will be committed:"
echo -e "   ${BLUE}git status${NC}"
echo ""
echo "4. Make your first commit:"
echo -e "   ${BLUE}git add .${NC}"
echo -e "   ${BLUE}git commit -m \"Initial commit with EthereumKit package\"${NC}"
echo ""
echo "5. Create a repo on GitHub and push:"
echo -e "   ${BLUE}git remote add origin https://github.com/yourusername/iMessageUSDC.git${NC}"
echo -e "   ${BLUE}git branch -M main${NC}"
echo -e "   ${BLUE}git push -u origin main${NC}"
echo ""

echo "✅ Setup complete!"
echo ""
echo "📖 What's in your monorepo:"
echo "   • Main iMessage app code"
echo "   • EthereumKit Swift Package (local)"
echo "   • Shared resources and documentation"
echo ""
echo "🔐 Security Reminder:"
echo "   • Never commit API keys or secrets"
echo "   • Use .env files or Config.xcconfig for sensitive data"
echo "   • Review files before committing: git status"
echo ""

# Check if git is initialized
if [ -d ".git" ]; then
    echo "📊 Current git status:"
    echo ""
    git status --short
else
    echo -e "${YELLOW}⚠${NC}  Git not initialized. Run 'git init' to start version control."
fi

echo ""
echo "🎉 All done! Your project is ready for version control."
