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

import Foundation
import TestsFoundation
import Core

public class GradesHelper: BaseHelper {
    public static func gradesAssignmentButton(assignment: DSAssignment) -> Element {
        app.find(id: "GradeListCell.\(assignment.id)")
    }

    public static func gradesAssignmentSubmittedLabel(assignment: DSAssignment) -> Element {
        gradesAssignmentButton(assignment: assignment).rawElement.findAll(type: .staticText)[2]
    }

    public static func checkForTotalGrade(totalGrade: String) -> Bool {
        sleep(3) // No idea why this is needed but it doesn't work without this
        pullToRefresh()
        return GradeList.totalGrade(totalGrade: totalGrade).waitToExist().isVisible
    }

    public static func createSubmissionsForAssignments(course: DSCourse, student: DSUser, assignments: [DSAssignment]) {
        for assignment in assignments {
            seeder.createSubmission(courseId: course.id, assignmentId: assignment.id, requestBody:
                .init(submission_type: .online_text_entry, body: "This is a submission body", user_id: student.id))
        }
    }

    public static func createAssignments(course: DSCourse, count: Int, points_possible: [Float]? = nil, grading_type: GradingType? = nil) -> [DSAssignment] {
        var assignments = [DSAssignment]()
        for i in 0..<count {
            assignments.append(
                seeder.createAssignment(
                    courseId: course.id,
                    assignementBody: .init(
                        name: "\(grading_type?.rawValue.capitalized ?? "Sample") Assignment \(i)",
                        description: "This is a description for Assignment \(i)",
                        published: true,
                        points_possible: points_possible?[i] ?? 100,
                        grading_type: grading_type)))
        }
        return assignments
    }

    public static func gradeAssignments(grades: [String], course: DSCourse, assignments: [DSAssignment], user: DSUser) {
        for i in 0..<assignments.count {
            seeder.postGrade(
                courseId: course.id,
                assignmentId: assignments[i].id,
                userId: user.id,
                requestBody: .init(posted_grade: grades[i]))
        }
    }

    public static func navigateToAssignments(course: DSCourse) {
        let courseCard = Dashboard.courseCard(id: course.id).waitToExist()
        courseCard.tap()
        let assignmentsButton = CourseNavigation.assignments.waitToExist()
        assignmentsButton.tap()
    }

    public static func navigateToGrades(course: DSCourse) {
        let courseCard = Dashboard.courseCard(id: course.id).waitToExist()
        courseCard.tap()
        let gradesButton = CourseNavigation.grades.waitToExist()
        gradesButton.tap()
    }
}
