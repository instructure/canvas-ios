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

// MARK: - CDStoredPropertyWrapper

/// Helper protocol to extract some boilerplate code required for property wrappers
/// that store their wrapped value in a private @NSManaged property.
/// The storing property's type strictly matches `RawValue`.
///
/// The implementing types are property wrappers. They use a specific static `subscript` to get/set the
/// wrapped value based on the provided `rawKeypath`. The `subscript` must be defined in
/// the implementing type, otherwise it's not recognized in runtime. Handling the keypaths is extracted
/// to helpers here, the implementing types define only the actual decode/encode logic.
/// The property `wrappedValue` has to be defined there as well, even though the `subscript` will be used instead.
public protocol CDStoredPropertyWrapper {
    associatedtype EnclosingType: NSManagedObject
    associatedtype RawValue
    associatedtype DecodedValue

    var rawKeyPath: ReferenceWritableKeyPath<EnclosingType, RawValue> { get }

    static func decode(_ rawValue: RawValue) -> DecodedValue
    static func encode(_ newValue: DecodedValue) -> RawValue
}

extension CDStoredPropertyWrapper {

    /// Helper to extract & decode the `rawValue` based on keypaths.
    /// The actual decoding is delegated back to the implementing type.
    public static func decode(
        instance: EnclosingType,
        storageKeyPath: ReferenceWritableKeyPath<EnclosingType, Self>
    ) -> DecodedValue {
        let rawValueKeyPath = instance[keyPath: storageKeyPath].rawKeyPath
        let rawValue = instance[keyPath: rawValueKeyPath]
        return Self.decode(rawValue)
    }

    /// Helper to encode & assign the `newValue` based on keypaths.
    /// The actual encoding is delegated back to the implementing type.
    public static func encode(
        _ newValue: DecodedValue,
        instance: EnclosingType,
        storageKeyPath: ReferenceWritableKeyPath<EnclosingType, Self>
    ) {
        let rawValueKeyPath = instance[keyPath: storageKeyPath].rawKeyPath
        instance[keyPath: rawValueKeyPath] = Self.encode(newValue)
    }
}

// MARK: - CDStoredWithDefaultPropertyWrapper

/// Helper protocol to extract some boilerplate code required for property wrappers
/// that store their wrapped value in a private @NSManaged property.
/// The storing property's type could be either `RawValue` or `RawValue?`.
///
/// The implementing types are property wrappers. They use a specific static `subscript` to get/set the
/// wrapped value based on the provided `rawKeypath`. The `subscript` must be defined in
/// the implementing type, otherwise it's not recognized in runtime. Handling the keypaths is extracted
/// to helpers here, the implementing types define only the actual decode/encode logic.
/// The property `wrappedValue` has to be defined there as well, even though the `subscript` will be used instead.
public protocol CDStoredWithDefaultPropertyWrapper {
    associatedtype EnclosingType: NSManagedObject
    associatedtype RawValue
    associatedtype DecodedValue

    var rawKeyPath: AnyKeyPath { get }
    var defaultValue: DecodedValue { get }

    static func decode(_ rawValue: RawValue?) -> DecodedValue?
    static func encode(_ newValue: DecodedValue) -> RawValue
}

extension CDStoredWithDefaultPropertyWrapper {
    private typealias RawKeyPath = ReferenceWritableKeyPath<EnclosingType, RawValue>
    private typealias OptionalRawKeyPath = ReferenceWritableKeyPath<EnclosingType, RawValue?>

    /// Helper to extract & decode the `rawValue` based on keypaths.
    /// The actual decoding is delegated back to the implementing type.
    public static func decode(
        instance: EnclosingType,
        storageKeyPath: ReferenceWritableKeyPath<EnclosingType, Self>
    ) -> DecodedValue {
        let wrapper = instance[keyPath: storageKeyPath]
        let rawKeyPath = wrapper.rawKeyPath
        let defaultValue = wrapper.defaultValue

        if let rawKeyPath = rawKeyPath as? RawKeyPath {
            let rawValue = instance[keyPath: rawKeyPath]
            return Self.decode(rawValue) ?? defaultValue
        }
        if let rawKeyPath = rawKeyPath as? OptionalRawKeyPath {
            let rawValue = instance[keyPath: rawKeyPath]
            return Self.decode(rawValue) ?? defaultValue
        }
        return defaultValue
    }

    /// Helper to encode & assign the `newValue` based on keypaths.
    /// The actual encoding is delegated back to the implementing type.
    public static func encode(
        _ newValue: DecodedValue,
        instance: EnclosingType,
        storageKeyPath: ReferenceWritableKeyPath<EnclosingType, Self>
    ) {
        let wrapper = instance[keyPath: storageKeyPath]
        let rawKeyPath = wrapper.rawKeyPath

        if let rawKeyPath = rawKeyPath as? RawKeyPath {
            instance[keyPath: rawKeyPath] = Self.encode(newValue)
        }
        if let rawKeyPath = rawKeyPath as? OptionalRawKeyPath {
            instance[keyPath: rawKeyPath] = Self.encode(newValue)
        }
    }
}

// MARK: - CDStoredContainer

/// This allows for each property wrapper typealiased inside it to omit the root of the keypath.
/// E.g.: `@StoredEnum(\CDSubAssignmentSubmission.latePolicyStatusRaw) public var ...`
/// becomes `@StoredEnum(\.latePolicyStatusRaw) public var ...`
public protocol CDStoredContainer: NSManagedObject { }

extension NSManagedObject: CDStoredContainer {}
