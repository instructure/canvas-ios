//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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

final class GetUserSettingsTests: CoreTestCase {

    private static let testData = (
        userID: "some-user-id",
        studentKey: "some student key",
        teacherKey: "some teacher key",
        parentKey: "some parent key"
    )
    private lazy var testData = Self.testData

    // MARK: - cacheKey

    func test_cacheKey() {
        let testee = GetUserSettings(userID: testData.userID)
        XCTAssertEqual(testee.cacheKey, "get-user-\(testData.userID)-settings")
    }

    // MARK: - request

    func test_request_path() {
        let testee = GetUserSettings(userID: testData.userID)
        XCTAssertEqual(testee.request.path, "users/\(testData.userID)/settings")
    }

    // MARK: - scope

    func test_scope() {
        let testee = GetUserSettings(userID: testData.userID)
        XCTAssertEqual(testee.scope, Scope(predicate: .all, order: []))
    }

    // MARK: - write

    func test_write_shouldSaveUserSettings() {
        let testee = GetUserSettings()
        let response = APIUserSettings.make(manual_mark_as_read: true)

        testee.write(response: response, urlResponse: nil, to: databaseClient)

        let saved: [UserSettings] = databaseClient.fetch()
        XCTAssertEqual(saved.first?.manualMarkAsRead, true)
    }

    func test_write_whenShouldNotSaveAnalyticsApiKey_shouldNotCallStorePendoApiKey() {
        environment.app = .student
        let testee = GetUserSettings(shouldSaveAnalyticsApiKey: false)
        let response = APIUserSettings.make(pendo_mobile_student_api_key: testData.studentKey)

        testee.write(response: response, urlResponse: nil, to: databaseClient)

        XCTAssertEqual(analytics.storePendoApiKeyCallCount, 0)
    }

    func test_write_whenShouldSaveAnalyticsApiKey_withStudentApp_shouldStoreStudentKey() {
        environment.app = .student
        let testee = GetUserSettings(shouldSaveAnalyticsApiKey: true)
        let response = APIUserSettings.make(pendo_mobile_student_api_key: testData.studentKey)

        testee.write(response: response, urlResponse: nil, to: databaseClient)

        XCTAssertEqual(analytics.storePendoApiKeyInput, testData.studentKey)
        XCTAssertEqual(analytics.storePendoApiKeyCallCount, 1)
    }

    func test_write_whenShouldSaveAnalyticsApiKey_withHorizonApp_shouldStoreStudentKey() {
        environment.app = .horizon
        let testee = GetUserSettings(shouldSaveAnalyticsApiKey: true)
        let response = APIUserSettings.make(pendo_mobile_student_api_key: testData.studentKey)

        testee.write(response: response, urlResponse: nil, to: databaseClient)

        XCTAssertEqual(analytics.storePendoApiKeyInput, testData.studentKey)
        XCTAssertEqual(analytics.storePendoApiKeyCallCount, 1)
    }

    func test_write_whenShouldSaveAnalyticsApiKey_withTeacherApp_shouldStoreTeacherKey() {
        environment.app = .teacher
        let testee = GetUserSettings(shouldSaveAnalyticsApiKey: true)
        let response = APIUserSettings.make(pendo_mobile_teacher_api_key: testData.teacherKey)

        testee.write(response: response, urlResponse: nil, to: databaseClient)

        XCTAssertEqual(analytics.storePendoApiKeyInput, testData.teacherKey)
        XCTAssertEqual(analytics.storePendoApiKeyCallCount, 1)
    }

    func test_write_whenShouldSaveAnalyticsApiKey_withParentApp_shouldStoreParentKey() {
        environment.app = .parent
        let testee = GetUserSettings(shouldSaveAnalyticsApiKey: true)
        let response = APIUserSettings.make(pendo_mobile_parent_api_key: testData.parentKey)

        testee.write(response: response, urlResponse: nil, to: databaseClient)

        XCTAssertEqual(analytics.storePendoApiKeyInput, testData.parentKey)
        XCTAssertEqual(analytics.storePendoApiKeyCallCount, 1)
    }

    func test_write_whenShouldSaveAnalyticsApiKey_withNilOrEmptyKey_shouldNotCallStorePendoApiKey() {
        environment.app = .student
        let testee = GetUserSettings(shouldSaveAnalyticsApiKey: true)

        // WHEN key is nil
        testee.write(response: .make(pendo_mobile_student_api_key: nil), urlResponse: nil, to: databaseClient)
        // THEN
        XCTAssertEqual(analytics.storePendoApiKeyCallCount, 0)

        // WHEN key is empty
        testee.write(response: .make(pendo_mobile_student_api_key: ""), urlResponse: nil, to: databaseClient)
        // THEN
        XCTAssertEqual(analytics.storePendoApiKeyCallCount, 0)
    }
}
