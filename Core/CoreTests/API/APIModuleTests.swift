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

import Foundation
@testable import Core
import XCTest
import TestsFoundation

class APIModuleItemTests: XCTestCase {
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()

    func testCodableContent() {
        let file = try! decoder.decode(APIModuleItem.self, from: try! encoder.encode(APIModuleItem.make(content: .file("1"))))
        XCTAssertEqual(file.content, .file("1"))

        let subheader = try! decoder.decode(APIModuleItem.self, from: try! encoder.encode(APIModuleItem.make(content: .subHeader)))
        XCTAssertEqual(subheader.content, .subHeader)

        let nilCompleted = try! decoder.decode(APIModuleItem.self, from: try! encoder.encode(APIModuleItem.make(completion_requirement: .make(completed: nil))))
        XCTAssertNil(nilCompleted.completion_requirement?.completed)
    }

    func testDecodeNullIndent() {
        var json = try! JSONSerialization.jsonObject(with: try! encoder.encode(APIModuleItem.make()), options: []) as! [String: Any?]
        json["indent"] = nil
        let data = try! JSONSerialization.data(withJSONObject: json, options: [])
        let item = try! decoder.decode(APIModuleItem.self, from: data)
        XCTAssertEqual(item.indent, 0)
    }
}
