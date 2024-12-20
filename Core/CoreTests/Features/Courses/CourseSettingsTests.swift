//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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

class CourseSettingsTests: CoreTestCase {
    private let emptyAPIResponse = APICourseSettings(usage_rights_required: nil,
                                                     syllabus_course_summary: nil,
                                                     restrict_quantitative_data: nil)

    func testSavesDefaultValues() {
        let testee = CourseSettings.save(emptyAPIResponse, courseID: "1", in: databaseClient)

        XCTAssertFalse(testee.restrictQuantitativeData)
        XCTAssertFalse(testee.syllabusCourseSummary)
        XCTAssertFalse(testee.usageRightsRequired)
    }

    func testSavesAPIValues() {
        let apiResponse = APICourseSettings(usage_rights_required: true,
                                            syllabus_course_summary: true,
                                            restrict_quantitative_data: true)
        let testee = CourseSettings.save(apiResponse, courseID: "1", in: databaseClient)

        XCTAssertTrue(testee.restrictQuantitativeData)
        XCTAssertTrue(testee.syllabusCourseSummary)
        XCTAssertTrue(testee.usageRightsRequired)
    }

    func testRestrictQuantitativeDataFlagNotSavedForTeacherApp() {
        AppEnvironment.shared.app = .teacher
        let apiResponse = APICourseSettings(usage_rights_required: true,
                                            syllabus_course_summary: true,
                                            restrict_quantitative_data: true)
        let testee = CourseSettings.save(apiResponse, courseID: "1", in: databaseClient)

        XCTAssertFalse(testee.restrictQuantitativeData)
        XCTAssertTrue(testee.syllabusCourseSummary)
        XCTAssertTrue(testee.usageRightsRequired)
    }

    func testEmptyResponseNotOverwritesSavedData() {
        let dbEntity: CourseSettings = databaseClient.insert()
        dbEntity.courseID = "1"
        dbEntity.restrictQuantitativeData = true
        dbEntity.syllabusCourseSummary = true
        dbEntity.usageRightsRequired = true
        CourseSettings.save(emptyAPIResponse, courseID: "1", in: databaseClient)

        let scope = Scope.where(#keyPath(CourseSettings.courseID), equals: "1")
        guard let testee: CourseSettings = (databaseClient.fetch(scope: scope) as [CourseSettings]).first else {
            return XCTFail()
        }

        XCTAssertTrue(testee.restrictQuantitativeData)
        XCTAssertTrue(testee.syllabusCourseSummary)
        XCTAssertTrue(testee.usageRightsRequired)
    }
}
