//
// Copyright (C) 2019-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import Foundation
@testable import Core
import XCTest
import TestsFoundation

class APIModuleItemTests: XCTestCase {
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()

    func testCodableFile() {
        let fixture = APIModuleItem.make(["type": "File", "content_id": "1"])
        let data = try! encoder.encode(fixture)
        let item = try! decoder.decode(APIModuleItem.self, from: data)
        XCTAssertEqual(item.content, .file("1"))
    }

    func testCodablePage() {
        let fixture = APIModuleItem.make(["type": "Page", "page_url": "my-page-title"])
        let data = try! encoder.encode(fixture)
        let item = try! decoder.decode(APIModuleItem.self, from: data)
        XCTAssertEqual(item.content, .page("my-page-title"))
    }

    func testCodableDiscussion() {
        let fixture = APIModuleItem.make(["type": "Discussion", "content_id": "1"])
        let data = try! encoder.encode(fixture)
        let item = try! decoder.decode(APIModuleItem.self, from: data)
        XCTAssertEqual(item.content, .discussion("1"))
    }

    func testCodableAssignment() {
        let fixture = APIModuleItem.make(["type": "Assignment", "content_id": "1"])
        let data = try! encoder.encode(fixture)
        let item = try! decoder.decode(APIModuleItem.self, from: data)
        XCTAssertEqual(item.content, .assignment("1"))
    }

    func testCodableQuiz() {
        let fixture = APIModuleItem.make(["type": "Quiz", "content_id": "1"])
        let data = try! encoder.encode(fixture)
        let item = try! decoder.decode(APIModuleItem.self, from: data)
        XCTAssertEqual(item.content, .quiz("1"))
    }

    func testCodableSubHeader() {
        let fixture = APIModuleItem.make(["type": "SubHeader", "content_id": "1"])
        let data = try! encoder.encode(fixture)
        let item = try! decoder.decode(APIModuleItem.self, from: data)
        XCTAssertEqual(item.content, .subHeader)
    }

    func testCodableExternalURL() {
        let url = "https://www.example.com/externalurl"
        let fixture = APIModuleItem.make(["type": "ExternalUrl", "external_url": "https://www.example.com/externalurl"])
        let data = try! encoder.encode(fixture)
        let item = try! decoder.decode(APIModuleItem.self, from: data)
        XCTAssertEqual(item.content, .externalURL(URL(string: url)!))
    }

    func testCodableExternalTool() {
        let url = "https://www.example.com/externalurl"
        let fixture = APIModuleItem.make(["type": "ExternalTool", "external_url": "https://www.example.com/externalurl", "content_id": "1"])
        let data = try! encoder.encode(fixture)
        let item = try! decoder.decode(APIModuleItem.self, from: data)
        XCTAssertEqual(item.content, .externalTool("1", URL(string: url)!))
    }
}
