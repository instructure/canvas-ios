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
        let fixture = ModuleItemType.file("1")
        let data = try! encoder.encode(fixture)
        let type = try! decoder.decode(ModuleItemType.self, from: data)
        XCTAssertEqual(type, .file("1"))
    }

    func testCodablePage() {
        let fixture = ModuleItemType.page("my-page-title")
        let data = try! encoder.encode(fixture)
        let type = try! decoder.decode(ModuleItemType.self, from: data)
        XCTAssertEqual(type, .page("my-page-title"))
    }

    func testCodableDiscussion() {
        let fixture = ModuleItemType.discussion("1")
        let data = try! encoder.encode(fixture)
        let type = try! decoder.decode(ModuleItemType.self, from: data)
        XCTAssertEqual(type, .discussion("1"))
    }

    func testCodableAssignment() {
        let fixture = ModuleItemType.assignment("1")
        let data = try! encoder.encode(fixture)
        let type = try! decoder.decode(ModuleItemType.self, from: data)
        XCTAssertEqual(type, .assignment("1"))
    }

    func testCodableQuiz() {
        let fixture = ModuleItemType.quiz("1")
        let data = try! encoder.encode(fixture)
        let type = try! decoder.decode(ModuleItemType.self, from: data)
        XCTAssertEqual(type, .quiz("1"))
    }

    func testCodableSubHeader() {
        let fixture = ModuleItemType.subHeader
        let data = try! encoder.encode(fixture)
        let type = try! decoder.decode(ModuleItemType.self, from: data)
        XCTAssertEqual(type, .subHeader)
    }

    func testCodableExternalURL() {
        let url = "https://www.example.com/externalurl"
        let fixture = ModuleItemType.externalURL(URL(string: "https://www.example.com/externalurl")!)
        let data = try! encoder.encode(fixture)
        let type = try! decoder.decode(ModuleItemType.self, from: data)
        XCTAssertEqual(type, .externalURL(URL(string: url)!))
    }

    func testCodableExternalTool() {
        let url = "https://www.example.com/externalurl"
        let fixture = ModuleItemType.externalTool("1", URL(string: "https://www.example.com/externalurl")!)
        let data = try! encoder.encode(fixture)
        let type = try! decoder.decode(ModuleItemType.self, from: data)
        XCTAssertEqual(type, .externalTool("1", URL(string: url)!))
    }
}
