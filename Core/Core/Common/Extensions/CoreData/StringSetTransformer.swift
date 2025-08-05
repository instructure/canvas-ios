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

@objc(StringSetValueTransformer)
final class StringSetValueTransformer: ValueTransformer {
    static let name = NSValueTransformerName(rawValue: String(describing: StringSetValueTransformer.self))

    // Transforms a Set<String> to NSData
    override func transformedValue(_ value: Any?) -> Any? {
        guard let stringSet = value as? Set<String> else { return nil }
        let array = Array(stringSet)

        let archiver = NSKeyedArchiver(requiringSecureCoding: true)
        archiver.encode(array, forKey: NSKeyedArchiveRootObjectKey)
        return archiver.encodedData
    }

    // Transforms NSData back to Set<String>
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? Data else { return nil }

        // swiftlint:disable:next force_try
        let unarchiver = try! NSKeyedUnarchiver(forReadingFrom: data)
        unarchiver.decodingFailurePolicy = .setErrorAndReturn

        let allowedClasses = [NSArray.self, NSString.self]
        allowedClasses.forEach { unarchiver.setClass($0, forClassName: NSStringFromClass($0)) }

        guard let array = unarchiver.decodeObject(of: [NSArray.self, NSString.self], forKey: NSKeyedArchiveRootObjectKey) as? [String] else {
            return Set<String>()
        }

        return Set(array)
    }

    public static func register() {
        let transformer = StringSetValueTransformer()
        ValueTransformer.setValueTransformer(transformer, forName: name)
    }
}
