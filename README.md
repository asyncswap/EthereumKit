# EthereumKit

A modern, Swift-native Ethereum JSON-RPC client built with Swift Concurrency (async/await). Perfect for iOS, macOS, watchOS, and tvOS applications.

## Features

- ✅ **Pure Swift** - No JavaScript bridges or web3.js dependencies
- ✅ **Swift Concurrency** - Built with async/await and actors
- ✅ **Type-Safe** - Full Codable support with compile-time safety
- ✅ **Cross-Platform** - Works on iOS 16+, macOS 13+, watchOS 9+, tvOS 16+
- ✅ **Lightweight** - Zero external dependencies
- ✅ **ERC-20 Support** - Built-in helpers for token interactions
- ✅ **Network Configs** - Pre-configured for popular networks (Ethereum, Polygon, Arbitrum, Base, Optimism)

## Installation

### Swift Package Manager

Add EthereumKit to your project:

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/EthereumKit.git", from: "1.0.0")
]
```

Or in Xcode:

1. File → Add Package Dependencies
2. Enter the repository URL
3. Select version and add to your target

## Quick Start

### Basic Usage

```swift
import EthereumKit

// Initialize the service
let service = EthereumService(rpcURL: "https://mainnet.infura.io/v3/YOUR_API_KEY")

// Get latest block number
let blockNumber = try await service.getLatestBlockNumber()
print("Latest block: \(blockNumber)")

// Get ETH balance
let balance = try await service.getBalanceInEther(address: "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb")
print("Balance: \(balance) ETH")

// Get USDC balance
let usdc = try await service.getUSDCBalance(
    address: "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb",
    usdcContractAddress: "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48"
)
print("USDC Balance: \(usdc)")
```

### Using Network Configs

```swift
// Use pre-configured networks
let config = NetworkConfig.polygon
let service = EthereumService(rpcURL: config.rpcURL)

if let usdcAddress = config.usdcAddress {
    let balance = try await service.getUSDCBalance(
        address: "0x...",
        usdcContractAddress: usdcAddress
    )
}
```

### Raw JSON-RPC Calls

```swift
let client = JSONRPCClient(rpcURLString: "https://mainnet.infura.io/v3/YOUR_KEY")!

// Simple call
let blockNumber: String = try await client.call(method: "eth_blockNumber")

// Call with parameters
let balance: String = try await client.call(
    method: "eth_getBalance",
    params: [
        .string("0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb"),
        .string("latest")
    ]
)
```

### Hex Utilities

```swift
// Convert hex to integers
let blockNum = "0x1234".hexToInt // Returns 4660

// Convert integers to hex
let hex = 100.toHex // Returns "0x64"

// Convert Wei to Ether
let ether = "0xde0b6b3a7640000".weiToEther // Returns 1.0

// Pad addresses for ABI encoding
let padded = HexUtils.padAddress("0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb")
```

## Supported Networks

Pre-configured networks available out of the box:

| Network | Chain ID | USDC Address |
|---------|----------|--------------|
| Ethereum Mainnet | 1 | ✅ |
| Polygon | 137 | ✅ |
| Arbitrum One | 42161 | ✅ |
| Base | 8453 | ✅ |
| Optimism | 10 | ✅ |
| Sepolia Testnet | 11155111 | ✅ |

## Available Methods

### Block & Network Info

- `getLatestBlockNumber()` - Get current block number
- `getChainId()` - Get network chain ID

### Balance Queries

- `getBalance()` - Get ETH balance (Wei as hex)
- `getBalanceInEther()` - Get ETH balance (as Double)
- `getBalanceInWei()` - Get ETH balance (as UInt64)

### ERC-20 Tokens

- `getERC20Balance()` - Get token balance (raw hex)
- `getERC20BalanceFormatted()` - Get token balance with decimals
- `getUSDCBalance()` - Convenience method for USDC

### Gas & Transactions

- `getGasPrice()` - Get current gas price
- `getGasPriceInGwei()` - Get gas price in Gwei
- `estimateGas()` - Estimate gas for transaction
- `getTransactionCount()` - Get nonce for address
- `sendTransaction()` - Send signed transaction
- `getTransactionReceipt()` - Get transaction receipt

### Raw RPC Access

All standard Ethereum JSON-RPC methods are available:

- `eth_blockNumber`
- `eth_getBalance`
- `eth_call`
- `eth_sendRawTransaction`
- `eth_estimateGas`
- And more...

## Error Handling

```swift
do {
    let balance = try await service.getBalanceInEther(address: "0x...")
    print("Balance: \(balance)")
} catch let error as JSONRPCError {
    // JSON-RPC error from server
    print("RPC Error [\(error.code)]: \(error.message)")
} catch let error as EthereumServiceError {
    // Service-level error
    print("Service Error: \(error.localizedDescription)")
} catch {
    // Network or other errors
    print("Error: \(error)")
}
```

## Architecture

### Components

1. **JSONRPCClient (Actor)** - Thread-safe, low-level RPC client
2. **EthereumService (Class)** - High-level API with convenience methods
3. **HexUtils** - Utilities for hex/decimal conversions
4. **NetworkConfig** - Pre-configured network settings

### Thread Safety

`JSONRPCClient` is an actor, ensuring all RPC calls are thread-safe and can be called from any context:

```swift
Task {
    let balance = try await client.eth_getBalance(address: "0x...")
}

Task.detached {
    let gasPrice = try await client.eth_gasPrice()
}
```

## Examples

### Check Multiple Balances

```swift
let addresses = ["0xAddress1", "0xAddress2", "0xAddress3"]

await withTaskGroup(of: (String, Double).self) { group in
    for address in addresses {
        group.addTask {
            let balance = try await service.getBalanceInEther(address: address)
            return (address, balance)
        }
    }
    
    for await (address, balance) in group {
        print("\(address): \(balance) ETH")
    }
}
```

### Call Smart Contract

```swift
// Example: Get ERC-20 token symbol
func getTokenSymbol(contractAddress: String) async throws -> String {
    let functionSelector = "0x95d89b41" // symbol()
    let result = try await client.eth_call(to: contractAddress, data: functionSelector)
    // Parse result...
    return result
}
```

## Testing

Run tests using Swift Testing:

```bash
swift test
```

Or in Xcode: `Cmd + U`

## Requirements

- iOS 16.0+ / macOS 13.0+ / watchOS 9.0+ / tvOS 16.0+
- Swift 5.9+
- Xcode 15.0+

## License

MIT License - feel free to use in your projects!

## Contributing

Contributions welcome! Please feel free to submit a Pull Request.

## Roadmap

- [ ] Transaction signing support
- [ ] ENS resolution
- [ ] WebSocket support for subscriptions
- [ ] Batch RPC calls
- [ ] Gas price estimation strategies
- [ ] Transaction status monitoring

## Credits

Built with ❤️ for the iOS Ethereum community.
