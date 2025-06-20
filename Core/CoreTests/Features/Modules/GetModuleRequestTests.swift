//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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

@testable import Core
import XCTest

class GetModuleRequestTests: XCTestCase {
    var req: GetModuleRequest!
    let courseID = "1"
    let moduleID = "2"

    override func setUp() {
        super.setUp()
        req = GetModuleRequest(courseID: courseID, moduleID: moduleID)
    }

    func testPath() {
        XCTAssertEqual(req.path, "courses/\(courseID)/modules/\(moduleID)")
    }

    func testQuery() {
        XCTAssertEqual(req.queryItems, [])

        req = GetModuleRequest(
            courseID: courseID,
            moduleID: moduleID,
            include: [.content_details, .items, .estimated_durations]
        )

        XCTAssertEqual(req.queryItems.count, 3)
        XCTAssertEqual(req.queryItems.contains(URLQueryItem(name: "include[]", value: "content_details")), true)
        XCTAssertEqual(req.queryItems.contains(URLQueryItem(name: "include[]", value: "items")), true)
        XCTAssertEqual(req.queryItems.contains(URLQueryItem(name: "include[]", value: "estimated_durations")), true)
    }

    func testQueryWithPerPage() {
        req = GetModuleRequest(
            courseID: courseID,
            moduleID: moduleID,
            include: [.items],
            perPage: 50
        )

        XCTAssertEqual(req.queryItems.count, 2)
        XCTAssertEqual(req.queryItems.contains(URLQueryItem(name: "include[]", value: "items")), true)
        XCTAssertEqual(req.queryItems.contains(URLQueryItem(name: "per_page", value: "50")), true)
    }

    func testInitWithDefaultParameters() {
        XCTAssertEqual(req.courseID, courseID)
        XCTAssertEqual(req.moduleID, moduleID)
        XCTAssertEqual(req.include, [])
        XCTAssertNil(req.perPage)
    }

    func testInitWithAllParameters() {
        let include: [GetModuleRequest.Include] = [.content_details, .items]
        let perPage = 25

        req = GetModuleRequest(
            courseID: courseID,
            moduleID: moduleID,
            include: include,
            perPage: perPage
        )

        XCTAssertEqual(req.courseID, courseID)
        XCTAssertEqual(req.moduleID, moduleID)
        XCTAssertEqual(req.include, include)
        XCTAssertEqual(req.perPage, perPage)
    }

    func testResponseType() {
        let responseType = type(of: req).Response.self
        XCTAssertTrue(responseType == APIModule.self)
    }
}
