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
    
    

@testable import TooLegit
import XCTest
import SoAutomated
import SoLazy

extension ContextID {
    static func validURL(_ context: Context) -> URL {
        let baseURL = URL(string: "https://mobiledev.instructure.com")!
        let url: URL
        switch context {
        case .course:
            url = baseURL/"courses/1/assignments"
        case .account:
            url = baseURL/"accounts/1/foo/bar"
        case .group:
            url = baseURL/"groups/2/assignments"
        case .user:
            url = baseURL/"users/3/files"
        }
        return url
    }

    static func validPath(_ context: Context) -> Path {
        return validURL(context).path
    }

    static func validCanvasContext(_ context: Context) -> String {
        let canvasContext: String
        switch context {
        case .course:
            canvasContext = "course_1"
        case .account:
            canvasContext = "account_1"
        case .group:
            canvasContext = "group_2"
        case .user:
            canvasContext = "user_3"
        }
        return canvasContext
    }

    func isA(_ context: Context, withID id: String) -> Bool {
        return self.context == context && self.id == id
    }
}

class ContextIDTests: XCTestCase {
    func testCreatingAContextIDFromAURL_setsTheCorrectContext() {
        XCTAssert(ContextID(url: ContextID.validURL(.course))?.context == .course, "it has a Course context")
        XCTAssert(ContextID(url: ContextID.validURL(.group))?.context == .group, "it has a Group context")
        XCTAssert(ContextID(url: ContextID.validURL(.user))?.context == .user, "it has a User context")
        XCTAssert(ContextID(url: ContextID.validURL(.account))?.context == .account, "it has an Account context")
    }

    func testCreatingAContextIDFromAURL_setsTheCorrectID() {
        XCTAssertEqual("1", ContextID(url: ContextID.validURL(.course))?.id, "it has the course id")
        XCTAssertEqual("2", ContextID(url: ContextID.validURL(.group))?.id, "it has the group id")
        XCTAssertEqual("1", ContextID(url: ContextID.validURL(.account))?.id, "it has the account id")
        XCTAssertEqual("3", ContextID(url: ContextID.validURL(.user))?.id, "it has the user id")
    }

    func testCreatingAContextIDFromaAPath_setsTheCorrectContext() {
        XCTAssert(ContextID(path: ContextID.validPath(.course))?.context == .course, "it has a Course context")
        XCTAssert(ContextID(path: ContextID.validPath(.group))?.context == .group, "it has a Group context")
        XCTAssert(ContextID(path: ContextID.validPath(.user))?.context == .user, "it has a User context")
        XCTAssert(ContextID(path: ContextID.validPath(.account))?.context == .account, "it has an Account context")
    }

    func testCreatingAContextIDFromAPath_setsTheCorrectID() {
        XCTAssertEqual("1", ContextID(path: ContextID.validPath(.course))?.id, "it has the course id")
        XCTAssertEqual("2", ContextID(path: ContextID.validPath(.group))?.id, "it has the group id")
        XCTAssertEqual("1", ContextID(path: ContextID.validPath(.account))?.id, "it has the account id")
        XCTAssertEqual("3", ContextID(path: ContextID.validPath(.user))?.id, "it has the user id")
    }

    func testCreatingAContextIDFromACanvasContext_setsTheCorrectContext() {
        XCTAssert(ContextID(canvasContext: ContextID.validCanvasContext(.course))?.context == .course, "it has a Course context")
        XCTAssert(ContextID(canvasContext: ContextID.validCanvasContext(.group))?.context == .group, "it has a Group context")
        XCTAssert(ContextID(canvasContext: ContextID.validCanvasContext(.user))?.context == .user, "it has a User context")
        XCTAssert(ContextID(canvasContext: ContextID.validCanvasContext(.account))?.context == .account, "it has an Account context")
    }

    func testCreatingAContextIDFromACanvasContext_setsTheCorrectID() {
        XCTAssertEqual("1", ContextID(canvasContext: ContextID.validCanvasContext(.course))?.id, "it has the course id")
        XCTAssertEqual("2", ContextID(canvasContext: ContextID.validCanvasContext(.group))?.id, "it has the group id")
        XCTAssertEqual("1", ContextID(canvasContext: ContextID.validCanvasContext(.account))?.id, "it has the account id")
        XCTAssertEqual("3", ContextID(canvasContext: ContextID.validCanvasContext(.user))?.id, "it has the user id")
    }

    func testCreatingAContextIDFromAURL_whenTheURLIsInvalid() {
        let contextID = ContextID(url: URL(string: "http://google.com")!)
        XCTAssertNil(contextID, "it should be nil")
    }

    func testCreatingAContextIDFromAPath_whenThePathIsInvalid() {
        let contextID = ContextID(path: "/invalid/path")
        XCTAssertNil(contextID, "it should be nil")
    }

    func testCreatingAContextIDFromACanvasContext_whenTheContextIsInvalid() {
        let contextID = ContextID(canvasContext: "not_a_thing_123")
        XCTAssertNil(contextID, "it should be nil")
    }

    func testCanvasContextID() {
        XCTAssertEqual("course_123", ContextID(id: "123", context: .course).canvasContextID)
        XCTAssertEqual("group_333", ContextID(id: "333", context: .group).canvasContextID)
        XCTAssertEqual("user_123", ContextID(id: "123", context: .user).canvasContextID)
        XCTAssertEqual("account_5912", ContextID(id: "5912", context: .account).canvasContextID)
    }

    func testAPIPath() {
        XCTAssertEqual("api/v1/courses/123", ContextID(id: "123", context: .course).apiPath)
        XCTAssertEqual("api/v1/groups/333", ContextID(id: "333", context: .group).apiPath)
        XCTAssertEqual("api/v1/users/123", ContextID(id: "123", context: .user).apiPath)
        XCTAssertEqual("api/v1/accounts/5912", ContextID(id: "5912", context: .account).apiPath)
    }

    func testHTMLPath() {
        XCTAssertEqual("courses/123", ContextID(id: "123", context: .course).htmlPath)
        XCTAssertEqual("groups/333", ContextID(id: "333", context: .group).htmlPath)
        XCTAssertEqual("users/123", ContextID(id: "123", context: .user).htmlPath)
        XCTAssertEqual("accounts/5912", ContextID(id: "5912", context: .account).htmlPath)
    }

    func testDescription() {
        XCTAssertEqual("course_123", ContextID(id: "123", context: .course).description)
        XCTAssertEqual("group_333", ContextID(id: "333", context: .group).description)
        XCTAssertEqual("user_123", ContextID(id: "123", context: .user).description)
        XCTAssertEqual("account_5912", ContextID(id: "5912", context: .account).description)
    }

    func testHashValue_isUniquePerContext() {
        let id = "1"
        let course = ContextID(id: id, context: .course)
        let group = ContextID(id: id, context: .group)
        let user = ContextID(id: id, context: .user)
        let account = ContextID(id: id, context: .account)

        let hashValues = Set([course, group, user, account].map { $0.hashValue })

        XCTAssertEqual(4, hashValues.count)
    }

    func testHashValue_isUniquePerID() {
        let one = ContextID(id: "1", context: .course)
        let two = ContextID(id: "2", context: .course)
        XCTAssertNotEqual(one.hashValue, two.hashValue)
    }

    func testEquatable_whenTheyHaveTheSameIDAndContext() {
        let one = ContextID(id: "1", context: .course)
        let two = ContextID(id: "1", context: .course)
        XCTAssert(one == two, "they are equal")
    }

    func testEquatable_whenTheyHaveDifferentIDs() {
        let one = ContextID(id: "1", context: .course)
        let two = ContextID(id: "2", context: .course)
        XCTAssertFalse(one == two, "they are not equal")
    }

    func testEquatable_whenTheyHaveDifferentContexts() {
        let one = ContextID(id: "1", context: .course)
        let two = ContextID(id: "1", context: .account)
        XCTAssertFalse(one == two, "they are not equal")
    }

    // MARK: Helpers

    fileprivate func validContextID(url: URL) -> ContextID {
        var contextID: ContextID!
        contextID = ContextID(url: url)
        if contextID == nil {
            XCTFail("contextID should not be nil")
        }
        return contextID
    }

    fileprivate func validContextID(path: String) -> ContextID {
        var contextID: ContextID!
        contextID = ContextID(path: path)
        if contextID == nil {
            XCTFail("contextID should not be nil")
        }
        return contextID
    }

    fileprivate func validContextID(canvasContext: String) -> ContextID {
        var contextID: ContextID!
        contextID = ContextID(canvasContext: canvasContext)
        if contextID == nil {
            XCTFail("contextID should not be nil")
        }
        return contextID
    }
}
