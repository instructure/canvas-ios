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

import SwiftUI

@available(iOS 13.0, *)
public enum Tag {
    /// Wrapper around LocalizedStringKey that provides access to the string
    public struct LocalizedString: ExpressibleByStringInterpolation {
        public let key: LocalizedStringKey
        public let string: String
        public init(stringLiteral value: String) {
            key = LocalizedStringKey(value)
            string = value
        }
        public init(stringInterpolation: StringInterpolation) {
            key = LocalizedStringKey(stringInterpolation: stringInterpolation.keyInterpolation)
            string = stringInterpolation.components.joined()
        }
        public struct StringInterpolation: StringInterpolationProtocol {
            public var keyInterpolation: LocalizedStringKey.StringInterpolation
            public var components: [String] = []

            public init(literalCapacity: Int, interpolationCount: Int) {
                keyInterpolation = .init(literalCapacity: literalCapacity, interpolationCount: interpolationCount)
                components.reserveCapacity(literalCapacity + interpolationCount)
            }
            public mutating func appendLiteral(_ literal: String) {
                keyInterpolation.appendLiteral(literal)
                components.append(literal)
            }
            public mutating func appendInterpolation(_ string: String) {
                keyInterpolation.appendInterpolation(string)
                components.append(string)
            }
            public mutating func appendInterpolation<Subject: ReferenceConvertible>(_ subject: Subject, formatter: Formatter? = nil) {
                keyInterpolation.appendInterpolation(subject, formatter: formatter)
                components.append(formatter?.string(for: subject as? NSObject) ?? "\(subject)")
            }
            public mutating func appendInterpolation<Subject: NSObject>(_ subject: Subject, formatter: Formatter? = nil) {
                keyInterpolation.appendInterpolation(subject, formatter: formatter)
                components.append(formatter?.string(for: subject) ?? "\(subject)")
            }
            public mutating func appendInterpolation<T: _FormatSpecifiable>(_ value: T) {
                keyInterpolation.appendInterpolation(value)
                components.append(String(format: value._specifier, value._arg))
            }
            public mutating func appendInterpolation<T: _FormatSpecifiable>(_ value: T, specifier: String) {
                keyInterpolation.appendInterpolation(value)
                components.append(String(format: specifier, value._arg))
            }
        }
        public typealias StringLiteralType = String
        public typealias ExtendedGraphemeClusterLiteralType = String
        public typealias UnicodeScalarLiteralType = String
    }

    // It's important that this is named "Text" so that the strings exporter will recognize it
    public struct Text: View {
        public let text: String
        public let contents: SwiftUI.Text
        public init(verbatim text: String) {
            contents = SwiftUI.Text(verbatim: text)
            self.text = text
        }

        @_disfavoredOverload
        public init<S: StringProtocol>(_ content: S) {
            self.init(verbatim: String(content))
        }

        public init(_ key: LocalizedString, tableName: String? = nil, bundle: Bundle? = nil, comment: StaticString? = nil) {
            contents = SwiftUI.Text(key.key, tableName: tableName, bundle: bundle, comment: comment)
            self.text = key.string
        }

        public var body: some View {
            contents.testID(.text, id: text)
        }
    }
}
