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
        let route1 = Route("/courses") { return UIViewController() }
        let route2 = Route("/inbox") { return UIViewController() }

        router.addRoute(route1)
        router.addRoute(route2)

        XCTAssert(router.count == 2)

        let routeExists = router.routeForPath("/courses")
        XCTAssertNotNil(routeExists)

        let missingRoute = router.routeForPath("/garbage")
        XCTAssertNil(missingRoute)
    }
}
