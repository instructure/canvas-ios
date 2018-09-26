//
// Copyright (C) 2018-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import XCTest
@testable import Core

class ListFormatterTests: XCTestCase {
    func testLocalizedStringAnd() {
        XCTAssertEqual(ListFormatter.localizedString(from: []), "")
        XCTAssertEqual(ListFormatter.localizedString(from: ["a"]), "a")
        XCTAssertEqual(ListFormatter.localizedString(from: ["a", "b"]), "a and b")
        XCTAssertEqual(ListFormatter.localizedString(from: ["a", "b", "c"]), "a, b, and c")
        XCTAssertEqual(ListFormatter.localizedString(from: ["a", "b", "c", "d"]), "a, b, c, and d")
    }

    func testLocalizedStringOr() {
        XCTAssertEqual(ListFormatter.localizedString(from: [], conjunction: .or), "")
        XCTAssertEqual(ListFormatter.localizedString(from: ["a"], conjunction: .or), "a")
        XCTAssertEqual(ListFormatter.localizedString(from: ["a", "b"], conjunction: .or), "a or b")
        XCTAssertEqual(ListFormatter.localizedString(from: ["a", "b", "c"], conjunction: .or), "a, b, or c")
        XCTAssertEqual(ListFormatter.localizedString(from: ["a", "b", "c", "d"], conjunction: .or), "a, b, c, or d")
    }
}
