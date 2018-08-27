//
//  Router+Tests.swift
//  CoreTests
//
//  Created by Layne Moseley on 8/10/18.
//  Copyright © 2018 Instructure, Inc. All rights reserved.
//

import XCTest
import Core

class RouterTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testRouter() {
        let router = Router()

        router.addRoute("/courses") { _ in
            return UIViewController()
        }
        router.addRoute("/inbox") { _ in
            return UIViewController()
        }

        XCTAssert(router.count == 2)

        let routeExists = router.routeForPath("/courses")
        XCTAssertNotNil(routeExists)

        let missingRoute = router.routeForPath("/garbage")
        XCTAssertNil(missingRoute)
    }
}
