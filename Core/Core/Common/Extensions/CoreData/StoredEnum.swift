//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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
import CoreData

extension CDStoredContainer {

    /// A property wrapper that provides an _optional_ string-based enum,
    /// storing it's `rawValue` in a `String?` property at the provided `rawKeyPath`.
    public typealias StoredEnum<T: RawRepresentable<String>> = CDStoredEnum<Self, T>

    /// A property wrapper that provides a _non-optional_ string-based enum,
    /// storing it's `rawValue` in a `String` or `String?` property at the provided `rawKeyPath`.
    /// Falls back to the provided `defaultValue` if decoding fails.
    public typealias StoredEnumWithDefault<T: RawRepresentable<String>> = CDStoredEnumWithDefault<Self, T>
}

// MARK: - Optional raw value

@propertyWrapper
public struct CDStoredEnum<EnclosingType: NSManagedObject, EnumType: RawRepresentable<String>>: CDStoredPropertyWrapper {
    public typealias RawValue = String?
    public typealias DecodedValue = EnumType?

    public let rawKeyPath: ReferenceWritableKeyPath<EnclosingType, String?>

    public init(_ rawKeyPath: ReferenceWritableKeyPath<EnclosingType, String?>) {
        self.rawKeyPath = rawKeyPath
    }

    public static func decode(_ rawValue: String?) -> EnumType? {
        rawValue.flatMap { EnumType(rawValue: $0) }
    }

    public static func encode(_ newValue: EnumType?) -> String? {
        newValue?.rawValue
    }

    public static subscript(
        _enclosingInstance instance: EnclosingType,
        wrapped wrappedKeyPath: ReferenceWritableKeyPath<EnclosingType, DecodedValue>,
        storage storageKeyPath: ReferenceWritableKeyPath<EnclosingType, Self>
    ) -> DecodedValue {
        get { Self.decode(instance: instance, storageKeyPath: storageKeyPath) }
        set { Self.encode(newValue, instance: instance, storageKeyPath: storageKeyPath) }
    }

    // unused but required
    public var wrappedValue: DecodedValue {
        get { fatalError() }
        set { fatalError() } // swiftlint:disable:this unused_setter_value
    }
}

// MARK: - Raw value with default value

@propertyWrapper
public struct CDStoredEnumWithDefault<EnclosingType: NSManagedObject, EnumType: RawRepresentable<String>>: CDStoredWithDefaultPropertyWrapper {
    public typealias RawValue = String
    public typealias DecodedValue = EnumType

    public let rawKeyPath: AnyKeyPath
    public let defaultValue: DecodedValue

    public init(_ rawKeyPath: ReferenceWritableKeyPath<EnclosingType, String>, _ defaultValue: DecodedValue) {
        self.rawKeyPath = rawKeyPath
        self.defaultValue = defaultValue
    }

    public init(_ rawKeyPath: ReferenceWritableKeyPath<EnclosingType, String?>, _ defaultValue: DecodedValue) {
        self.rawKeyPath = rawKeyPath
        self.defaultValue = defaultValue
    }

    public static func decode(_ rawValue: String?) -> EnumType? {
        rawValue.flatMap { EnumType(rawValue: $0) }
    }

    public static func encode(_ newValue: EnumType) -> String {
        newValue.rawValue
    }

    public static subscript(
        _enclosingInstance instance: EnclosingType,
        wrapped wrappedKeyPath: ReferenceWritableKeyPath<EnclosingType, DecodedValue>,
        storage storageKeyPath: ReferenceWritableKeyPath<EnclosingType, Self>
    ) -> DecodedValue {
        get { Self.decode(instance: instance, storageKeyPath: storageKeyPath) }
        set { Self.encode(newValue, instance: instance, storageKeyPath: storageKeyPath) }
    }

    // unused but required
    public var wrappedValue: DecodedValue {
        get { fatalError() }
        set { fatalError() } // swiftlint:disable:this unused_setter_value
    }
}
