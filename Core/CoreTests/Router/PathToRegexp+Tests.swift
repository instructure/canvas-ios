//
//  PathToRegexp+Tests.swift
//  CoreTests
//
//  Created by Matt Sessions on 8/15/18.
//  Copyright © 2018 Instructure, Inc. All rights reserved.
//

import XCTest
import Core

class PathToRegexpTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testCanMatchRoutes() {
        let path = "/courses/3/users/1"
        guard let regexp = pathToRegexp("/courses/:courseID/users/:userID") else { return XCTFail() }
        let numMatches = regexp.numberOfMatches(in: path, range: NSRange(location: 0, length: path.count))
        XCTAssertEqual(numMatches, 1)
    }

    func testCanExtractParams() {
        let route = "/courses/:courseID/assignments/:assignmentID"
        let path = "/courses/3/assignments/1"
        guard let regexp = pathToRegexp(route), let match = regexp.firstMatch(in: path, range: NSRange(location: 0, length: path.count)) else { return XCTFail() }

        let params = extractParamsFromPath(path, match: match, routePath: route)
        XCTAssertEqual(params["courseID"], "3")
        XCTAssertEqual(params["assignmentID"], "1")
    }

    func testSplatCharacter() {
        let route = "/:context/:contextID/files/folder/:subFolder*"
        let path = "/courses/1/files/folder/a/folder"

        guard let regexp = pathToRegexp(route), let match = regexp.firstMatch(in: path, range: NSRange(location: 0, length: path.count)) else { return XCTFail() }

        let params = extractParamsFromPath(path, match: match, routePath: route)
        XCTAssertEqual(params["context"], "courses")
        XCTAssertEqual(params["contextID"], "1")
        XCTAssertEqual(params["subFolder"], "a/folder")
    }

    func testCanExtractQueryParams() {
        let path = "/courses/1/quizzes/2?include[]=user"
        let query = extractQueryParamsFromPath(path)

        XCTAssertEqual(query["include[]"], "user")
    }
}
