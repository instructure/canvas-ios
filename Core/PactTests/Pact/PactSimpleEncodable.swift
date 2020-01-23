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

enum PactSimpleFieldHandling {
    case exact
    case matching(regex: String)
    case somethingLike
}

protocol PactSimpleEncodable: PactEncodable {
    /// Keys should be the JSON keys, which might not be the field names
    var pactFields: [String: PactSimpleFieldHandling] { get }
}
extension PactSimpleEncodable {
    func pactEncode(to encoder: PactEncoder) throws {
        try encoder.encodeAndFix(self, fixup: fixup)
    }

    func fixup(encoder: PactEncoder, result: inout NSObject?) throws {
        guard let dict = result as? NSMutableDictionary else {
            let context = EncodingError.Context(
                codingPath: encoder.codingPath,
                debugDescription: "the default PactEncodable.pactEncode can only deal with dictionary json"
            )
            throw EncodingError.invalidValue(self, context)
        }

        // fix up fields based on pact patterns
        let keys = Set((dict.allKeys as? [String])! + pactFields.keys)
        for key in keys {
            switch pactFields[key] {
            case .exact: ()
            case .matching(let regex):
                guard let old = dict[key] as? String else {
                    let context = EncodingError.Context(
                        codingPath: encoder.codingPath,
                        debugDescription: "non-string value found in regex field \(key)"
                    )
                    throw EncodingError.invalidValue(self, context)
                }
                dict[key] = Matcher.term(matcher: regex, generate: old)
            case .somethingLike, nil:
                if let old = dict[key] {
                    dict[key] = Matcher.somethingLike(old)
                } else {
                    dict[key] = NSNull()
                }
            }
        }
    }

}
