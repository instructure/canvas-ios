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

    func testMapping() {
        let discussion = ModuleItemType.discussion("")
        XCTAssertEqual(discussion.assetType, .discussion)

        let assignement = ModuleItemType.assignment("")
        XCTAssertEqual(assignement.assetType, .assignment)

        let quiz = ModuleItemType.quiz("")
        XCTAssertEqual(quiz.assetType, .quiz)

        let externalURL = ModuleItemType.externalURL(URL(string: "/foo")!)
        XCTAssertEqual(externalURL.assetType, .moduleItem)

        let externalTool = ModuleItemType.externalTool("", URL(string: "/foo")!)
        XCTAssertEqual(externalTool.assetType, .externalTool)

        let page = ModuleItemType.page("")
        XCTAssertEqual(page.assetType, .page)

        let subHeader = ModuleItemType.subHeader
        XCTAssertEqual(subHeader.assetType, .moduleItem)
    }
}
