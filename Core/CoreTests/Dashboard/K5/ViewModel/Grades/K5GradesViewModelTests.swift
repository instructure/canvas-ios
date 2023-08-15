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

class K5GradesViewModelTests: CoreTestCase {

    func testRefresh() {
        let refreshExpectation = expectation(description: "Refresh finished")
        let testee = K5GradesViewModel()
        testee.refresh {
            refreshExpectation.fulfill()
        }

        wait(for: [refreshExpectation], timeout: 2.5)
    }

    func testLoadGrades() {
        api.mock(GetUserProfileRequest(userID: "self"), value: APIProfile.make())
        mockCourses()

        let testee = K5GradesViewModel()

        XCTAssertEqual(testee.grades.count, 3)

        XCTAssertEqual(testee.grades[0].grade, "A")
        XCTAssertEqual(testee.grades[1].grade, "B")
        XCTAssertNil(testee.grades[2].grade)

        XCTAssertEqual(testee.grades[0].score, 95)
        XCTAssertNil(testee.grades[1].score)
        XCTAssertEqual(testee.grades[2].score, 55)
    }

    func testGradingPeriods() {
        api.mock(GetUserProfileRequest(userID: "self"), value: APIProfile.make())
        mockCourses()

        let testee = K5GradesViewModel()

        XCTAssertEqual(testee.currentGradingPeriod.title, "Current Grading Period")
        XCTAssertEqual(testee.gradingPeriods.count, 3)
        XCTAssertEqual(testee.gradingPeriods[1].periodID, "2")
    }

    func testGradingPeriodChange() {
        api.mock(GetUserProfileRequest(userID: "self"), value: APIProfile.make())
        mockCourses()
        api.mock(GetEnrollmentsRequest(context: .currentUser, userID: "1", gradingPeriodID: "1", types: [ "StudentEnrollment" ], states: [ .active ]), value: [
            .make(id: "1", course_id: "3", grades: .make(current_grade: "C")),
        ])

        let testee = K5GradesViewModel()
        testee.didSelect(gradingPeriod: testee.gradingPeriods[2])

        XCTAssertEqual(testee.currentGradingPeriod.title, "grading period 1")
        XCTAssertEqual(testee.grades.first?.grade, "C")
    }

    func testMultiGradingPeriodCurrentGrade() {
        api.mock(GetUserCourses(userID: "1"), value: [
            .make(
                id: "1",
                name: "Math",
                course_code: "CRS-1",
                enrollments: [
                    .make(
                        id: "1",
                        course_id: "1",
                        user_id: "1",
                        multiple_grading_periods_enabled: true,
                        current_period_computed_current_score: 6,
                        current_period_computed_current_grade: "Hat"
                    ),
                ]
            ),
        ])

        let testee = K5GradesViewModel()
        XCTAssertEqual(testee.grades.first?.grade, "Hat")
        XCTAssertEqual(testee.grades.first?.score, 6)
    }

    func testHidesGradeBarWhenQuantitativeDataEnabled() {
        api.mock(GetUserCourses(userID: "1"), value: [
            .make(
                id: "1",
                name: "Math",
                course_code: "CRS-1",
                enrollments: [
                    .make(
                        id: "1",
                        course_id: "1",
                        user_id: "1",
                        multiple_grading_periods_enabled: true,
                        current_period_computed_current_score: 6,
                        current_period_computed_current_grade: "Hat"
                    ),
                ],
                settings: APICourseSettings.make(restrict_quantitative_data: true)
            ),
        ])

        let testee = K5GradesViewModel()
        XCTAssertTrue(testee.grades[0].hideGradeBar)
    }

    func testShowsCourseLetterGradeWhenQuantitativeDataEnabled() {
        api.mock(GetUserCourses(userID: "1"), value: [
            .make(
                id: "1",
                name: "Math",
                course_code: "CRS-1",
                enrollments: [
                    .make(
                        id: "1",
                        course_id: "1",
                        user_id: "1",
                        computed_current_letter_grade: "B",
                        multiple_grading_periods_enabled: true,
                        current_period_computed_current_score: 6,
                        current_period_computed_current_grade: "Hat"
                    ),
                ],
                settings: APICourseSettings.make(restrict_quantitative_data: true)
            ),
        ])

        let testee = K5GradesViewModel()
        XCTAssertEqual(testee.grades.first?.grade, "B")
        XCTAssertNil(testee.grades.first?.score)
    }

    func testShowsEnrollmentLetterGradeWhenQuantitativeDataEnabled() {
        let gradingPeriods: [APIGradingPeriod] = [
            .make(id: "1", title: "grading period 1", start_date: Clock.now.addDays(-7)),
        ]
        api.mock(GetUserCourses(userID: "1"), value: [
            .make(
                id: "1",
                name: "",
                course_code: "CRS-1",
                enrollments: [
                    .make(
                        id: "1",
                        course_id: "1",
                        user_id: "1"
                    ),
                ],
                grading_periods: gradingPeriods,
                homeroom_course: false,
                settings: APICourseSettings.make(restrict_quantitative_data: true)
            ),
        ])
        let request = GetEnrollmentsRequest(context: .currentUser,
                                            userID: "1",
                                            gradingPeriodID: "1",
                                            types: ["StudentEnrollment"],
                                            states: [.active])
        api.mock(request, value: [
            .make(id: "1", course_id: "1", computed_current_letter_grade: "B"),
        ])

        let testee = K5GradesViewModel()
        testee.didSelect(gradingPeriod: testee.gradingPeriods[1])

        XCTAssertEqual(testee.grades.first?.grade, "B")
        XCTAssertNil(testee.grades.first?.score)
    }

    // MARK: - Private Helpers

    private func mockCourses() {
        let gradingPeriods: [APIGradingPeriod] = [
            .make(id: "1", title: "grading period 1", start_date: Clock.now),
            .make(id: "2", title: "grading period 2", start_date: Clock.now.addDays(-7)),
        ]
        api.mock(GetUserCourses(userID: "1"), value: [
            .make(
                id: "1",
                name: "Homeroom",
                course_code: "CRS-1",
                enrollments: [
                    .make(
                        id: "1",
                        course_id: "1",
                        user_id: "1"
                    ),
                ],
                grading_periods: gradingPeriods,
                homeroom_course: true
            ),
            .make(
                id: "2",
                name: "Course B",
                course_code: "CRS-2",
                enrollments: [
                    .make(
                        id: "2",
                        course_id: "2",
                        user_id: "1",
                        computed_current_score: 95,
                        computed_current_grade: "A"
                    ),
                ],
                grading_periods: gradingPeriods
            ),
            .make(
                id: "3",
                name: "Course C",
                course_code: "CRS-3",
                enrollments: [
                    .make(
                        id: "3",
                        course_id: "3",
                        user_id: "1",
                        computed_current_score: nil,
                        computed_current_grade: "B"
                    ),
                ],
                grading_periods: gradingPeriods
            ),
            .make(
                id: "4",
                name: "Course D",
                course_code: "CRS-4",
                enrollments: [
                    .make(
                        id: "4",
                        course_id: "4",
                        user_id: "1",
                        computed_current_score: 55,
                        computed_current_grade: nil
                    ),
                ],
                grading_periods: gradingPeriods
            ),
        ])
    }
}
