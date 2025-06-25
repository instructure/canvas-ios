//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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

import CryptoKit
import Foundation

extension String {
    public func populatePathWithParams(_ params: PageViewEventDictionary?) -> String? {
        guard let url = URL(string: self), params?.count ?? 0 > 0 else {
            return nil
        }
        var components = url.pathComponents
        let componentsCopy = components

        for (index, c) in componentsCopy.enumerated() {
            if c.hasPrefix(":") || c.hasPrefix("*"), let replacementVal = params?[String(c.dropFirst())] {
                components[index] = replacementVal.description
            }
        }
        return NSString.path(withComponents: components) as String
    }

    public func pruneApiVersionFromPath() -> String {
        let regex = "\\/{0,1}api\\/v\\d+"
        guard let range = self.range(of: regex, options: .regularExpression, range: nil, locale: nil) else {
            return self
        }
        let prefix = String(self[self.startIndex..<range.lowerBound])
        let suffix = String(self[range.upperBound..<self.endIndex])
        return prefix + suffix
    }

    public var removingXMLEscaping: String {
        let xmlChars = [
            "&lt;": "<",
            "&gt;": ">",
            "&amp;": "&",
            "&apos;": "'",
            "&quot;": "\""
        ]
        var result = self

        for (escaped, original) in xmlChars {
            result = result.replacingOccurrences(of: escaped, with: original, options: .caseInsensitive)
        }

        return result
    }

    public var containsNumber: Bool {
        return unicodeScalars.contains { char in
            CharacterSet.decimalDigits.contains(char)
        }
    }

    /// - returns: True if the receiver string only contains decimal digits or if the string is empty.
    public var containsOnlyNumbers: Bool {
        unicodeScalars.allSatisfy { CharacterSet.decimalDigits.contains($0) }
    }

    public var isNotEmpty: Bool {
        !isEmpty
    }
    /**
     Converts a `String` to a `Bool` value.
     Returns `false` if the `String` value does not contain any valid `Bool` representation. It uses `NSString`'s `boolValue` property which can convert nums, characters, strings to bool values.
     */
    public var boolValue: Bool {
        return (self as NSString).boolValue
    }

    public var nilIfEmpty: String? {
        self.isEmpty ? nil : self
    }

    public func trimmed() -> String {
        return trimmingCharacters(in: .whitespacesAndNewlines)
    }

    public func asFormat(for arguments: any CVarArg...) -> String {
        return String(format: self, arguments)
    }

    /// Returns a range that covers the whole string.
    public var nsRange: NSRange {
        NSRange(location: 0, length: count)
    }

    public func extractiFrames() -> [String] {
        // swiftlint:disable:next force_try
        let iframePattern = try! NSRegularExpression(
            pattern: "<iframe[\\s\\S]*?</iframe>"
        )

        return iframePattern
            .matches(in: self, range: nsRange)
            .compactMap {
                guard let stringRange = Range($0.range, in: self) else {
                    return nil
                }
                return String(self[stringRange])
            }
    }

    public func dataWithError(
        using encoding: String.Encoding,
        allowLossyConversion: Bool = false
    ) throws -> Data {
        guard let data = self.data(using: encoding, allowLossyConversion: allowLossyConversion) else {
            throw NSError.instructureError("Failed to convert string to data using encoding \(encoding).")
        }
        return data
    }

    /// - returns: A new string without the given prefix. If the string doesn't have the given prefix this method will return the unmodified string.
    public func deletingPrefix(_ prefix: String) -> String {
        guard hasPrefix(prefix) else { return self }
        return String(dropFirst(prefix.count))
    }

    public func sha256() -> String {
        let inputData = Data(utf8)
        let hashedData = SHA256.hash(data: inputData)
        return hashedData.map { String(format: "%02x", $0) }.joined()
    }

    public var isLocalizedNA: Bool {
        self == String(localized: "N/A", bundle: .core)
    }
}

public extension Array<String?> {
    func joined(separator: String = "") -> String {
        compactMap { $0 }.joined(separator: separator)
    }
}

extension ReferenceWritableKeyPath {
    var string: String {
        NSExpression(forKeyPath: self).keyPath
    }
}

extension String? {
    public var isNilOrEmpty: Bool {
        guard let self else {
            return true
        }
        return self.isEmpty
    }
}
