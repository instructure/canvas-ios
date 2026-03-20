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

import Core
import XCTest
@testable import Student

final class WeeklySummaryWidgetAssignmentTests: StudentTestCase {

    // MARK: - init(entry:) — core field mapping

    func test_init_mapsIdAndTitle() {
        let entry = makeEntry(assignmentId: "a42", title: "Chemistry Lab")

        let testee = WeeklySummaryWidgetAssignment(entry: entry)

        XCTAssertEqual(testee.id, "a42")
        XCTAssertEqual(testee.title, "Chemistry Lab")
    }

    func test_init_mapsCourseIdFromCourse() {
        let course = makeCourse(id: "99")
        let entry = makeEntry(assignmentId: "a1", courseId: "99", course: course)

        let testee = WeeklySummaryWidgetAssignment(entry: entry)

        XCTAssertEqual(testee.courseId, "99")
    }

    func test_init_usesCourseNameAsDisplayCode() {
        let course = makeCourse(name: "Chemistry 101")
        let entry = makeEntry(course: course)

        let testee = WeeklySummaryWidgetAssignment(entry: entry)

        XCTAssertEqual(testee.courseCode, "Chemistry 101")
    }

    func test_init_fallsBackToCourseCodeWhenNameIsNil() {
        let course = makeCourse(name: nil, courseCode: "CHEM101")
        let entry = makeEntry(course: course)

        let testee = WeeklySummaryWidgetAssignment(entry: entry)

        XCTAssertEqual(testee.courseCode, "CHEM101")
    }

    func test_init_fallsBackToEmptyStringWhenNoCourse() {
        let entry = makeEntry(courseId: "99", course: nil)

        let testee = WeeklySummaryWidgetAssignment(entry: entry)

        XCTAssertEqual(testee.courseCode, "")
    }

    // MARK: - dueDateText

    func test_dueDateText_isFormattedForMissingCategory() {
        let date = Date(timeIntervalSince1970: 1_700_000_000)
        let entry = makeEntry(category: .missing, date: date)

        let testee = WeeklySummaryWidgetAssignment(entry: entry)

        XCTAssertEqual(testee.dueDateText, date.relativeDateTimeString)
    }

    func test_dueDateText_isFormattedForDueCategory() {
        let date = Date(timeIntervalSince1970: 1_700_000_000)
        let entry = makeEntry(category: .due, date: date)

        let testee = WeeklySummaryWidgetAssignment(entry: entry)

        XCTAssertEqual(testee.dueDateText, date.relativeDateTimeString)
    }

    func test_dueDateText_isFormattedForNewGradesCategory() {
        let date = Date(timeIntervalSince1970: 1_700_000_000)
        let entry = makeEntry(category: .newGrades, date: date)

        let testee = WeeklySummaryWidgetAssignment(entry: entry)

        XCTAssertEqual(testee.dueDateText, date.relativeDateTimeString)
    }

    // MARK: - grade

    func test_grade_isNilForMissingCategory() {
        let entry = makeEntry(category: .missing)
        entry.grade = "A"
        entry.score = 90
        entry.pointsPossible = 100
        entry.gradingType = GradingType.points.rawValue

        let testee = WeeklySummaryWidgetAssignment(entry: entry)

        XCTAssertNil(testee.grade)
    }

    func test_grade_isFormattedForDueCategoryWithScore() {
        let entry = makeEntry(category: .due)
        entry.score = 85
        entry.pointsPossible = 100
        entry.gradingType = GradingType.points.rawValue

        let testee = WeeklySummaryWidgetAssignment(entry: entry)

        XCTAssertNotNil(testee.grade)
    }

    func test_grade_isFormattedForNewGradesCategoryWithScore() {
        let entry = makeEntry(category: .newGrades)
        entry.score = 72
        entry.pointsPossible = 100
        entry.gradingType = GradingType.points.rawValue

        let testee = WeeklySummaryWidgetAssignment(entry: entry)

        XCTAssertNotNil(testee.grade)
    }

    // MARK: - submissionStatus

    func test_submissionStatus_isGradedWhenDueAndGraded() {
        let entry = makeEntry(category: .due)
        entry.submissionStatus = .graded

        let testee = WeeklySummaryWidgetAssignment(entry: entry)

        XCTAssertEqual(testee.submissionStatus?.text, "Graded")
    }

    func test_submissionStatus_isSubmittedWhenDueAndSubmitted() {
        let entry = makeEntry(category: .due)
        entry.submissionStatus = .submitted

        let testee = WeeklySummaryWidgetAssignment(entry: entry)

        XCTAssertEqual(testee.submissionStatus?.text, "Submitted")
    }

    func test_submissionStatus_isNilForMissingCategory() {
        let entry = makeEntry(category: .missing)
        entry.submissionStatus = .graded

        let testee = WeeklySummaryWidgetAssignment(entry: entry)

        XCTAssertNil(testee.submissionStatus)
    }

    func test_submissionStatus_isNilForNewGradesCategory() {
        let entry = makeEntry(category: .newGrades)
        entry.submissionStatus = .submitted

        let testee = WeeklySummaryWidgetAssignment(entry: entry)

        XCTAssertNil(testee.submissionStatus)
    }

    func test_submissionStatus_isNilWhenNilOnDueEntry() {
        let entry = makeEntry(category: .due)
        entry.submissionStatus = nil

        let testee = WeeklySummaryWidgetAssignment(entry: entry)

        XCTAssertNil(testee.submissionStatus)
    }

    // MARK: - gradeWeightText

    func test_gradeWeightText_isNilWhenAssignmentWeightIsNil() {
        let entry = makeEntry(category: .due)
        entry.gradeWeight = nil

        let testee = WeeklySummaryWidgetAssignment(entry: entry)

        XCTAssertNil(testee.gradeWeightText)
    }

    func test_gradeWeightText_containsFinalGradeLabel() {
        let entry = makeEntry(category: .due)
        entry.gradeWeight = 0.20

        let testee = WeeklySummaryWidgetAssignment(entry: entry)

        XCTAssertTrue(testee.gradeWeightText?.contains("final grade") == true)
    }

    func test_gradeWeightText_containsFormattedPercent() {
        let entry = makeEntry(category: .due)
        entry.gradeWeight = 0.30

        let testee = WeeklySummaryWidgetAssignment(entry: entry)

        XCTAssertTrue(testee.gradeWeightText?.contains("30%") == true)
    }

    // MARK: - pointsPossible

    func test_pointsPossible_isNilWhenNil() {
        let entry = makeEntry(category: .due)
        entry.pointsPossible = nil

        let testee = WeeklySummaryWidgetAssignment(entry: entry)

        XCTAssertNil(testee.pointsPossible)
    }

    func test_pointsPossible_isFormattedWhenPresent() {
        let entry = makeEntry(category: .due)
        entry.pointsPossible = 10

        let testee = WeeklySummaryWidgetAssignment(entry: entry)

        XCTAssertNotNil(testee.pointsPossible)
    }

    // MARK: - Private helpers

    @discardableResult
    private func makeCourse(id: String = "1", name: String? = "Course Name", courseCode: String = "TEST") -> Course {
        Course.make(from: .make(id: ID(id), name: name, course_code: courseCode), in: databaseClient)
    }

    private func makeEntry(
        assignmentId: String = "a1",
        courseId: String = "1",
        title: String = "Assignment",
        category: CDDashboardWeeklySummaryEntry.Category = .due,
        date: Date? = nil,
        course: Course? = nil
    ) -> CDDashboardWeeklySummaryEntry {
        let entry = CDDashboardWeeklySummaryEntry.findOrCreate(
            weekStart: .distantPast,
            category: category,
            id: assignmentId,
            in: databaseClient
        )
        entry.weekStart = .distantPast
        entry.category = category
        entry.courseId = courseId
        entry.title = title
        entry.date = date
        entry.submissionTypes = []
        if let course {
            entry.course = course
        }
        return entry
    }
}
