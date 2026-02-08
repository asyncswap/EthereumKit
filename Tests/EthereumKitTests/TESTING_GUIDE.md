# JSON-RPC Testing Guide

## 📋 Test Overview

The `JSONRPCTests.swift` file contains two types of tests:

### 1. **Unit Tests** (Always Run)

These test the JSON-RPC client logic without making network calls:

- ✅ Client creation
- ✅ Request encoding
- ✅ Response decoding
- ✅ Error handling

### 2. **Network Tests** (Opt-in)

These make real RPC calls to test actual blockchain interaction:

- ✅ Get block number
- ✅ Get account balance
- ✅ Get chain ID
- ✅ Get gas price
- ✅ Call ERC-20 contract (read-only)
- ✅ Concurrent calls
- ✅ Error scenarios

## 🚀 Running Tests

### Option 1: Run All Tests (Unit Tests Only)

```bash
cd EthereumKit
swift test
```

**Output:**

```
✓ Test "Create JSONRPCClient with URL string" passed
✓ Test "Test JSONRPCRequest encoding" passed
✓ Test "Test JSONRPCResponse decoding success" passed
...
Test Suite 'All tests' passed
```

### Option 2: Run With Network Tests

```bash
cd EthereumKit
RUN_NETWORK_TESTS=1 swift test
```

**Output:**

```
✓ Test "Get current block number from real network" passed
  Current block number: 19234567
✓ Test "Get balance for a known address" passed
  Balance for 0xde0B2956...: 0x1234abcd
...
Test Suite 'All tests' passed
```

### Option 3: Run in Xcode

#### For Unit Tests Only

1. Open `EthereumKit` package in Xcode
2. Press `Cmd + U`

#### For Network Tests

1. Product → Scheme → Edit Scheme
2. Select "Test" in sidebar
3. Go to "Arguments" tab
4. Under "Environment Variables", click `+`
5. Add:
   - Name: `RUN_NETWORK_TESTS`
   - Value: `1`
6. Press `Cmd + U`

## 📊 Test Details

### Network Tests Use Public Endpoints

All network tests use **Public Ethereum endpoint**:

- URL: `https://ethereum-rpc.publicnode.com`
- No API key required
- Rate limited but sufficient for testing
- Ethereum Mainnet only

### What Each Test Does

#### 1. `testRealEthBlockNumber`

```swift
// Gets the current block number from Ethereum mainnet
let blockNumber = try await client.eth_blockNumber()
// Example result: "0x1256a4f" (19,234,575)
```

#### 2. `testRealEthGetBalance`

```swift
// Checks the ETH balance of Ethereum Foundation
let balance = try await client.eth_getBalance(address: "0xde0B295...")
// Returns balance in Wei as hex string
```

#### 3. `testRealEthChainId`

```swift
// Verifies we're connected to mainnet (chain ID 1)
let chainId = try await client.eth_chainId()
// Should return "0x1"
```

#### 4. `testRealEthGasPrice`

```swift
// Gets current gas price
let gasPrice = try await client.eth_gasPrice()
// Converts to Gwei for readability
```

#### 5. `testRealERC20Call`

```swift
// Reads USDC balance of Binance wallet
// Tests eth_call for contract interactions
let result = try await client.eth_call(to: usdcContract, data: encodedData)
```

#### 6. `testConcurrentCalls`

```swift
// Makes multiple RPC calls simultaneously
async let blockNumber = client.eth_blockNumber()
async let gasPrice = client.eth_gasPrice()
async let chainId = client.eth_chainId()
// Tests thread safety of the actor-based client
```

#### 7. `testInvalidAddressError`

```swift
// Tests error handling for invalid inputs
// Should receive JSONRPCError from the server
```

## 🔧 Customizing Tests

### Use Your Own RPC Endpoint

Edit the test file to use your preferred endpoint:

```swift
// Replace this line in each test:
guard let client = JSONRPCClient(rpcURLString: "https://ethereum-rpc.publicnode.com") else {

// With your endpoint:
guard let client = JSONRPCClient(rpcURLString: "https://ethereum-rpc.publicnode.com") else {
```

### Test Different Networks

```swift
// Polygon
guard let client = JSONRPCClient(rpcURLString: "https://polygon-rpc.com") else {

// Base
guard let client = JSONRPCClient(rpcURLString: "https://mainnet.base.org") else {

// Arbitrum
guard let client = JSONRPCClient(rpcURLString: "https://arb1.arbitrum.io/rpc") else {
```

### Add More Tests

```swift
@Test("Your custom test",
      .enabled(if: ProcessInfo.processInfo.environment["RUN_NETWORK_TESTS"] == "1"))
func testCustomRPCCall() async throws {
    guard let client = JSONRPCClient(rpcURLString: "YOUR_RPC_URL") else {
        Issue.record("Failed to create client")
        return
    }
    
    // Your test code here
    let result = try await client.eth_blockNumber()
    #expect(result.hasPrefix("0x"))
}
```

## 📈 Continuous Integration

### GitHub Actions Example

```yaml
# .github/workflows/test.yml
name: Test EthereumKit

on: [push, pull_request]

jobs:
  test:
    runs-on: macos-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Run Unit Tests
        run: |
          cd EthereumKit
          swift test
      
      - name: Run Network Tests (with secrets)
        if: github.event_name == 'push' && github.ref == 'refs/heads/main'
        env:
          RUN_NETWORK_TESTS: 1
          INFURA_KEY: ${{ secrets.INFURA_KEY }}
        run: |
          cd EthereumKit
          swift test
```

### Xcode Cloud Configuration

```json
{
  "test": {
    "environment": {
      "RUN_NETWORK_TESTS": "1"
    }
  }
}
```

## 🎯 Best Practices

### 1. **Always Run Unit Tests**

```bash
# Before every commit
cd EthereumKit && swift test
```

### 2. **Run Network Tests Periodically**

```bash
# Weekly or before releases
RUN_NETWORK_TESTS=1 swift test
```

### 3. **Don't Overuse Network Tests**

- Public endpoints are rate limited
- Network tests are slower
- Save them for integration testing

### 4. **Mock for Development**

For rapid development, create mock tests:

```swift
@Test("Mock RPC response")
func testWithMock() async throws {
    // Use URLProtocol or mock client
    let mockClient = MockJSONRPCClient()
    mockClient.mockResponse = "0x1234"
    
    let result = try await mockClient.eth_blockNumber()
    #expect(result == "0x1234")
}
```

## ⚠️ Troubleshooting

### Network Tests Failing

**Problem:** "Connection timeout" or "Too many requests"

**Solutions:**

1. Check your internet connection
2. Use your own RPC endpoint (Infura/Alchemy)
3. Add delays between tests:

   ```swift
   try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
   ```

### Tests Pass Locally but Fail in CI

**Problem:** Network tests fail in CI environment

**Solutions:**

1. Disable network tests in CI:

   ```bash
   # Don't set RUN_NETWORK_TESTS
   swift test
   ```

2. Use secrets for API keys:

   ```yaml
   env:
     INFURA_KEY: ${{ secrets.INFURA_KEY }}
   ```

### Invalid Hex Response

**Problem:** Getting unexpected responses

**Solutions:**

1. Check the RPC endpoint is online
2. Verify chain ID matches your expectations
3. Print debug info:

   ```swift
   print("Response: \(blockNumber)")
   print("Is valid hex: \(blockNumber.isValidHex)")
   ```

## 📊 Test Coverage

Run tests with coverage:

```bash
swift test --enable-code-coverage
```

View coverage report:

```bash
xcrun llvm-cov show \
  .build/debug/EthereumKitPackageTests.xctest/Contents/MacOS/EthereumKitPackageTests \
  -instr-profile .build/debug/codecov/default.profdata
```

## 🎓 Learning Resources

### Understanding Ethereum JSON-RPC

- [Ethereum JSON-RPC Spec](https://ethereum.org/en/developers/docs/apis/json-rpc/)
- [Common RPC Methods](https://docs.alchemy.com/reference/ethereum-api-quickstart)

### Swift Testing

- [Swift Testing Framework](https://developer.apple.com/documentation/testing)
- [Async Testing](https://developer.apple.com/documentation/xctest/asynchronous_tests_and_expectations)

### Public RPC Endpoints

- [Public Node](https://publicnode.com/)

## 🚦 Quick Reference

```bash
# Run unit tests only (fast)
swift test

# Run all tests including network (slow)
RUN_NETWORK_TESTS=1 swift test

# Run specific test
swift test --filter JSONRPCTests.testRealEthBlockNumber

# Run with verbose output
swift test --verbose

# Run in Xcode
# Cmd + U

# Enable network tests in Xcode
# Edit Scheme → Test → Environment Variables → RUN_NETWORK_TESTS=1
```

## ✅ Checklist

Before committing:

- [ ] Unit tests pass: `swift test`
- [ ] Code builds: `swift build`
- [ ] Network tests pass (if changed RPC logic): `RUN_NETWORK_TESTS=1 swift test`
- [ ] No hardcoded API keys in code
- [ ] Tests are well-documented

---

**Happy Testing!** 🧪🎉
