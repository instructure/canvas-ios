//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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

class SubmissionDestinationTests: CoreTestCase {

    func test_api_resolving_for_dest_with_no_host() throws {
        let destWithNoHost = SubmissionDestination(
            courseID: "123",
            assignmentID: "321",
            userID: "456"
        )

        XCTAssertEqual(destWithNoHost.context, Context(.course, id: "123"))
        XCTAssertNil(destWithNoHost.baseURL(in: environment))
    }

    func test_api_resolving_for_dest_with_host() throws {
        let destWithHost = SubmissionDestination(
            courseID: "456",
            assignmentID: "876",
            userID: "322",
            apiInstanceHost: "canvas-034.instructure.com"
        )

        let expected = URL(string: "https://canvas-034.instructure.com")
        XCTAssertEqual(destWithHost.baseURL(in: environment), expected)
        XCTAssertEqual(destWithHost.context, Context(.course, id: "456"))
    }
}

class DefaultSubmissionApiCoordinatorTests: CoreTestCase {

    func test_api_resolving_with_no_host() throws {
        let destWithNoHost = SubmissionDestination(
            courseID: "123",
            assignmentID: "321",
            userID: "456"
        )

        let coordinator = DefaultSubmissionApiCoordinator()
        let api = coordinator.api(for: destWithNoHost, in: environment)
        XCTAssertEqual(api.baseURL, environment.api.baseURL)
        XCTAssertEqual(api.loginSession, environment.api.loginSession)
    }

    func test_api_resolving_with_host() throws {
        let destWithHost = SubmissionDestination(
            courseID: "456",
            assignmentID: "876",
            userID: "322",
            apiInstanceHost: "canvas-034.instructure.com"
        )

        let coordinator = DefaultSubmissionApiCoordinator()
        let api = coordinator.api(for: destWithHost, in: environment)
        XCTAssertEqual(api.baseURL, destWithHost.baseURL(in: environment))
        XCTAssertEqual(api.loginSession, environment.api.loginSession)
    }
}
