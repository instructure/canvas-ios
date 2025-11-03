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

class AppEnvironmentOverrideTests: CoreTestCase {

    func test_session_baseUrl_override() {
        let urlComponents = URLComponents(string: "https://override.url")!
        let testee = AppEnvironment.resolved(for: urlComponents, contextShardID: "23452")

        XCTAssertEqual(testee.app, environment.app)
        XCTAssertTrue(testee.router === environment.router)
        XCTAssertEqual(testee.database, environment.database)
        XCTAssertEqual(testee.globalDatabase, environment.globalDatabase)
        XCTAssertEqual(testee.userDefaults, environment.userDefaults)
        XCTAssertTrue(testee.loginDelegate === environment.loginDelegate)
        XCTAssertEqual(testee.window, environment.window)
        XCTAssertEqual(testee.contextShardID, "23452")

        XCTAssertEqual(testee.api.baseURL, urlComponents.url)
        XCTAssertEqual(testee.currentSession?.baseURL, urlComponents.url)
    }

    func test_userID_override_course_on_trusted_account() {
        // Given
        environment.currentSession = LoginSession(
            accessToken: "32345~78482348h28734y283h58734y58437h5...",
            baseURL: URL(string: "https://random-school.instructure.com")!,
            userID: "897",
            userName: "some_user_name"
        )

        // When
        let urlComponents = URLComponents(string: "https://another-school.instructure.com")!
        let testee = AppEnvironment.resolved(for: urlComponents, contextShardID: "23452")

        // Then
        XCTAssertEqual(testee.currentSession?.userID, "323450000000000897")
    }

    func test_userID_override_cross_shard_course_and_user_in_same_account() {
        // Given
        environment.currentSession = LoginSession(
            accessToken: "87456~875934m583u4985869384m546987596...",
            baseURL: URL(string: "https://random-school.instructure.com")!,
            userID: "64568~768",
            userName: "some_user_name"
        )

        // When
        let urlComponents = URLComponents(string: "https://random-school-02.instructure.com")!
        let testee = AppEnvironment.resolved(for: urlComponents, contextShardID: "64568")

        // Then
        XCTAssertEqual(testee.currentSession?.userID, "768")
    }

    func test_userID_override_cross_shard_course_and_user_in_diff_account() {
        // Given
        environment.currentSession = LoginSession(
            accessToken: "76854~4347bbkjh9845y934983g4g87324878...",
            baseURL: URL(string: "https://random-school.instructure.com")!,
            userID: "64568~345",
            userName: "some_user_name"
        )

        // When
        let urlComponents = URLComponents(string: "https://random-school-06.instructure.com")!
        let testee = AppEnvironment.resolved(for: urlComponents, contextShardID: "23456")

        // Then
        XCTAssertEqual(testee.currentSession?.userID, "64568~345")
    }

    func test_transformContentIDsToLocalForm_root_env() {
        // Given
        var url = URLComponents(string: "https://random-school.instructure.com")!
        url.path = "/courses/21342~542/assignments/21342~435"
        url.queryItems = [
            URLQueryItem(name: "courseID", value: "21342~542"),
            URLQueryItem(name: "assignmentID", value: "21342~435"),
            URLQueryItem(name: "assignment_id", value: "21342~435")
        ]

        let params: [String: String] = [
            "courseID": "21342~542",
            "assignmentID": "21342~435",
            "userID": "21342~124"
        ]

        // When
        let (newParams, newUrl) = environment.transformContentIDsToLocalForm(params: params, url: url)

        // Assert no transform for root environment
        XCTAssertEqual(url, newUrl)
        XCTAssertEqual(params, newParams)
    }

    func test_transformContentIDsToLocalForm_overriden_env() {
        // Given
        environment.currentSession = LoginSession(
            accessToken: "76854~4347bbkjh9845y934983g4g87324878...",
            baseURL: URL(string: "https://random-school.instructure.com")!,
            userID: "64568~345",
            userName: "some_user_name"
        )

        var url = URLComponents(string: "https://another-school.instructure.com")!
        url.path = "/courses/21342~542/assignments/21342~435/submissions/21342~198"
        url.queryItems = [
            URLQueryItem(name: "courseID", value: "21342~542"),
            URLQueryItem(name: "assignmentID", value: "21342~435"),
            URLQueryItem(name: "assignment_id", value: "21342~435"),
            URLQueryItem(name: "userID", value: "64568~345")
        ]

        let params: [String: String] = [
            "courseID": "21342~542",
            "assignmentID": "21342~435",
            "submissionID": "21342~198",
            "userID": "64568~345"
        ]

        // When
        let testee = AppEnvironment.resolved(for: url, contextShardID: "21342")
        let (newParams, newUrl) = testee.transformContentIDsToLocalForm(params: params, url: url)

        // Then

        // - Expected
        var expUrl = URLComponents(string: "https://another-school.instructure.com")!
        expUrl.path = "/courses/542/assignments/435/submissions/198"
        expUrl.queryItems = [
            URLQueryItem(name: "courseID", value: "542"),
            URLQueryItem(name: "assignmentID", value: "435"),
            URLQueryItem(name: "assignment_id", value: "435"),
            URLQueryItem(name: "userID", value: "64568~345")
        ]

        let expParams: [String: String] = [
            "courseID": "542",
            "assignmentID": "435",
            "submissionID": "198",
            "userID": "64568~345"
        ]

        // - Assert Expected
        XCTAssertEqual(newUrl, expUrl)
        XCTAssertEqual(newParams, expParams)
    }
}
