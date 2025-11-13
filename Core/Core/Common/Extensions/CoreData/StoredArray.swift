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

    /// A property wrapper that provides an array,
    /// storing it in a `NSOrderedSet` or `NSOrderedSet?` property at the provided `rawKeyPath`.
    /// Falls back to empty array if decoding fails.
    public typealias StoredArray<Element> = CDStoredArray<Self, Element>
}

// MARK: - Array

@propertyWrapper
public struct CDStoredArray<EnclosingType: NSManagedObject, Element>: CDStoredWithDefaultPropertyWrapper {
    public typealias RawValue = NSOrderedSet
    public typealias DecodedValue = [Element]

    public let rawKeyPath: AnyKeyPath
    public let defaultValue: [Element] = []

    public init(_ rawKeyPath: ReferenceWritableKeyPath<EnclosingType, NSOrderedSet>) {
        self.rawKeyPath = rawKeyPath
    }

    public init(_ rawKeyPath: ReferenceWritableKeyPath<EnclosingType, NSOrderedSet?>) {
        self.rawKeyPath = rawKeyPath
    }

    public static func decode(_ rawValue: NSOrderedSet?) -> [Element]? {
        rawValue?.array as? [Element]
    }

    public static func encode(_ newValue: [Element]) -> NSOrderedSet {
        NSOrderedSet(array: newValue)
    }

    public static subscript(
        _enclosingInstance instance: EnclosingType,
        wrapped wrappedKeyPath: ReferenceWritableKeyPath<EnclosingType, DecodedValue>,
        storage storageKeyPath: ReferenceWritableKeyPath<EnclosingType, Self>
    ) -> DecodedValue {
        get { Self.decode(instance: instance, storageKeyPath: storageKeyPath) }
        set { Self.encode(newValue, instance: instance, storageKeyPath: storageKeyPath) }
    }

    public var wrappedValue: DecodedValue {
        get { fatalError() }
        set { fatalError() } // swiftlint:disable:this unused_setter_value
    }
}
