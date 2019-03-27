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

class ModuleItemTypeTests: XCTestCase {
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()

    func testCodableFile() {
        let fixture = ModuleItemType.make(["type": "File", "content_id": "1"])
        let data = try! encoder.encode(fixture)
        let type = try! decoder.decode(ModuleItemType.self, from: data)
        XCTAssertEqual(type, .file("1"))
    }

    func testCodablePage() {
        let fixture = ModuleItemType.make(["type": "Page", "page_url": "my-page-title"])
        let data = try! encoder.encode(fixture)
        let type = try! decoder.decode(ModuleItemType.self, from: data)
        XCTAssertEqual(type, .page("my-page-title"))
    }

    func testCodableDiscussion() {
        let fixture = ModuleItemType.make(["type": "Discussion", "content_id": "1"])
        let data = try! encoder.encode(fixture)
        let type = try! decoder.decode(ModuleItemType.self, from: data)
        XCTAssertEqual(type, .discussion("1"))
    }

    func testCodableAssignment() {
        let fixture = ModuleItemType.make(["type": "Assignment", "content_id": "1"])
        let data = try! encoder.encode(fixture)
        let type = try! decoder.decode(ModuleItemType.self, from: data)
        XCTAssertEqual(type, .assignment("1"))
    }

    func testCodableQuiz() {
        let fixture = ModuleItemType.make(["type": "Quiz", "content_id": "1"])
        let data = try! encoder.encode(fixture)
        let type = try! decoder.decode(ModuleItemType.self, from: data)
        XCTAssertEqual(type, .quiz("1"))
    }

    func testCodableSubHeader() {
        let fixture = ModuleItemType.make(["type": "SubHeader", "content_id": "1"])
        let data = try! encoder.encode(fixture)
        let type = try! decoder.decode(ModuleItemType.self, from: data)
        XCTAssertEqual(type, .subHeader)
    }

    func testCodableExternalURL() {
        let url = "https://www.example.com/externalurl"
        let fixture = ModuleItemType.make(["type": "ExternalUrl", "external_url": "https://www.example.com/externalurl"])
        let data = try! encoder.encode(fixture)
        let type = try! decoder.decode(ModuleItemType.self, from: data)
        XCTAssertEqual(type, .externalURL(URL(string: url)!))
    }

    func testCodableExternalTool() {
        let url = "https://www.example.com/externalurl"
        let fixture = ModuleItemType.make(["type": "ExternalTool", "external_url": "https://www.example.com/externalurl", "content_id": "1"])
        let data = try! encoder.encode(fixture)
        let type = try! decoder.decode(ModuleItemType.self, from: data)
        XCTAssertEqual(type, .externalTool("1", URL(string: url)!))
    }

    func testEquatable() {
        XCTAssertEqual(ModuleItemType.assignment("1"), .assignment("1"))
        XCTAssertNotEqual(ModuleItemType.assignment("1"), .assignment("2"))
        XCTAssertNotEqual(ModuleItemType.file("1"), .subHeader)
        XCTAssertNotEqual(ModuleItemType.file("1"), .assignment("1"))
    }
}
