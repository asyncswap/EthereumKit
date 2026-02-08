//
//  HexUtils.swift
//  EthereumKit
//
//  Created by Meek Msaki on 2/7/26.
//

import Foundation

/// Utilities for working with hexadecimal strings
public struct HexUtils {
    
    /// Convert a hex string to an integer
    /// - Parameter hex: Hex string (with or without "0x" prefix)
    /// - Returns: Integer value, or nil if invalid
    public static func hexToInt(_ hex: String) -> Int? {
        let cleanHex = hex.hasPrefix("0x") ? String(hex.dropFirst(2)) : hex
        return Int(cleanHex, radix: 16)
    }
    
    /// Convert a hex string to UInt64
    /// - Parameter hex: Hex string (with or without "0x" prefix)
    /// - Returns: UInt64 value, or nil if invalid
    public static func hexToUInt64(_ hex: String) -> UInt64? {
        let cleanHex = hex.hasPrefix("0x") ? String(hex.dropFirst(2)) : hex
        return UInt64(cleanHex, radix: 16)
    }
    
    /// Convert a hex string to a Double (useful for large numbers like Wei)
    /// - Parameter hex: Hex string (with or without "0x" prefix)
    /// - Returns: Double value, or nil if invalid
    public static func hexToDouble(_ hex: String) -> Double? {
        guard let uint = hexToUInt64(hex) else { return nil }
        return Double(uint)
    }
    
    /// Convert an integer to a hex string with "0x" prefix
    /// - Parameter value: Integer value
    /// - Returns: Hex string with "0x" prefix
    public static func intToHex(_ value: Int) -> String {
        return "0x" + String(value, radix: 16)
    }
    
    /// Convert a UInt64 to a hex string with "0x" prefix
    /// - Parameter value: UInt64 value
    /// - Returns: Hex string with "0x" prefix
    public static func uint64ToHex(_ value: UInt64) -> String {
        return "0x" + String(value, radix: 16)
    }
    
    /// Pad an address to 64 characters (32 bytes) for ABI encoding
    /// - Parameter address: Ethereum address (with or without "0x")
    /// - Returns: Padded hex string without "0x" prefix, with leading zeros
    public static func padAddress(_ address: String) -> String {
        let cleanAddress = address.hasPrefix("0x") ? String(address.dropFirst(2)) : address
        // Left-pad with zeros to reach 64 characters
        let paddingNeeded = max(0, 64 - cleanAddress.count)
        let padding = String(repeating: "0", count: paddingNeeded)
        return padding + cleanAddress
    }
    
    /// Pad a hex value to specified length
    /// - Parameters:
    ///   - hex: Hex string (with or without "0x")
    ///   - length: Target length (in characters, not bytes)
    /// - Returns: Padded hex string without "0x" prefix
    public static func padHex(_ hex: String, toLength length: Int) -> String {
        let cleanHex = hex.hasPrefix("0x") ? String(hex.dropFirst(2)) : hex
        return cleanHex.padding(toLength: length, withPad: "0", startingAt: 0)
    }
    
    /// Convert Wei (as hex string) to Ether
    /// - Parameter weiHex: Wei amount as hex string
    /// - Returns: Ether amount as Double
    public static func weiToEther(_ weiHex: String) -> Double? {
        guard let wei = hexToDouble(weiHex) else { return nil }
        return wei / 1_000_000_000_000_000_000.0
    }
    
    /// Convert Wei (as hex string) to Gwei
    /// - Parameter weiHex: Wei amount as hex string
    /// - Returns: Gwei amount as Double
    public static func weiToGwei(_ weiHex: String) -> Double? {
        guard let wei = hexToDouble(weiHex) else { return nil }
        return wei / 1_000_000_000.0
    }
    
    /// Convert Ether to Wei as hex string
    /// - Parameter ether: Ether amount
    /// - Returns: Wei as hex string with "0x" prefix
    public static func etherToWeiHex(_ ether: Double) -> String {
        let wei = UInt64(ether * 1_000_000_000_000_000_000.0)
        return uint64ToHex(wei)
    }
    
    /// Convert Gwei to Wei as hex string
    /// - Parameter gwei: Gwei amount
    /// - Returns: Wei as hex string with "0x" prefix
    public static func gweiToWeiHex(_ gwei: Double) -> String {
        let wei = UInt64(gwei * 1_000_000_000.0)
        return uint64ToHex(wei)
    }
}

/// String extension for hex utilities
public extension String {
    /// Check if string is a valid hex string
    var isValidHex: Bool {
        let cleanHex = self.hasPrefix("0x") ? String(self.dropFirst(2)) : self
        return cleanHex.allSatisfy { $0.isHexDigit }
    }
    
    /// Convert hex string to integer
    var hexToInt: Int? {
        HexUtils.hexToInt(self)
    }
    
    /// Convert hex string to UInt64
    var hexToUInt64: UInt64? {
        HexUtils.hexToUInt64(self)
    }
    
    /// Convert hex string to Double
    var hexToDouble: Double? {
        HexUtils.hexToDouble(self)
    }
    
    /// Convert Wei hex to Ether
    var weiToEther: Double? {
        HexUtils.weiToEther(self)
    }
    
    /// Convert Wei hex to Gwei
    var weiToGwei: Double? {
        HexUtils.weiToGwei(self)
    }
}

/// Int extension for hex utilities
public extension Int {
    /// Convert integer to hex string with "0x" prefix
    var toHex: String {
        HexUtils.intToHex(self)
    }
}

/// UInt64 extension for hex utilities
public extension UInt64 {
    /// Convert UInt64 to hex string with "0x" prefix
    var toHex: String {
        HexUtils.uint64ToHex(self)
    }
}
