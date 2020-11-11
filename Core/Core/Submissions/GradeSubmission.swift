//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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
import CoreData

public class GradeSubmission: APIUseCase {
    public typealias Model = Submission

    let courseID: String
    let assignmentID: String
    let userID: String
    let excused: Bool?
    let grade: String?
    let rubricAssessment: APIRubricAssessmentMap?

    public var cacheKey: String? { nil }
    public var request: PutSubmissionGradeRequest {
        PutSubmissionGradeRequest(courseID: courseID, assignmentID: assignmentID, userID: userID, body: .init(
            submission: .init(excuse: excused, posted_grade: grade),
            rubric_assessment: rubricAssessment
        ))
    }

    public init(
        courseID: String,
        assignmentID: String,
        userID: String,
        excused: Bool? = nil,
        grade: String? = nil,
        rubricAssessment: APIRubricAssessmentMap? = nil
    ) {
        self.courseID = courseID
        self.assignmentID = assignmentID
        self.userID = userID
        self.excused = excused
        self.grade = grade
        self.rubricAssessment = rubricAssessment
    }
}
