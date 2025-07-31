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
        return try? NSKeyedArchiver.archivedData(withRootObject: Array(stringSet) as NSArray, requiringSecureCoding: true)
    }

    // Transforms NSData back to Set<String>
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? Data else { return nil }
        do {
            let array = try NSKeyedUnarchiver.unarchivedObject(ofClass: NSArray.self, from: data)
            return Set(array as? [String] ?? [])
        } catch {
            print("Error unarchiving data: \(error)")
            return Set<String>()
        }
    }

    /// Registers the transformer.
    public static func register() {
        let transformer = StringSetValueTransformer()
        ValueTransformer.setValueTransformer(transformer, forName: name)
    }
}
