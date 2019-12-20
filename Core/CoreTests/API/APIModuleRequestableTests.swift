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

class APIModuleRequestableTests: XCTestCase {
    func testGetModulesRequest() {
        XCTAssertEqual(GetModulesRequest(courseID: "1").path, "courses/1/modules")
        XCTAssertEqual(GetModulesRequest(courseID: "1", include: [.items, .content_details], perPage: 10).queryItems, [
            URLQueryItem(name: "include[]", value: "items"),
            URLQueryItem(name: "include[]", value: "content_details"),
            URLQueryItem(name: "per_page", value: "10"),
        ])
    }

    func testGetModuleItemsRequest() {
        XCTAssertEqual(GetModuleItemsRequest(courseID: "1", moduleID: "2", include: []).path, "courses/1/modules/2/items")
        XCTAssertEqual(
            GetModuleItemsRequest(courseID: "1", moduleID: "2", include: [.content_details, .mastery_paths], perPage: 10).queryItems,
            [
                URLQueryItem(name: "include[]", value: "content_details"),
                URLQueryItem(name: "include[]", value: "mastery_paths"),
                URLQueryItem(name: "per_page", value: "10"),
            ]
        )
    }

    func testGetModuleItemSequenceRequest() {
        XCTAssertEqual(
            GetModuleItemSequenceRequest(courseID: "1", assetType: .moduleItem, assetID: "1").path,
            "courses/1/module_item_sequence"
        )
        XCTAssertEqual(
            GetModuleItemSequenceRequest(courseID: "1", assetType: .moduleItem, assetID: "1").queryItems,
            [
                URLQueryItem(name: "asset_type", value: GetModuleItemSequenceRequest.AssetType.moduleItem.rawValue),
                URLQueryItem(name: "asset_id", value: "1"),
            ]
        )
    }

    func testPostMarkModuleItemRead() {
        let request = PostMarkModuleItemRead(courseID: "1", moduleID: "2", moduleItemID: "3")
        XCTAssertEqual(request.path, "courses/1/modules/2/items/3/mark_read")
        XCTAssertEqual(request.method, .post)
    }
}
