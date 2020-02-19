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
import PactConsumerSwift

protocol PactCaseEncodable: PactEncodable, RawRepresentable, CaseIterable where RawValue == String { }

extension PactCaseEncodable {
    static func escapeStringAsRegex(_ string: String) -> String {
        (string.map { char in
            switch char {
            case "\t": return "\\t"
            case "\u{000C}": return "\\f"
            case "\u{000B}": return "\\v"
            case "\n": return "\\n"
            case "\r": return "\\r"
            case _ where "[]{}()|-*.\\?+^$ #".contains(char):
                return "\\\(char)"
            default:
                return "\(char)"
            }
        }).joined()
    }

    func pactEncode(to encoder: PactEncoder) throws {
        let enumCases = Self.allCases.map {
            Self.escapeStringAsRegex($0.rawValue)
        }
        let regex = enumCases.joined(separator: "|")
        try encoder.encode(rawValue, matching: regex)
    }
}
