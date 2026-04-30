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

import XCTest
@testable import Core
@testable import NextGen

final class NGRoutesTests: NGTestCase {

    private static let testData = (
        route1: "/some/route/1",
        route2: "/some/route/2",
        academicVC: UIViewController(),
        academicVC2: UIViewController(),
        nextgenVC: UIViewController()
    )
    private lazy var testData = Self.testData

    // MARK: - makeRouter

    func test_makeRouter_shouldUseAcademicRouteHandlers() {
        let academicRoutes = [RouteHandler(testData.route1) { _, _, _ in self.testData.academicVC }]

        let router = NGRoutes.makeRouter(academicRoutes: academicRoutes, nextgenRoutes: [])

        XCTAssertIdentical(router.match(testData.route1), testData.academicVC)
    }

    func test_makeRouter_whenNextgenRouteOverridesAcademicRoute_shouldUseNextgenHandler() {
        let academicRoutes = [RouteHandler(testData.route1) { _, _, _ in self.testData.academicVC }]
        let nextgenRoutes = [RouteHandler(testData.route1) { _, _, _ in self.testData.nextgenVC }]

        let router = NGRoutes.makeRouter(academicRoutes: academicRoutes, nextgenRoutes: nextgenRoutes)

        XCTAssertIdentical(router.match(testData.route1), testData.nextgenVC)
    }

    func test_makeRouter_whenNextgenRouteOverridesAcademicRoute_shouldKeepOtherAcademicRouteHandlers() {
        let academicRoutes = [
            RouteHandler(testData.route1) { _, _, _ in self.testData.academicVC2 },
            RouteHandler(testData.route2) { _, _, _ in self.testData.academicVC }
        ]
        let nextgenRoutes = [RouteHandler(testData.route1) { _, _, _ in self.testData.nextgenVC }]

        let router = NGRoutes.makeRouter(academicRoutes: academicRoutes, nextgenRoutes: nextgenRoutes)

        XCTAssertIdentical(router.match(testData.route2), testData.academicVC)
    }
}
