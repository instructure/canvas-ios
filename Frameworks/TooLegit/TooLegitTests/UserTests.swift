//
//  UserTests.swift
//  TooLegit
//
//  Created by Nathan Armstrong on 1/19/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import XCTest
import TooLegit
import SoAutomated

class SessionUserTests: XCTestCase {
    func testCreateUser() {
        let user = SessionUser(id: "2", name: "John", loginID: nil, sortableName: "john", email: nil, avatarURL: nil)

        XCTAssertEqual("2", user.id)
        XCTAssertNil(user.loginID)
        XCTAssertEqual("John", user.name)
        XCTAssertEqual("john", user.sortableName)
        XCTAssertNil(user.email)
        XCTAssertNil(user.avatarURL)
    }

    func testCreateUserWithAvatarLoginIDAndEmail() {
        let avatarURL = NSURL(string: "http://ibm.com")!
        let user = SessionUser(id: "2", name: "Jane", loginID: "user", sortableName: "jane", email: "jane@user.com", avatarURL: avatarURL)

        XCTAssertEqual("2", user.id)
        XCTAssertEqual("user", user.loginID)
        XCTAssertEqual("Jane", user.name)
        XCTAssertEqual("jane", user.sortableName)
        XCTAssertEqual("jane@user.com", user.email)
        XCTAssertEqual("http://ibm.com", user.avatarURL?.absoluteString)
    }

    func testFromJSONSucceeds() {
        let json = [
            "id": "2",
            "name": "Anakin Skywalker",
            "sortable_name": "ani",
        ]
        let user = SessionUser.fromJSON(json)

        XCTAssertNotNil(user)
        XCTAssertEqual("2", user?.id)
        XCTAssertEqual("Anakin Skywalker", user?.name)
        XCTAssertEqual("ani", user?.sortableName)
    }

    func testJSONDictionary() {
        let user = SessionUser(id: "2", name: "Anakin Skywalker", loginID: "askywalker", sortableName: "ani", email: "vader@gmail.com", avatarURL: nil)
        let json = user.JSONDictionary()

        if let
            id = json["id"] as? String,
            loginID = json["login_id"] as? String,
            name = json["name"] as? String,
            sortableName = json["sortable_name"] as? String,
            email = json["primary_email"] as? String
        {
            XCTAssertEqual("2", id)
            XCTAssertEqual("askywalker", loginID)
            XCTAssertEqual("Anakin Skywalker", name)
            XCTAssertEqual("ani", sortableName)
            XCTAssertEqual("vader@gmail.com", email)
        } else {
            XCTFail("dictionary is incorrect")
            return
        }
    }

    func testSessionUser_getAvatarImage_whenAvatarURLIsNil_completesWithError() {
        let user = SessionUser(id: "1", name: "John", loginID: nil, sortableName: nil, email: nil, avatarURL: nil)
        let expectation = expectationWithDescription("get avatar image")
        user.getAvatarImage { image, error in
            XCTAssertNil(image)
            XCTAssertNotNil(error)
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(1, handler: nil)
    }

    func testSessionUser_getAvatarImage_whenAvatarURLIsNotNil_completesWithImage() {
        let user = SessionUser(id: "1", name: "John", loginID: nil, sortableName: nil, email: nil, avatarURL: NSURL.image)
        let expectation = expectationWithDescription("get avatar image")
        user.getAvatarImage { image, error in
            XCTAssertNotNil(image)
            XCTAssertNil(error)
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(1, handler: nil)
    }

}
