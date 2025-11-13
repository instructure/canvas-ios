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

    /// A property wrapper that provides a `Double?` value,
    /// storing it in a `NSNumber?` property at the provided `rawKeyPath`.
    public typealias StoredDouble = CDStoredDouble<Self>

    /// A property wrapper that provides a `Int?` value,
    /// storing it in a `NSNumber?` property at the provided `rawKeyPath`.
    public typealias StoredInt = CDStoredInt<Self>
}

// MARK: - Optional Double

@propertyWrapper
public struct CDStoredDouble<EnclosingType: NSManagedObject>: CDStoredPropertyWrapper {
    public typealias RawValue = NSNumber?
    public typealias DecodedValue = Double?

    public let rawKeyPath: ReferenceWritableKeyPath<EnclosingType, RawValue>

    public init(_ rawKeyPath: ReferenceWritableKeyPath<EnclosingType, RawValue>) {
        self.rawKeyPath = rawKeyPath
    }

    public static func decode(_ rawValue: NSNumber?) -> Double? {
        rawValue?.doubleValue
    }

    public static func encode(_ newValue: Double?) -> NSNumber? {
        newValue.map { NSNumber(value: $0) }
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

// MARK: - Optional Int

@propertyWrapper
public struct CDStoredInt<EnclosingType: NSManagedObject>: CDStoredPropertyWrapper {
    public typealias RawValue = NSNumber?
    public typealias DecodedValue = Int?

    public let rawKeyPath: ReferenceWritableKeyPath<EnclosingType, NSNumber?>

    public init(_ rawKeyPath: ReferenceWritableKeyPath<EnclosingType, NSNumber?>) {
        self.rawKeyPath = rawKeyPath
    }

    public static func decode(_ rawValue: NSNumber?) -> Int? {
        rawValue?.intValue
    }

    public static func encode(_ newValue: Int?) -> NSNumber? {
        newValue.map { NSNumber(value: $0) }
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
