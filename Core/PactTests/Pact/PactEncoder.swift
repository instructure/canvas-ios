//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

import Foundation
import Core
import PactConsumerSwift
import TestsFoundation

protocol PactEncodable: Encodable {
    func pactEncode(to encoder: PactEncoder) throws
}

// Implementation borrows heavily from JSONEncoder in swift-corelibs-foundation
class PactEncoder {
    let codingPath: [CodingKey]
    var userInfo: [CodingUserInfoKey: Any] = [:]
    var storage: NSObject?

    static func encode<T: Encodable>(_ value: T) throws -> Data {
        let topLevel = try encodeToJsonObject(value)
        return try JSONSerialization.data(withJSONObject: topLevel, options: .fragmentsAllowed)
    }

    static func encodeToJsonObject<T: Encodable>(_ value: T) throws -> NSObject {
        try box(value, codingPath: [])
    }

    private init(codingPath: [CodingKey]) {
        self.codingPath = codingPath
    }

    static func box<T: Encodable>(_ value: T, codingPath: [CodingKey]) throws -> NSObject {
        let encoder = PactEncoder(codingPath: codingPath)
        try encoder.encode(value)
        guard let topLevel = encoder.storage else {
            let context = EncodingError.Context(
                codingPath: [],
                debugDescription: "value \(T.self) did not encode any values."
            )
            throw EncodingError.invalidValue(value, context)
        }
        return topLevel
    }

    // pact-specific encodings
    static func box(_ value: String, matching regex: String) -> NSObject {
        Matcher.term(matcher: regex, generate: value) as NSObject
    }

    static func box<T: Encodable>(somethingLike value: T, codingPath: [CodingKey]) throws -> NSObject {
        let boxed = try PactEncoder.box(value, codingPath: codingPath)
        return Matcher.somethingLike(boxed) as NSObject
    }

    static func box<T: Encodable>(eachLike value: T, min: Int = 1, codingPath: [CodingKey]) throws -> NSObject {
        let boxed = try PactEncoder.box(value, codingPath: codingPath)
        return Matcher.eachLike(boxed, min: min) as NSObject
    }

    func encode(_ value: String, matching regex: String) throws {
        storage = PactEncoder.box(value, matching: regex)
    }
    func encode<T: Encodable>(somethingLike value: T) throws { let boxed = try PactEncoder.box(value, codingPath: codingPath)
        storage = Matcher.somethingLike(boxed) as NSObject
    }

    func encode<T: Encodable>(eachLike value: T, min: Int = 1) throws {
        let boxed = try PactEncoder.box(value, codingPath: codingPath)
        storage = Matcher.eachLike(boxed, min: min) as NSObject
    }
}

extension PactEncoder: Encoder {
    func pactContainer<Key: CodingKey>(keyedBy type: Key.Type) -> KeyedContainer<Key> {
        let dict: NSMutableDictionary
        if storage == nil {
            dict = NSMutableDictionary()
            storage = dict
        } else if let value = storage as? NSMutableDictionary {
            dict = value
        } else {
            preconditionFailure("Attempt to push new keyed encoding container when already previously encoded at this path.")
        }
        return KeyedContainer<Key>(codingPath: codingPath, storage: dict)
    }

    func unkeyedPactContainer() -> UnkeyedContainer {
        let arr: NSMutableArray
        if storage == nil {
            arr = NSMutableArray()
            storage = arr
        } else if let value = storage as? NSMutableArray {
            arr = value
        } else {
            preconditionFailure("Attempt to push new keyed encoding container when already previously encoded at this path.")
        }
        return UnkeyedContainer(codingPath: codingPath, storage: arr)
    }

    func container<Key: CodingKey>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> {
        KeyedEncodingContainer(pactContainer(keyedBy: type))
    }
    func unkeyedContainer() -> UnkeyedEncodingContainer { unkeyedPactContainer() }
    func singleValueContainer() -> SingleValueEncodingContainer { self }
}

extension PactEncoder: SingleValueEncodingContainer {
    func encodeNil() throws { storage = NSNull() }
    func encode(_ value: Bool) throws { storage = value as NSObject }
    func encode(_ value: String) throws { storage = value as NSObject }
    func encode(_ value: Double) throws { storage = value as NSObject }
    func encode(_ value: Float) throws { storage = value as NSObject }
    func encode(_ value: Int) throws { storage = value as NSObject }
    func encode(_ value: Int8) throws { storage = value as NSObject }
    func encode(_ value: Int16) throws { storage = value as NSObject }
    func encode(_ value: Int32) throws { storage = value as NSObject }
    func encode(_ value: Int64) throws { storage = value as NSObject }
    func encode(_ value: UInt) throws { storage = value as NSObject }
    func encode(_ value: UInt8) throws { storage = value as NSObject }
    func encode(_ value: UInt16) throws { storage = value as NSObject }
    func encode(_ value: UInt32) throws { storage = value as NSObject }
    func encode(_ value: UInt64) throws { storage = value as NSObject }

    static var nonCustom: Set<String> = []

    func encode<T: Encodable>(_ value: T) throws {
        if let value = value as? PactEncodable {
            try value.pactEncode(to: self)
        } else {
            let typeName = "\(T.self)"
            if !PactEncoder.nonCustom.contains(typeName) {
                let path = (codingPath.map { $0.stringValue }).joined(separator: ".")
                print("no custom pact encoding for type \(typeName) at path \(path)")
                PactEncoder.nonCustom.insert(typeName)
            }
            try value.encode(to: self)
        }
    }

    func encodeAndFix<T: Encodable>(_ value: T, fixup: (PactEncoder, inout NSObject?) throws -> Void) throws {
        try value.encode(to: self)
        try fixup(self, &storage)
    }

    public struct KeyedContainer<K: CodingKey>: KeyedEncodingContainerProtocol {
        typealias Key = K
        var codingPath: [CodingKey]
        let storage: NSMutableDictionary

        init(codingPath: [CodingKey] = [], storage: NSMutableDictionary = NSMutableDictionary()) {
            self.codingPath = codingPath
            self.storage = storage
        }

        mutating func encodeNil(forKey key: K) throws { storage[key.stringValue] = NSNull() }
        mutating func encode(_ value: Bool, forKey key: K) throws { storage[key.stringValue] = value }
        mutating func encode(_ value: String, forKey key: K) throws { storage[key.stringValue] = value }
        mutating func encode(_ value: Double, forKey key: K) throws { storage[key.stringValue] = value }
        mutating func encode(_ value: Float, forKey key: K) throws { storage[key.stringValue] = value }
        mutating func encode(_ value: Int, forKey key: K) throws { storage[key.stringValue] = value }
        mutating func encode(_ value: Int8, forKey key: K) throws { storage[key.stringValue] = value }
        mutating func encode(_ value: Int16, forKey key: K) throws { storage[key.stringValue] = value }
        mutating func encode(_ value: Int32, forKey key: K) throws { storage[key.stringValue] = value }
        mutating func encode(_ value: Int64, forKey key: K) throws { storage[key.stringValue] = value }
        mutating func encode(_ value: UInt, forKey key: K) throws { storage[key.stringValue] = value }
        mutating func encode(_ value: UInt8, forKey key: K) throws { storage[key.stringValue] = value }
        mutating func encode(_ value: UInt16, forKey key: K) throws { storage[key.stringValue] = value }
        mutating func encode(_ value: UInt32, forKey key: K) throws { storage[key.stringValue] = value }
        mutating func encode(_ value: UInt64, forKey key: K) throws { storage[key.stringValue] = value }
        mutating func encode<T: Encodable>(_ value: T, forKey key: K) throws {
            storage[key.stringValue] = try PactEncoder.box(value, codingPath: codingPath + [key])
        }
        mutating func nestedContainer<NestedKey: CodingKey>(
            keyedBy keyType: NestedKey.Type,
            forKey key: K
        ) -> KeyedEncodingContainer<NestedKey> {
            let encoder = KeyedContainer<NestedKey>(codingPath: codingPath + [key])
            storage[key.stringValue] = encoder.storage
            return KeyedEncodingContainer(encoder)
        }

        mutating func nestedUnkeyedContainer(forKey key: K) -> UnkeyedEncodingContainer {
            let encoder = UnkeyedContainer(codingPath: codingPath + [key])
            storage[key.stringValue] = encoder.storage
            return encoder
        }

        mutating func superEncoder() -> Encoder {
            fatalError("superEncoder() is not implemented for PactEncoder")
        }

        mutating func superEncoder(forKey key: K) -> Encoder {
            fatalError("superEncoder(forKey:) is not implemented for PactEncoder")
        }

        mutating func encode(_ value: String, matching regex: String, forKey key: K) {
            storage[key.stringValue] = PactEncoder.box(value, matching: regex)
        }
        mutating func encode<T: Encodable>(somethingLike value: T, forKey key: K) throws {
            storage[key.stringValue] = try PactEncoder.box(somethingLike: value, codingPath: codingPath)
        }
        mutating func encode<T: Encodable>(eachLike value: T, min: Int = 1, forKey key: K) throws {
            storage[key.stringValue] = try PactEncoder.box(eachLike: value, min: min, codingPath: codingPath)
        }
    }

    public struct UnkeyedContainer: UnkeyedEncodingContainer {
        struct Key: CodingKey {
            let index: Int
            var intValue: Int? { index}
            var stringValue: String { "\(index)" }
            init(intValue: Int) {
                self.index = intValue
            }
            init?(stringValue: String) {
                guard let intValue = Int(stringValue) else { return nil }
                index = intValue
            }
        }

        let codingPath: [CodingKey]
        let storage: NSMutableArray

        var count: Int { storage.count }
        var nextKey: Key { Key(intValue: count) }

        init(codingPath: [CodingKey], storage: NSMutableArray = NSMutableArray()) {
            self.codingPath = codingPath
            self.storage = storage
        }

        mutating func encodeNil() throws { storage.add(NSNull()) }
        mutating func encode(_ value: Bool) throws { storage.add(value) }
        mutating func encode(_ value: String) throws { storage.add(value) }
        mutating func encode(_ value: Double) throws { storage.add(value) }
        mutating func encode(_ value: Float) throws { storage.add(value) }
        mutating func encode(_ value: Int) throws { storage.add(value) }
        mutating func encode(_ value: Int8) throws { storage.add(value) }
        mutating func encode(_ value: Int16) throws { storage.add(value) }
        mutating func encode(_ value: Int32) throws { storage.add(value) }
        mutating func encode(_ value: Int64) throws { storage.add(value) }
        mutating func encode(_ value: UInt) throws { storage.add(value) }
        mutating func encode(_ value: UInt8) throws { storage.add(value) }
        mutating func encode(_ value: UInt16) throws { storage.add(value) }
        mutating func encode(_ value: UInt32) throws { storage.add(value) }
        mutating func encode<T: Encodable>(_ value: T) throws {
            storage.add(try PactEncoder.box(value, codingPath: codingPath + [nextKey]))
        }

        mutating func nestedContainer<NestedKey: CodingKey>(
            keyedBy keyType: NestedKey.Type
        ) -> KeyedEncodingContainer<NestedKey> {
            let container = KeyedContainer<NestedKey>(codingPath: codingPath + [nextKey])
            storage.add(container.storage)
            return KeyedEncodingContainer(container)
        }

        mutating func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
            let container = UnkeyedContainer(codingPath: codingPath + [nextKey])
            storage.add(container.storage)
            return container
        }

        mutating func superEncoder() -> Encoder {
            fatalError("superEncoder() is not implemented for PactEncoder")
        }

        mutating func encode(_ value: String, matching regex: String) {
            storage.add(PactEncoder.box(value, matching: regex))
        }
        mutating func encode<T: Encodable>(somethingLike value: T) throws {
            storage.add(try PactEncoder.box(somethingLike: value, codingPath: codingPath))
        }
        mutating func encode<T: Encodable>(eachLike value: T, min: Int = 1) throws {
            storage.add(try PactEncoder.box(eachLike: value, min: min, codingPath: codingPath))
        }
    }
}
