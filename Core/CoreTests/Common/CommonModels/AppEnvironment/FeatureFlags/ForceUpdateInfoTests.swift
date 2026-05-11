//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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

@testable import Core
import XCTest

final class ForceUpdateInfoTests: XCTestCase {

    private static let testData = (
        belowAppVersion: "5.0.0",
        minimumSystemVersion: "16.0",
        isDismissable: true
    )
    private lazy var testData = Self.testData

    // MARK: - init(data:)

    func test_init_withValidJSON_shouldDecodeSuccessfully() {
        let testee = makeForceUpdateInfo(
            belowAppVersion: testData.belowAppVersion,
            minimumSystemVersion: testData.minimumSystemVersion,
            isDismissable: testData.isDismissable
        )

        XCTAssertNotNil(testee)
        XCTAssertEqual(testee?.isDismissable, true)
    }

    func test_init_withInvalidJSON_shouldReturnNil() {
        let data = Data("not valid json".utf8)

        let testee = ForceUpdateInfo(data: data)

        XCTAssertNil(testee)
    }

    func test_init_withEmptyData_shouldReturnNil() {
        let testee = ForceUpdateInfo(data: Data())

        XCTAssertNil(testee)
    }

    func test_init_withMissingFields_shouldReturnNil() {
        let json = #"{"belowAppVersion": "5.0.0"}"#
        let data = Data(json.utf8)

        let testee = ForceUpdateInfo(data: data)

        XCTAssertNil(testee)
    }

    func test_init_shouldDecodeIsDismissable() {
        var testee = makeForceUpdateInfo(isDismissable: true)
        XCTAssertEqual(testee?.isDismissable, true)

        testee = makeForceUpdateInfo(isDismissable: false)
        XCTAssertEqual(testee?.isDismissable, false)
    }

    // MARK: - isForceUpdateInfo(of:key:)

    func test_isForceUpdateInfo_whenKeyMatchesApp_shouldReturnTrue() {
        XCTAssertEqual(ForceUpdateInfo.isForceUpdateInfo(of: .student, key: "student_force_update_info"), true)
        XCTAssertEqual(ForceUpdateInfo.isForceUpdateInfo(of: .teacher, key: "teacher_force_update_info"), true)
        XCTAssertEqual(ForceUpdateInfo.isForceUpdateInfo(of: .parent, key: "parent_force_update_info"), true)
        XCTAssertEqual(ForceUpdateInfo.isForceUpdateInfo(of: .horizon, key: "student_force_update_info"), true)
    }

    func test_isForceUpdateInfo_whenKeyDoesNotMatchApp_shouldReturnFalse() {
        XCTAssertEqual(ForceUpdateInfo.isForceUpdateInfo(of: .student, key: "teacher_force_update_info"), false)
        XCTAssertEqual(ForceUpdateInfo.isForceUpdateInfo(of: .teacher, key: "parent_force_update_info"), false)
        XCTAssertEqual(ForceUpdateInfo.isForceUpdateInfo(of: .parent, key: "student_force_update_info"), false)
    }

    func test_isForceUpdateInfo_withArbitraryKey_shouldReturnFalse() {
        XCTAssertEqual(ForceUpdateInfo.isForceUpdateInfo(of: .student, key: "some_other_key"), false)
    }

    // MARK: - forceUpdateRemoteConfigKey

    func test_forceUpdateRemoteConfigKey() {
        XCTAssertEqual(AppEnvironment.App.student.forceUpdateRemoteConfigKey, "student_force_update_info")
        XCTAssertEqual(AppEnvironment.App.horizon.forceUpdateRemoteConfigKey, "student_force_update_info")
        XCTAssertEqual(AppEnvironment.App.teacher.forceUpdateRemoteConfigKey, "teacher_force_update_info")
        XCTAssertEqual(AppEnvironment.App.parent.forceUpdateRemoteConfigKey, "parent_force_update_info")
    }

    // MARK: - appID

    func test_appID() {
        XCTAssertEqual(AppEnvironment.App.student.appID, Bundle.studentAppID)
        XCTAssertEqual(AppEnvironment.App.horizon.appID, Bundle.studentAppID)
        XCTAssertEqual(AppEnvironment.App.teacher.appID, Bundle.teacherAppID)
        XCTAssertEqual(AppEnvironment.App.parent.appID, Bundle.parentAppID)
    }

    // MARK: - UserDefaults round-trip

    func test_saveToUserDefaults_andFromUserDefaults_shouldRoundTrip() {
        let testee = makeForceUpdateInfo(
            belowAppVersion: testData.belowAppVersion,
            minimumSystemVersion: testData.minimumSystemVersion,
            isDismissable: testData.isDismissable
        )
        testee?.saveToUserDefaults()

        let restored = ForceUpdateInfo.fromUserDefaults()

        XCTAssertNotNil(restored)
        XCTAssertEqual(restored?.isDismissable, testData.isDismissable)
    }

    // MARK: - Private helpers

    private func makeForceUpdateInfo(
        belowAppVersion: String = "5.0.0",
        minimumSystemVersion: String = "16.0",
        isDismissable: Bool = true
    ) -> ForceUpdateInfo? {
        let json = """
        {
            "belowAppVersion": "\(belowAppVersion)",
            "minimumSystemVersion": "\(minimumSystemVersion)",
            "isDismissable": \(isDismissable)
        }
        """
        return ForceUpdateInfo(data: Data(json.utf8))
    }
}
