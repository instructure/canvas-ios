//
// This file is part of Canvas.
// Copyright (C) 2021-present  Instructure, Inc.
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

class K5ResourcesApplicationViewModelTests: CoreTestCase {

    func testApplicationOpening() {
        let testee = K5ResourcesApplicationViewModel(image: nil, name: "test app", routesBySubjectNames: [("Art", URL(string: "https://instructure.com")!)])
        testee.applicationTapped(router: router, route: URL(string: "https://instructure.com")!, viewController: WeakViewController())

        XCTAssertTrue(router.lastRoutedTo("https://instructure.com"))
        wait(for: [router.routeExpectation], timeout: 0.1)
    }

    func testEquatable() {
        let testee1 = K5ResourcesApplicationViewModel(image: nil, name: "a", routesBySubjectNames: [])
        let testee2 = K5ResourcesApplicationViewModel(image: nil, name: "b", routesBySubjectNames: [])
        let testee3 = K5ResourcesApplicationViewModel(image: URL(string: "/image.png"), name: "b", routesBySubjectNames: [])
        XCTAssertNotEqual(testee1, testee2)
        XCTAssertEqual(testee2, testee3)
    }

    func testIdentifiable() {
        let testee = K5ResourcesApplicationViewModel(image: nil, name: "a", routesBySubjectNames: [])
        XCTAssertEqual(testee.id, testee.name)
    }
}
