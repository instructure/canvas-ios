//
// Copyright (C) 2016-present Instructure, Inc.
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

class ContextModelTests: XCTestCase {
    func testExpandTildeID() {
        XCTAssertEqual(ContextModel.expandTildeID("1~1"), "10000000000001")
        XCTAssertEqual(ContextModel.expandTildeID("123456789~123456789"), "1234567890000123456789")
        XCTAssertEqual(ContextModel.expandTildeID("1~z"), "1~z")
        XCTAssertEqual(ContextModel.expandTildeID("1~1~"), "1~1~")
        XCTAssertEqual(ContextModel.expandTildeID("12"), "12")
        XCTAssertEqual(ContextModel.expandTildeID("self"), "self")
    }

    func testCurrentUser() {
        XCTAssertEqual(ContextModel.currentUser, ContextModel(.user, id: "self"))
    }

    func testInitContextTypeId() {
        let context = ContextModel(.course, id: "5")
        XCTAssertEqual(context.contextType, .course)
        XCTAssertEqual(context.id, "5")
    }

    func testInitContextID() {
        XCTAssertEqual(ContextModel(canvasContextID: "group_42"), ContextModel(.group, id: "42"))

        XCTAssertNil(ContextModel(canvasContextID: "invalid"))
        XCTAssertNil(ContextModel(canvasContextID: "invalid_1"))
    }

    func testInitPath() {
        XCTAssertEqual(ContextModel(path: "groups/42"), ContextModel(.group, id: "42"))
        XCTAssertEqual(ContextModel(path: "/api/v1/users/4"), ContextModel(.user, id: "4"))

        XCTAssertNil(ContextModel(path: "invalid"))
        XCTAssertNil(ContextModel(path: "invalid/1"))
        XCTAssertNil(ContextModel(path: "/api/v1/invalid/1"))
    }

    func testInitUrl() {
        XCTAssertEqual(ContextModel(url: URL(string: "api/v1/accounts/self")!), ContextModel(.account, id: "self"))
        XCTAssertNil(ContextModel(url: URL(string: "/api/v1/")!))
    }
}
