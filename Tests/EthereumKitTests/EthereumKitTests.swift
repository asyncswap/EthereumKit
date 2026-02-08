//
//  EthereumKitTests.swift
//  EthereumKit
//
//  Created by Meek Msaki on 2/7/26.
//

import Foundation
import Testing
@testable import EthereumKit

@Suite("Hex Utilities Tests")
struct HexUtilsTests {
    
    @Test("Convert hex to int")
    func hexToInt() {
        #expect(HexUtils.hexToInt("0xa") == 10)
        #expect(HexUtils.hexToInt("0xff") == 255)
        #expect(HexUtils.hexToInt("64") == 100)
        #expect("0x10".hexToInt == 16)
    }
    
    @Test("Convert int to hex")
    func intToHex() {
        #expect(HexUtils.intToHex(10) == "0xa")
        #expect(HexUtils.intToHex(255) == "0xff")
        #expect(16.toHex == "0x10")
    }
    
    @Test("Pad address")
    func padAddress() {
        let address = "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb"
        let padded = HexUtils.padAddress(address)
        #expect(padded.count == 64)
        #expect(padded.hasPrefix("000000000000000000000000"))
    }
    
    @Test("Wei to Ether conversion")
    func weiToEther() {
        // 1 ETH = 1e18 Wei = 0xde0b6b3a7640000
        let oneEthInWei = "0xde0b6b3a7640000"
        let ether = HexUtils.weiToEther(oneEthInWei)
        #expect(ether != nil)
        #expect(ether! > 0.99 && ether! < 1.01) // Account for floating point
    }
    
    @Test("Gwei to Wei conversion")
    func gweiToWei() {
        let weiHex = HexUtils.gweiToWeiHex(30.0)
        let gwei = HexUtils.weiToGwei(weiHex)
        #expect(gwei == 30.0)
    }
    
    @Test("Check valid hex strings")
    func validHex() {
        #expect("0x1234abcd".isValidHex == true)
        #expect("1234ABCD".isValidHex == true)
        #expect("0xGHIJ".isValidHex == false)
        #expect("not hex".isValidHex == false)
    }
}

@Suite("JSON-RPC Request/Response Tests")
struct JSONRPCTests {
    
    @Test("Create JSON-RPC request")
    func createRequest() throws {
        let request = JSONRPCRequest(id: 1, method: "eth_blockNumber", params: [])
        
        #expect(request.jsonrpc == "2.0")
        #expect(request.id == 1)
        #expect(request.method == "eth_blockNumber")
        #expect(request.params.isEmpty)
    }
    
    @Test("JSONValue string literal")
    func jsonValueString() {
        let value: JSONValue = "hello"
        if case .string(let str) = value {
            #expect(str == "hello")
        } else {
            Issue.record("Expected string value")
        }
    }
    
    @Test("JSONValue int literal")
    func jsonValueInt() {
        let value: JSONValue = 42
        if case .int(let num) = value {
            #expect(num == 42)
        } else {
            Issue.record("Expected int value")
        }
    }
    
    @Test("JSONValue array literal")
    func jsonValueArray() {
        let value: JSONValue = ["test", 123]
        if case .array(let arr) = value {
            #expect(arr.count == 2)
        } else {
            Issue.record("Expected array value")
        }
    }
    
    @Test("JSONValue object literal")
    func jsonValueObject() {
        let value: JSONValue = [
            "to": "0x123",
            "value": 100
        ]
        if case .object(let obj) = value {
            #expect(obj.count == 2)
            #expect(obj["to"] != nil)
        } else {
            Issue.record("Expected object value")
        }
    }
    
    @Test("Encode and decode JSONValue")
    func encodeDecodeJSONValue() throws {
        let original: JSONValue = [
            "address": "0x123",
            "amount": 100,
            "active": true
        ]
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(original)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(JSONValue.self, from: data)
        
        #expect(original == decoded)
    }
}

@Suite("Network Configuration Tests")
struct NetworkConfigTests {
    
    @Test("Polygon network config")
    func polygonConfig() {
        let config = NetworkConfig.polygon
        #expect(config.name == "Polygon")
        #expect(config.chainId == 137)
        #expect(config.usdcAddress != nil)
    }
    
    @Test("Base network config")
    func baseConfig() {
        let config = NetworkConfig.base
        #expect(config.name == "Base")
        #expect(config.chainId == 8453)
        #expect(config.usdcAddress != nil)
    }
    
    @Test("Custom network config")
    func customConfig() {
        let config = NetworkConfig(
            name: "Custom Network",
            rpcURL: "https://custom.rpc",
            chainId: 999,
            usdcAddress: "0xCustomUSDC"
        )
        #expect(config.name == "Custom Network")
        #expect(config.chainId == 999)
    }
}
