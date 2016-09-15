//
//  PathTests.swift
//  TooLegit
//
//  Created by Nathan Armstrong on 1/18/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import XCTest
import TooLegit

class PathTests: XCTestCase {

    func testBuildingPathsFromStrings() {
        let basePath = api/v1
        XCTAssertEqual("api/v1", basePath)

        XCTAssertEqual("api/v1/users", basePath/"users")
        XCTAssertEqual("api/v1/users/foo/bar", api/v1/"users"/"foo"/"bar")
    }

    func testBuildingPathsFromURL() {
        let baseURL = NSURL(string: "http://api.com")!
        XCTAssertEqual("http://api.com/users", (baseURL/"users").absoluteString)
    }

    func testBuildingPathFromInt() {
        XCTAssertEqual("api/v1/courses/1", api/v1/"courses"/1)
    }

}
