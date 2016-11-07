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
    static func validURL(context: Context) -> NSURL {
        let baseURL = NSURL(string: "https://mobiledev.instructure.com")!
        let url: NSURL
        switch context {
        case .Course:
            url = baseURL/"courses/1/assignments"
        case .Account:
            url = baseURL/"accounts/1/foo/bar"
        case .Group:
            url = baseURL/"groups/2/assignments"
        case .User:
            url = baseURL/"users/3/files"
        }
        return url
    }

    static func validPath(context: Context) -> Path {
        return validURL(context).path!
    }

    static func validCanvasContext(context: Context) -> String {
        let canvasContext: String
        switch context {
        case .Course:
            canvasContext = "course_1"
        case .Account:
            canvasContext = "account_1"
        case .Group:
            canvasContext = "group_2"
        case .User:
            canvasContext = "user_3"
        }
        return canvasContext
    }

    func isA(context: Context, withID id: String) -> Bool {
        return self.context == context && self.id == id
    }
}

class ContextIDTests: XCTestCase {
    func testCreatingAContextIDFromAURL_setsTheCorrectContext() {
        XCTAssert(ContextID(url: ContextID.validURL(.Course))?.context == .Course, "it has a Course context")
        XCTAssert(ContextID(url: ContextID.validURL(.Group))?.context == .Group, "it has a Group context")
        XCTAssert(ContextID(url: ContextID.validURL(.User))?.context == .User, "it has a User context")
        XCTAssert(ContextID(url: ContextID.validURL(.Account))?.context == .Account, "it has an Account context")
    }

    func testCreatingAContextIDFromAURL_setsTheCorrectID() {
        XCTAssertEqual("1", ContextID(url: ContextID.validURL(.Course))?.id, "it has the course id")
        XCTAssertEqual("2", ContextID(url: ContextID.validURL(.Group))?.id, "it has the group id")
        XCTAssertEqual("1", ContextID(url: ContextID.validURL(.Account))?.id, "it has the account id")
        XCTAssertEqual("3", ContextID(url: ContextID.validURL(.User))?.id, "it has the user id")
    }

    func testCreatingAContextIDFromaAPath_setsTheCorrectContext() {
        XCTAssert(ContextID(path: ContextID.validPath(.Course))?.context == .Course, "it has a Course context")
        XCTAssert(ContextID(path: ContextID.validPath(.Group))?.context == .Group, "it has a Group context")
        XCTAssert(ContextID(path: ContextID.validPath(.User))?.context == .User, "it has a User context")
        XCTAssert(ContextID(path: ContextID.validPath(.Account))?.context == .Account, "it has an Account context")
    }

    func testCreatingAContextIDFromAPath_setsTheCorrectID() {
        XCTAssertEqual("1", ContextID(path: ContextID.validPath(.Course))?.id, "it has the course id")
        XCTAssertEqual("2", ContextID(path: ContextID.validPath(.Group))?.id, "it has the group id")
        XCTAssertEqual("1", ContextID(path: ContextID.validPath(.Account))?.id, "it has the account id")
        XCTAssertEqual("3", ContextID(path: ContextID.validPath(.User))?.id, "it has the user id")
    }

    func testCreatingAContextIDFromACanvasContext_setsTheCorrectContext() {
        XCTAssert(ContextID(canvasContext: ContextID.validCanvasContext(.Course))?.context == .Course, "it has a Course context")
        XCTAssert(ContextID(canvasContext: ContextID.validCanvasContext(.Group))?.context == .Group, "it has a Group context")
        XCTAssert(ContextID(canvasContext: ContextID.validCanvasContext(.User))?.context == .User, "it has a User context")
        XCTAssert(ContextID(canvasContext: ContextID.validCanvasContext(.Account))?.context == .Account, "it has an Account context")
    }

    func testCreatingAContextIDFromACanvasContext_setsTheCorrectID() {
        XCTAssertEqual("1", ContextID(canvasContext: ContextID.validCanvasContext(.Course))?.id, "it has the course id")
        XCTAssertEqual("2", ContextID(canvasContext: ContextID.validCanvasContext(.Group))?.id, "it has the group id")
        XCTAssertEqual("1", ContextID(canvasContext: ContextID.validCanvasContext(.Account))?.id, "it has the account id")
        XCTAssertEqual("3", ContextID(canvasContext: ContextID.validCanvasContext(.User))?.id, "it has the user id")
    }

    func testCreatingAContextIDFromAURL_whenTheURLIsInvalid() {
        let contextID = ContextID(url: NSURL(string: "http://google.com")!)
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
        XCTAssertEqual("course_123", ContextID(id: "123", context: .Course).canvasContextID)
        XCTAssertEqual("group_333", ContextID(id: "333", context: .Group).canvasContextID)
        XCTAssertEqual("user_123", ContextID(id: "123", context: .User).canvasContextID)
        XCTAssertEqual("account_5912", ContextID(id: "5912", context: .Account).canvasContextID)
    }

    func testAPIPath() {
        XCTAssertEqual("api/v1/courses/123", ContextID(id: "123", context: .Course).apiPath)
        XCTAssertEqual("api/v1/groups/333", ContextID(id: "333", context: .Group).apiPath)
        XCTAssertEqual("api/v1/users/123", ContextID(id: "123", context: .User).apiPath)
        XCTAssertEqual("api/v1/accounts/5912", ContextID(id: "5912", context: .Account).apiPath)
    }

    func testHTMLPath() {
        XCTAssertEqual("courses/123", ContextID(id: "123", context: .Course).htmlPath)
        XCTAssertEqual("groups/333", ContextID(id: "333", context: .Group).htmlPath)
        XCTAssertEqual("users/123", ContextID(id: "123", context: .User).htmlPath)
        XCTAssertEqual("accounts/5912", ContextID(id: "5912", context: .Account).htmlPath)
    }

    func testDescription() {
        XCTAssertEqual("course_123", ContextID(id: "123", context: .Course).description)
        XCTAssertEqual("group_333", ContextID(id: "333", context: .Group).description)
        XCTAssertEqual("user_123", ContextID(id: "123", context: .User).description)
        XCTAssertEqual("account_5912", ContextID(id: "5912", context: .Account).description)
    }

    func testHashValue_isUniquePerContext() {
        let id = "1"
        let course = ContextID(id: id, context: .Course)
        let group = ContextID(id: id, context: .Group)
        let user = ContextID(id: id, context: .User)
        let account = ContextID(id: id, context: .Account)

        let hashValues = Set([course, group, user, account].map { $0.hashValue })

        XCTAssertEqual(4, hashValues.count)
    }

    func testHashValue_isUniquePerID() {
        let one = ContextID(id: "1", context: .Course)
        let two = ContextID(id: "2", context: .Course)
        XCTAssertNotEqual(one.hashValue, two.hashValue)
    }

    func testEquatable_whenTheyHaveTheSameIDAndContext() {
        let one = ContextID(id: "1", context: .Course)
        let two = ContextID(id: "1", context: .Course)
        XCTAssert(one == two, "they are equal")
    }

    func testEquatable_whenTheyHaveDifferentIDs() {
        let one = ContextID(id: "1", context: .Course)
        let two = ContextID(id: "2", context: .Course)
        XCTAssertFalse(one == two, "they are not equal")
    }

    func testEquatable_whenTheyHaveDifferentContexts() {
        let one = ContextID(id: "1", context: .Course)
        let two = ContextID(id: "1", context: .Account)
        XCTAssertFalse(one == two, "they are not equal")
    }

    // MARK: Helpers

    private func validContextID(url url: NSURL) -> ContextID {
        var contextID: ContextID!
        contextID = ContextID(url: url)
        if contextID == nil {
            XCTFail("contextID should not be nil")
        }
        return contextID
    }

    private func validContextID(path path: String) -> ContextID {
        var contextID: ContextID!
        contextID = ContextID(path: path)
        if contextID == nil {
            XCTFail("contextID should not be nil")
        }
        return contextID
    }

    private func validContextID(canvasContext canvasContext: String) -> ContextID {
        var contextID: ContextID!
        contextID = ContextID(canvasContext: canvasContext)
        if contextID == nil {
            XCTFail("contextID should not be nil")
        }
        return contextID
    }
}
