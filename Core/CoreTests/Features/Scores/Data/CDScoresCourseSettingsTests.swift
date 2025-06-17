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

@testable import Core
import XCTest

final class CDScoresCourseSettingsTests: CoreTestCase {
    func testSave() {
        let course = CDHScoresCourse(context: databaseClient)
        course.courseID = "course-123"
        try? databaseClient.save()

        let apiSettings = APICourseSettings.make(
            restrict_quantitative_data: true
        )

        let savedSettings = CDHScoresCourseSettings.save(
            apiSettings,
            course: course,
            in: databaseClient
        )

        XCTAssertEqual(savedSettings.restrictQuantitativeData, true)
        XCTAssertEqual(savedSettings.course, course)

        let settings: CDHScoresCourseSettings? = databaseClient.first(
            where: #keyPath(CDHScoresCourseSettings.course),
            equals: course
        )
        XCTAssertNotNil(settings)
        XCTAssertEqual(settings?.restrictQuantitativeData, true)
    }

    func testSaveWithExistingEntity() {
        let course = CDHScoresCourse(context: databaseClient)
        course.courseID = "course-123"
        try? databaseClient.save()

        let apiSettings1 = APICourseSettings.make(
            restrict_quantitative_data: true
        )

        CDHScoresCourseSettings.save(
            apiSettings1,
            course: course,
            in: databaseClient
        )

        let apiSettings2 = APICourseSettings.make(
            restrict_quantitative_data: false
        )

        let updatedSettings = CDHScoresCourseSettings.save(
            apiSettings2,
            course: course,
            in: databaseClient
        )

        let settings: [CDHScoresCourseSettings] = databaseClient.fetch()
        XCTAssertEqual(settings.count, 1)

        XCTAssertEqual(updatedSettings.restrictQuantitativeData, false)
    }

    func testSaveWithNilValues() {
        let course = CDHScoresCourse(context: databaseClient)
        course.courseID = "course-123"

        let apiSettings = APICourseSettings.make(
            restrict_quantitative_data: nil
        )
        let apiCourse = APICourse.make(settings: apiSettings)

        let savedSettings = CDHScoresCourseSettings.save(
            apiSettings,
            course: course,
            in: databaseClient
        )

        XCTAssertEqual(savedSettings.restrictQuantitativeData, false)
        XCTAssertEqual(savedSettings.course, course)
    }
}
