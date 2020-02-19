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

// only verifies shapes match
protocol PactShapeEncodable: PactEncodable { }

extension PactShapeEncodable {
    func pactEncode(to encoder: PactEncoder) throws {
        try encoder.encodeAndFix(self, fixup: fixup)
    }

    func fixup(encoder: PactEncoder, result: inout NSObject?) throws {
        guard let value = result else {
            let context = EncodingError.Context(
                codingPath: encoder.codingPath,
                debugDescription: "no json found!"
            )
            throw EncodingError.invalidValue(self, context)
        }

        result = Matcher.somethingLike(value) as NSObject
    }
}
