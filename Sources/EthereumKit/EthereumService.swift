//
//  EthereumService.swift
//  EthereumKit
//
//  Created by Meek Msaki on 2/7/26.
//

import Foundation

/// High-level service for common Ethereum operations
public class EthereumService {
    public let client: JSONRPCClient
    
    /// Initialize with your RPC endpoint (e.g., Infura, Alchemy, or local node)
    public init(rpcURL: String) {
        guard let client = JSONRPCClient(rpcURLString: rpcURL) else {
            fatalError("Invalid RPC URL: \(rpcURL)")
        }
        self.client = client
    }
    
    /// Initialize with a URL object
    public init(rpcURL: URL) {
        self.client = JSONRPCClient(rpcURL: rpcURL)
    }
    
    /// Initialize with an existing client
    public init(client: JSONRPCClient) {
        self.client = client
    }
    
    // MARK: - Block Information
    
    /// Get the latest block number
    public func getLatestBlockNumber() async throws -> Int {
        let hexString = try await client.eth_blockNumber()
        guard let blockNumber = hexString.hexToInt else {
            throw EthereumServiceError.invalidHexString(hexString)
        }
        return blockNumber
    }
    
    // MARK: - Balance Queries
    
    /// Get balance in Wei (as hex string)
    public func getBalance(address: String, block: String = "latest") async throws -> String {
        try await client.eth_getBalance(address: address, block: block)
    }
    
    /// Get balance in Ether
    public func getBalanceInEther(address: String, block: String = "latest") async throws -> Double {
        let weiHex = try await client.eth_getBalance(address: address, block: block)
        guard let ether = weiHex.weiToEther else {
            throw EthereumServiceError.invalidHexString(weiHex)
        }
        return ether
    }
    
    /// Get balance in Wei as UInt64
    public func getBalanceInWei(address: String, block: String = "latest") async throws -> UInt64 {
        let weiHex = try await client.eth_getBalance(address: address, block: block)
        guard let wei = weiHex.hexToUInt64 else {
            throw EthereumServiceError.invalidHexString(weiHex)
        }
        return wei
    }
    
    // MARK: - ERC-20 Token Operations
    
    /// Check ERC-20 token balance
    /// - Parameters:
    ///   - address: Wallet address
    ///   - tokenContractAddress: Token contract address
    /// - Returns: Balance as hex string
    public func getERC20Balance(address: String, tokenContractAddress: String) async throws -> String {
        // ERC-20 balanceOf function signature: balanceOf(address)
        let functionSelector = "0x70a08231" // keccak256("balanceOf(address)")[:8]
        let paddedAddress = HexUtils.padAddress(address)
        let data = functionSelector + paddedAddress
        
        return try await client.eth_call(to: tokenContractAddress, data: data)
    }
    
    /// Get ERC-20 token balance with decimals conversion
    /// - Parameters:
    ///   - address: Wallet address
    ///   - tokenContractAddress: Token contract address
    ///   - decimals: Token decimals (default: 6 for USDC)
    /// - Returns: Token balance as Double
    public func getERC20BalanceFormatted(address: String, tokenContractAddress: String, decimals: Int = 6) async throws -> Double {
        let balanceHex = try await getERC20Balance(address: address, tokenContractAddress: tokenContractAddress)
        guard let balance = balanceHex.hexToDouble else {
            throw EthereumServiceError.invalidHexString(balanceHex)
        }
        let divisor = pow(10.0, Double(decimals))
        return balance / divisor
    }
    
    /// Get USDC balance (convenience method with 6 decimals)
    public func getUSDCBalance(address: String, usdcContractAddress: String) async throws -> Double {
        try await getERC20BalanceFormatted(address: address, tokenContractAddress: usdcContractAddress, decimals: 6)
    }
    
    // MARK: - Gas Information
    
    /// Get current gas price in Wei (as hex string)
    public func getGasPrice() async throws -> String {
        try await client.eth_gasPrice()
    }
    
    /// Get current gas price in Gwei
    public func getGasPriceInGwei() async throws -> Double {
        let hexString = try await client.eth_gasPrice()
        guard let gwei = hexString.weiToGwei else {
            throw EthereumServiceError.invalidHexString(hexString)
        }
        return gwei
    }
    
    /// Estimate gas for a transaction
    public func estimateGas(to: String, data: String, from: String? = nil) async throws -> UInt64 {
        let gasHex = try await client.eth_estimateGas(to: to, data: data, from: from)
        guard let gas = gasHex.hexToUInt64 else {
            throw EthereumServiceError.invalidHexString(gasHex)
        }
        return gas
    }
    
    // MARK: - Network Information
    
    /// Get chain ID
    public func getChainId() async throws -> Int {
        let hexString = try await client.eth_chainId()
        guard let chainId = hexString.hexToInt else {
            throw EthereumServiceError.invalidHexString(hexString)
        }
        return chainId
    }
    
    /// Get transaction count (nonce) for an address
    public func getTransactionCount(address: String, block: String = "latest") async throws -> Int {
        let hexString = try await client.eth_getTransactionCount(address: address, block: block)
        guard let count = hexString.hexToInt else {
            throw EthereumServiceError.invalidHexString(hexString)
        }
        return count
    }
    
    // MARK: - Transaction Operations
    
    /// Send a raw signed transaction
    /// - Parameter signedTxHex: Signed transaction as hex string
    /// - Returns: Transaction hash
    public func sendTransaction(signedTxHex: String) async throws -> String {
        try await client.eth_sendRawTransaction(signedTx: signedTxHex)
    }
    
    /// Get transaction receipt
    public func getTransactionReceipt(txHash: String) async throws -> JSONValue {
        try await client.eth_getTransactionReceipt(txHash: txHash)
    }
}

// MARK: - Network Configuration

/// Helper for managing different network configurations
public struct NetworkConfig {
    public let name: String
    public let rpcURL: String
    public let chainId: Int
    public let usdcAddress: String?
    public let explorerURL: String?
    
    public init(name: String, rpcURL: String, chainId: Int, usdcAddress: String? = nil, explorerURL: String? = nil) {
        self.name = name
        self.rpcURL = rpcURL
        self.chainId = chainId
        self.usdcAddress = usdcAddress
        self.explorerURL = explorerURL
    }
    
    // MARK: - Mainnet Networks
    
    public static func mainnet(apiKey: String) -> NetworkConfig {
        NetworkConfig(
            name: "Ethereum Mainnet",
            rpcURL: "https://mainnet.infura.io/v3/\(apiKey)",
            chainId: 1,
            usdcAddress: "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48",
            explorerURL: "https://etherscan.io"
        )
    }
    
    public static let polygon = NetworkConfig(
        name: "Polygon",
        rpcURL: "https://polygon-rpc.com",
        chainId: 137,
        usdcAddress: "0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174",
        explorerURL: "https://polygonscan.com"
    )
    
    public static let arbitrum = NetworkConfig(
        name: "Arbitrum One",
        rpcURL: "https://arb1.arbitrum.io/rpc",
        chainId: 42161,
        usdcAddress: "0xFF970A61A04b1cA14834A43f5dE4533eBDDB5CC8",
        explorerURL: "https://arbiscan.io"
    )
    
    public static let base = NetworkConfig(
        name: "Base",
        rpcURL: "https://mainnet.base.org",
        chainId: 8453,
        usdcAddress: "0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913",
        explorerURL: "https://basescan.org"
    )
    
    public static let optimism = NetworkConfig(
        name: "Optimism",
        rpcURL: "https://mainnet.optimism.io",
        chainId: 10,
        usdcAddress: "0x7F5c764cBc14f9669B88837ca1490cCa17c31607",
        explorerURL: "https://optimistic.etherscan.io"
    )
    
    // MARK: - Testnet Networks
    
    public static func sepolia(apiKey: String) -> NetworkConfig {
        NetworkConfig(
            name: "Sepolia Testnet",
            rpcURL: "https://sepolia.infura.io/v3/\(apiKey)",
            chainId: 11155111,
            usdcAddress: nil,
            explorerURL: "https://sepolia.etherscan.io"
        )
    }
}

// MARK: - Errors

public enum EthereumServiceError: Error, LocalizedError {
    case invalidHexString(String)
    case invalidAddress(String)
    
    public var errorDescription: String? {
        switch self {
        case .invalidHexString(let hex):
            return "Invalid hex string: \(hex)"
        case .invalidAddress(let address):
            return "Invalid Ethereum address: \(address)"
        }
    }
}
