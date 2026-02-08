import Foundation
import Testing
@testable import EthereumKit

@Suite("JSON-RPC Client Tests")
struct JSONRPCBasicTests {
    
    // MARK: - Network Tests (disabled by default)
    // Set RUN_NETWORK_TESTS=1 to enable these tests
    
    @Test("Get current block number from real network",
          .enabled(if: ProcessInfo.processInfo.environment["RUN_NETWORK_TESTS"] == "1"))
    func testRealEthBlockNumber() async throws {
        // Using public Cloudflare Ethereum endpoint (no API key needed)
        guard let client = JSONRPCClient(rpcURLString: "https://cloudflare-eth.com") else {
            Issue.record("Failed to create client")
            return
        }
        
        let blockNumber = try await client.eth_blockNumber()
        
        // Verify response format
        #expect(blockNumber.hasPrefix("0x"), "Block number should start with 0x")
        #expect(blockNumber.count > 2, "Block number should have hex digits")
        
        // Verify it's a valid hex number
        #expect(blockNumber.isValidHex, "Block number should be valid hex")
        
        // Convert to int and verify it's reasonable
        if let blockInt = blockNumber.hexToInt {
            #expect(blockInt > 0, "Block number should be positive")
            print("✓ Current block number: \(blockInt)")
        }
    }
    
    @Test("Get balance for a known address",
          .enabled(if: ProcessInfo.processInfo.environment["RUN_NETWORK_TESTS"] == "1"))
    func testRealEthGetBalance() async throws {
        guard let client = JSONRPCClient(rpcURLString: "https://cloudflare-eth.com") else {
            Issue.record("Failed to create client")
            return
        }
        
        // Ethereum Foundation address (public, well-known)
        let ethFoundation = "0xde0B295669a9FD93d5F28D9Ec85E40f4cb697BAe"
        
        let balance = try await client.eth_getBalance(address: ethFoundation)
        
        // Verify response format
        #expect(balance.hasPrefix("0x"), "Balance should start with 0x")
        #expect(balance.isValidHex, "Balance should be valid hex")
        
        print("✓ Balance for \(ethFoundation): \(balance)")
    }
    
    @Test("Get chain ID from network",
          .enabled(if: ProcessInfo.processInfo.environment["RUN_NETWORK_TESTS"] == "1"))
    func testRealEthChainId() async throws {
        guard let client = JSONRPCClient(rpcURLString: "https://cloudflare-eth.com") else {
            Issue.record("Failed to create client")
            return
        }
        
        let chainId = try await client.eth_chainId()
        
        // Verify response
        #expect(chainId.hasPrefix("0x"), "Chain ID should start with 0x")
        
        // Should be 0x1 for Ethereum mainnet
        if let chainIdInt = chainId.hexToInt {
            #expect(chainIdInt == 1, "Cloudflare endpoint should return chain ID 1 (mainnet)")
            print("✓ Chain ID: \(chainIdInt)")
        }
    }
    
    @Test("Get gas price from network",
          .enabled(if: ProcessInfo.processInfo.environment["RUN_NETWORK_TESTS"] == "1"))
    func testRealEthGasPrice() async throws {
        guard let client = JSONRPCClient(rpcURLString: "https://cloudflare-eth.com") else {
            Issue.record("Failed to create client")
            return
        }
        
        let gasPrice = try await client.eth_gasPrice()
        
        // Verify response format
        #expect(gasPrice.hasPrefix("0x"), "Gas price should start with 0x")
        #expect(gasPrice.isValidHex, "Gas price should be valid hex")
        
        // Convert to Gwei for readability
        if let gwei = gasPrice.weiToGwei {
            #expect(gwei > 0, "Gas price should be positive")
            print("✓ Current gas price: \(gwei) Gwei")
        }
    }
    
    @Test("Test ERC-20 USDC balance call (read-only)",
          .enabled(if: ProcessInfo.processInfo.environment["RUN_NETWORK_TESTS"] == "1"))
    func testRealERC20Call() async throws {
        guard let client = JSONRPCClient(rpcURLString: "https://cloudflare-eth.com") else {
            Issue.record("Failed to create client")
            return
        }
        
        // USDC contract on Ethereum mainnet
        let usdcContract = "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48"
        // Binance wallet (known to have USDC)
        let binanceWallet = "0xF977814e90dA44bFA03b6295A0616a897441aceC"
        
        // ERC-20 balanceOf function
        let functionSelector = "0x70a08231"
        let paddedAddress = HexUtils.padAddress(binanceWallet)
        let data = functionSelector + paddedAddress
        
        let result = try await client.eth_call(to: usdcContract, data: data)
        
        // Verify response
        #expect(result.hasPrefix("0x"), "Result should start with 0x")
        #expect(result.isValidHex, "Result should be valid hex")
        
        // Convert USDC balance (6 decimals)
        if let balanceRaw = result.hexToDouble {
            let usdcBalance = balanceRaw / 1_000_000.0
            print("✓ USDC balance: \(usdcBalance) USDC")
        }
    }
    
    @Test("Test multiple concurrent RPC calls",
          .enabled(if: ProcessInfo.processInfo.environment["RUN_NETWORK_TESTS"] == "1"))
    func testConcurrentCalls() async throws {
        guard let client = JSONRPCClient(rpcURLString: "https://cloudflare-eth.com") else {
            Issue.record("Failed to create client")
            return
        }
        
        // Make multiple calls concurrently
        async let blockNumber = client.eth_blockNumber()
        async let gasPrice = client.eth_gasPrice()
        async let chainId = client.eth_chainId()
        
        let (block, gas, chain) = try await (blockNumber, gasPrice, chainId)
        
        // All should succeed
        #expect(block.hasPrefix("0x"))
        #expect(gas.hasPrefix("0x"))
        #expect(chain.hasPrefix("0x"))
        
        print("✓ Concurrent calls successful:")
        print("  Block: \(block)")
        print("  Gas: \(gas)")
        print("  Chain: \(chain)")
    }
    
    @Test("Test error handling for invalid address",
          .enabled(if: ProcessInfo.processInfo.environment["RUN_NETWORK_TESTS"] == "1"))
    func testInvalidAddressError() async throws {
        guard let client = JSONRPCClient(rpcURLString: "https://cloudflare-eth.com") else {
            Issue.record("Failed to create client")
            return
        }
        
        // Invalid address (too short)
        let invalidAddress = "0xInvalidAddress"
        
        do {
            _ = try await client.eth_getBalance(address: invalidAddress)
            Issue.record("Should have thrown an error for invalid address")
        } catch let error as JSONRPCError {
            // Expected - should get RPC error
            #expect(error.code != 0, "Should have error code")
            print("✓ Correctly received error: \(error.message)")
        } catch {
            Issue.record("Unexpected error type: \(error)")
        }
    }
    
    // MARK: - Unit Tests (always enabled)
    
    @Test("Create JSONRPCClient with URL string")
    func testClientCreation() {
        let client = JSONRPCClient(rpcURLString: "https://mainnet.infura.io/v3/test")
        #expect(client != nil, "Should create client with valid URL")
        
        let invalidClient = JSONRPCClient(rpcURLString: "not a url")
        #expect(invalidClient == nil, "Should return nil for invalid URL")
    }
    
    @Test("Test JSONRPCRequest encoding")
    func testRequestEncoding() throws {
        let request = JSONRPCRequest(
            id: 1,
            method: "eth_blockNumber",
            params: []
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(request)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        
        #expect(json?["jsonrpc"] as? String == "2.0")
        #expect(json?["id"] as? Int == 1)
        #expect(json?["method"] as? String == "eth_blockNumber")
        #expect((json?["params"] as? [Any])?.isEmpty == true)
    }
    
    @Test("Test JSONRPCRequest with parameters")
    func testRequestWithParams() throws {
        let request = JSONRPCRequest(
            id: 2,
            method: "eth_getBalance",
            params: [
                .string("0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb"),
                .string("latest")
            ]
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(request)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        
        #expect(json?["method"] as? String == "eth_getBalance")
        
        let params = json?["params"] as? [String]
        #expect(params?.count == 2)
        #expect(params?[0] == "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb")
        #expect(params?[1] == "latest")
    }
    
    @Test("Test JSONRPCResponse decoding success")
    func testResponseDecodingSuccess() throws {
        let jsonString = """
        {
            "jsonrpc": "2.0",
            "id": 1,
            "result": "0x1234567"
        }
        """
        
        let data = jsonString.data(using: .utf8)!
        let decoder = JSONDecoder()
        let response = try decoder.decode(JSONRPCResponse<String>.self, from: data)
        
        #expect(response.jsonrpc == "2.0")
        #expect(response.id == 1)
        #expect(response.result == "0x1234567")
        #expect(response.error == nil)
        #expect(response.isSuccess == true)
    }
    
    @Test("Test JSONRPCResponse decoding error")
    func testResponseDecodingError() throws {
        let jsonString = """
        {
            "jsonrpc": "2.0",
            "id": 1,
            "error": {
                "code": -32600,
                "message": "Invalid Request",
                "data": null
            }
        }
        """
        
        let data = jsonString.data(using: .utf8)!
        let decoder = JSONDecoder()
        let response = try decoder.decode(JSONRPCResponse<String>.self, from: data)
        
        #expect(response.result == nil)
        #expect(response.error != nil)
        #expect(response.error?.code == -32600)
        #expect(response.error?.message == "Invalid Request")
        #expect(response.isSuccess == false)
    }
}
// MARK: - Test Configuration Helper

extension JSONRPCBasicTests {
    /// Helper to check if network tests are enabled
    static var networkTestsEnabled: Bool {
        ProcessInfo.processInfo.environment["RUN_NETWORK_TESTS"] == "1"
    }
    
    /// Print instructions for running network tests
    static func printNetworkTestInstructions() {
        print("""
        
        ℹ️  Network tests are disabled by default.
        
        To enable them, run:
        RUN_NETWORK_TESTS=1 swift test
        
        Or in Xcode:
        1. Edit Scheme → Test
        2. Arguments → Environment Variables
        3. Add: RUN_NETWORK_TESTS = 1
        
        """)
    }
}

