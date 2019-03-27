//
// Copyright (C) 2019-present Instructure, Inc.
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

import Foundation
@testable import Core
import XCTest
import TestsFoundation

class APIModuleItemTests: XCTestCase {
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()

    func testCodableContent() {
        let file = try! decoder.decode(APIModuleItem.self, from: try! encoder.encode(APIModuleItem.make(["type": "File", "content_id": "1"])))
        XCTAssertEqual(file.content, .file("1"))
        let subheader = try! decoder.decode(APIModuleItem.self, from: try! encoder.encode(APIModuleItem.make(["type": "SubHeader", "content_id": "1"])))
        XCTAssertEqual(subheader.content, .subHeader)

    }
}
