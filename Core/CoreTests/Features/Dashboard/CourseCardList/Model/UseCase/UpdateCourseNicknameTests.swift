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

import XCTest
@testable import Core

class UpdateCourseNicknameTests: CoreTestCase {

    private static let testData = (
        courseId: "some course id",
        courseName: "some course name",
        nickname: "some nickname"
    )
    private lazy var testData = Self.testData

    // MARK: - Request

    func test_request() {
        let testee = UpdateCourseNickname(courseID: testData.courseId, nickname: testData.nickname)

        XCTAssertEqual(testee.request.path, "users/self/course_nicknames/\(testData.courseId)")
        XCTAssertEqual(testee.request.method, .put)
        XCTAssertEqual(testee.request.body?.nickname, testData.nickname)
    }

    // MARK: - Cache key

    func test_cacheKey_shouldBeNil() {
        let testee = UpdateCourseNickname(courseID: testData.courseId, nickname: testData.nickname)

        XCTAssertEqual(testee.cacheKey, nil)
    }

    // MARK: - Write

    func test_write_shouldUpdateCourseNameAndDashboardCardShortName() {
        let course: Course = databaseClient.insert()
        course.id = testData.courseId
        course.name = testData.courseName
        let card: DashboardCard = databaseClient.insert()
        card.id = testData.courseId
        card.shortName = testData.courseName
        let response = APICourseNickname(
            course_id: ID(testData.courseId),
            name: testData.courseName,
            nickname: testData.nickname
        )

        UpdateCourseNickname(courseID: testData.courseId, nickname: testData.nickname)
            .write(response: response, urlResponse: nil, to: databaseClient)

        XCTAssertEqual(course.name, testData.nickname)
        XCTAssertEqual(card.shortName, testData.nickname)
    }

    func test_write_whenResponseIsNil_shouldNotModifyEntities() {
        let course: Course = databaseClient.insert()
        course.id = testData.courseId
        course.name = testData.courseName

        UpdateCourseNickname(courseID: testData.courseId, nickname: testData.nickname)
            .write(response: nil, urlResponse: nil, to: databaseClient)

        XCTAssertEqual(course.name, testData.courseName)
    }
}
