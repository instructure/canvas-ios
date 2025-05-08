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

import Combine
import XCTest
@testable import Core

class CourseSyncEnvironmentResolverTests: CoreTestCase {

    private enum TestConstants {
        static let courseID = "course-id-422"
        static let userID = "user-id-123"
    }

    private var resolver: CourseSyncEnvironmentResolver!

    private func makeTestResolver() {
        resolver = TestCourseSyncEnvironmentResolver(userId: TestConstants.userID, environment: environment)
    }

    private func makeLiveResolver() {
        resolver = CourseSyncEnvironmentResolverLive()
    }

    func test_default_impl_env_and_session() {
        // Given
        makeTestResolver()

        let env = environment
        let courseID = CourseSyncID(value: TestConstants.courseID)

        // Then
        XCTAssertEqual(resolver.userId, TestConstants.userID)
        XCTAssertTrue(resolver.targetEnvironment(for: courseID) === env)
        XCTAssertEqual(resolver.loginSession(for: courseID), env.currentSession)
        XCTAssertEqual(resolver.sessionId(for: courseID), env.currentSession?.uniqueID)
    }

    func test_default_impl_offline_directories() {
        makeTestResolver()

        let courseID = CourseSyncID(value: TestConstants.courseID)
        let sessionID = environment.currentSession?.uniqueID ?? ""

        let expectedDir = URL.Paths.Offline.rootURL(sessionID: sessionID)
        XCTAssertEqual(resolver.offlineDirectory(for: courseID), expectedDir)

        let expectedStudioDir = expectedDir.appendingPathComponent("studio", isDirectory: true)
        XCTAssertEqual(resolver.offlineStudioDirectory(for: courseID), expectedStudioDir)

        let expectedFolderURL = URL.Paths.Offline.courseSectionFolderURL(
            sessionId: sessionID,
            courseId: TestConstants.courseID,
            sectionName: "Pages"
        )

        XCTAssertEqual(resolver.folderURL(forSection: "Pages", ofCourse: courseID), expectedFolderURL)

        let expectedFolderPath = "\(sessionID)/Offline/course-\(TestConstants.courseID)/Pages"
        XCTAssertEqual(resolver.folderDocumentsPath(forSection: "Pages", ofCourse: courseID), expectedFolderPath)
    }

    func test_live_resolver() throws {
        // Given
        makeLiveResolver()

        // Then
        XCTAssertEqual(resolver.userId, environment.currentSession?.userID)

        // Given
        let exampleBaseURL = URL(string: "https://random-school-034.instructure.com")
        let courseID = CourseSyncID(
            value: TestConstants.courseID,
            apiBaseURL: exampleBaseURL
        )

        // Then
        let targetEnv = try XCTUnwrap(resolver.targetEnvironment(for: courseID) as? AppEnvironmentOverride)
        XCTAssertEqual(targetEnv.api.baseURL, exampleBaseURL)
        XCTAssertEqual(targetEnv.currentSession?.baseURL, exampleBaseURL)
    }

}

private struct TestCourseSyncEnvironmentResolver: CourseSyncEnvironmentResolver {
    var userId: String
    var environment: AppEnvironment

    func targetEnvironment(for courseID: Core.CourseSyncID) -> AppEnvironment {
        environment
    }
}
