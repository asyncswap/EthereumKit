# Git & Repository Setup Guide

## 🎯 Recommended: Monorepo Structure

For your iMessage wallet app with EthereumKit, I recommend a **monorepo** structure:

```
iMessageUSDC/                          # Your main repository
├── .git/                              # Git repository
├── .gitignore                         # Main gitignore
├── README.md                          # Project README
├── iMessageUSDC.xcodeproj            # Xcode project
├── iMessageUSDC/                      # Main app target
├── MessagesExtension/                 # iMessage extension
├── EthereumKit/                       # 📦 Swift Package (local)
│   ├── .gitignore                     # Package-specific gitignore
│   ├── Package.swift
│   ├── README.md
│   ├── Sources/
│   └── Tests/
├── Shared/                            # Shared code/resources
└── Documentation/                     # Guides and docs
```

## 📝 GitIgnore Files Created

I've created two `.gitignore` templates:

### 1. `MainProject-gitignore.txt`
Place this as `.gitignore` in your project root.

**Key items ignored:**
- ✅ Xcode user data (xcuserdata, DerivedData)
- ✅ Build products
- ✅ Swift Package Manager artifacts (.build, .swiftpm)
- ✅ **API Keys and Secrets** (CRITICAL!)
- ✅ macOS files (.DS_Store)
- ✅ IDE files
- ❌ **NOT ignored:** EthereumKit folder (it's part of your repo)

### 2. `EthereumKit-gitignore.txt`
Place this as `EthereumKit/.gitignore` in the package folder.

**Key items ignored:**
- ✅ Swift Package build artifacts
- ✅ Generated Xcode projects
- ✅ Test results
- ✅ Documentation build files

## 🚀 Quick Setup

### Option A: Use the Setup Script (Recommended)

```bash
# Make the script executable
chmod +x setup_monorepo.sh

# Run it
./setup_monorepo.sh
```

This will:
- ✅ Check your project structure
- ✅ Create .gitignore files
- ✅ Clean up unnecessary files
- ✅ Show you the next steps

### Option B: Manual Setup

```bash
# 1. Copy the gitignore files
cp MainProject-gitignore.txt .gitignore
cp EthereumKit-gitignore.txt EthereumKit/.gitignore

# 2. Remove files that should be ignored
find . -name ".DS_Store" -delete
rm -rf DerivedData/
rm -rf .build/

# 3. Initialize git (if not done)
git init

# 4. Add everything
git add .

# 5. Check what will be committed
git status

# 6. Make first commit
git commit -m "Initial commit with EthereumKit package"
```

## 🔐 Critical: Protecting Secrets

### Never Commit These:
- ❌ API Keys (Infura, Alchemy)
- ❌ Private keys
- ❌ Signing certificates
- ❌ .env files with secrets
- ❌ Config files with credentials

### How to Handle Secrets:

#### 1. Use Config.xcconfig (Excluded from git)

Create `Config.xcconfig`:
```
// Config.xcconfig - DO NOT COMMIT
INFURA_API_KEY = your_key_here
ALCHEMY_API_KEY = your_key_here
```

Add to `.gitignore`:
```
Config.xcconfig
```

Create `Config.example.xcconfig` (commit this):
```
// Config.example.xcconfig
INFURA_API_KEY = your_infura_key
ALCHEMY_API_KEY = your_alchemy_key
```

#### 2. Use Environment Variables

Create `Secrets.swift` (excluded):
```swift
struct Secrets {
    static let infuraKey = ProcessInfo.processInfo.environment["INFURA_KEY"] ?? ""
}
```

Add to `.gitignore`:
```
**/Secrets.swift
```

#### 3. Use Info.plist

Add keys to Info.plist, but **don't commit the actual values**:
```xml
<key>InfuraAPIKey</key>
<string>$(INFURA_API_KEY)</string>
```

Then use build settings or .xcconfig files.

## 📊 What Should Be Committed

### ✅ DO Commit:
- Source code (.swift files)
- EthereumKit package (entire folder)
- Xcode project file (.xcodeproj)
- README files
- Documentation
- Example configs (with placeholder values)
- .gitignore files
- Package.swift

### ❌ DON'T Commit:
- Build artifacts (.build, DerivedData)
- User-specific Xcode data (xcuserdata)
- API keys and secrets
- Compiled binaries
- .DS_Store files
- IDE settings (.vscode, .idea)
- Test artifacts

## 🌿 Branching Strategy

For a project this size, keep it simple:

```
main (or master)     ← Production-ready code
  ├── develop        ← Integration branch
  │   ├── feature/ethereum-integration
  │   ├── feature/usdc-transfer
  │   └── fix/gas-estimation
  └── hotfix/critical-bug
```

### Workflow:
1. Create feature branch from `develop`
2. Develop and commit changes
3. Test thoroughly
4. PR to `develop`
5. After testing, merge `develop` → `main`

## 🔍 Pre-Commit Checklist

Before committing:

```bash
# Check what's being committed
git status

# Review changes
git diff

# Make sure no secrets
git diff | grep -i "api.*key\|secret\|password"

# Verify tests pass
cd EthereumKit && swift test && cd ..

# Build succeeds
xcodebuild -project iMessageUSDC.xcodeproj -scheme iMessageUSDC build
```

## 📦 Package.resolved

The `Package.resolved` file:
- ❌ **Don't commit** for library/package projects (EthereumKit)
- ✅ **Do commit** for app projects (iMessageUSDC)

This is already handled in the gitignore files!

## 🚀 Publishing to GitHub

```bash
# 1. Create repo on GitHub (do NOT initialize with README)

# 2. Add remote
git remote add origin https://github.com/yourusername/iMessageUSDC.git

# 3. Push
git branch -M main
git push -u origin main

# 4. Verify on GitHub
open https://github.com/yourusername/iMessageUSDC
```

## 🧪 CI/CD Considerations

If you set up GitHub Actions or similar:

```yaml
# .github/workflows/test.yml
name: Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Test EthereumKit
        run: |
          cd EthereumKit
          swift test
      
      - name: Build App
        run: |
          xcodebuild -project iMessageUSDC.xcodeproj \
                     -scheme iMessageUSDC \
                     -destination 'platform=iOS Simulator,name=iPhone 15' \
                     build
```

## 📚 README Template

Your main README.md should include:

```markdown
# iMessageUSDC

A cryptocurrency wallet for iMessage, powered by EthereumKit.

## Features
- Send USDC via iMessage
- Multi-chain support (Ethereum, Polygon, Base, Arbitrum)
- Built-in transaction history

## Setup
1. Clone the repo
2. Copy `Config.example.xcconfig` to `Config.xcconfig`
3. Add your API keys to `Config.xcconfig`
4. Open `iMessageUSDC.xcodeproj`
5. Build and run!

## Architecture
- **iMessageUSDC**: Main app
- **MessagesExtension**: iMessage extension
- **EthereumKit**: Swift package for Ethereum JSON-RPC

## License
MIT
```

## 🎯 Next Steps

1. ✅ Run `setup_monorepo.sh` to configure gitignore
2. ✅ Review what will be committed: `git status`
3. ✅ Make your first commit
4. ✅ Push to GitHub
5. ✅ Set up branch protection on `main`
6. ✅ Add CI/CD (optional)

## 🆘 Troubleshooting

### Problem: Too many files showing in git status

**Solution:** Make sure .gitignore is in place:
```bash
# Add gitignore first
cp MainProject-gitignore.txt .gitignore
git add .gitignore
git commit -m "Add gitignore"

# Then add other files
git add .
```

### Problem: Accidentally committed secrets

**Solution:** Remove from history:
```bash
# Remove file from git but keep locally
git rm --cached path/to/secret/file

# Add to .gitignore
echo "path/to/secret/file" >> .gitignore

# Commit
git commit -m "Remove secrets from git"

# If already pushed, consider these secrets compromised!
# Rotate all API keys and secrets immediately!
```

### Problem: EthereumKit not showing in Xcode

**Solution:** 
1. File → Add Package Dependencies → Add Local
2. Select the `EthereumKit` folder
3. Add to your targets

## 📖 Resources

- [Swift Package Manager](https://swift.org/package-manager/)
- [Git Best Practices](https://git-scm.com/book/en/v2)
- [Xcode Source Control](https://developer.apple.com/documentation/xcode/source-control)

---

**Remember:** Your repo structure should make it easy to develop, test, and deploy. The monorepo approach works great for tightly coupled projects like yours! 🚀
