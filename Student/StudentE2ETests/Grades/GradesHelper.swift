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

public class GradesHelper: BaseHelper {
    public static func checkForTotalGrade(totalGrade: String) {
        sleep(3)
        pullToRefresh()
        GradeList.totalGrade(totalGrade: totalGrade).waitToExist(3)
    }

    public static func createSubmissionsForAssignments(course: DSCourse, student: DSUser, assignments: [DSAssignment]) {
        for assignment in assignments {
            seeder.createSubmission(courseId: course.id, assignmentId: assignment.id, requestBody:
                .init(submission_type: .online_text_entry, body: "This is a submission body", user_id: student.id))
        }
    }
}
