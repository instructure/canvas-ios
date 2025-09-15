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

import Foundation
import CoreData

public class CDSubAssignmentSubmission: NSManagedObject {

    @NSManaged public var submissionId: String
    @NSManaged public var userId: String
    @NSManaged public var subAssignmentTag: String

    // Status
    @NSManaged public var isExcused: Bool
    @NSManaged public var isLate: Bool
    @NSManaged private var latePolicyStatusRaw: String?
    public var latePolicyStatus: LatePolicyStatus? {
        get { .init(rawValue: latePolicyStatusRaw) } set { latePolicyStatusRaw = newValue?.rawValue }
    }
    @NSManaged public var lateSeconds: Int
    @NSManaged public var isMissing: Bool
    @NSManaged public var submittedAt: Date?
    @NSManaged public var customGradeStatusId: String?
    @NSManaged public var customGradeStatusName: String?

    // Score
    @NSManaged private var enteredScoreRaw: NSNumber?
    public var enteredScore: Double? {
        get { enteredScoreRaw?.doubleValue } set { enteredScoreRaw = .init(newValue) }
    }
    @NSManaged private var scoreRaw: NSNumber?
    public var score: Double? {
        get { scoreRaw?.doubleValue } set { scoreRaw = .init(newValue) }
    }
    @NSManaged private var publishedScoreRaw: NSNumber?
    public var publishedScore: Double? {
        get { publishedScoreRaw?.doubleValue } set { publishedScoreRaw = .init(newValue) }
    }

    // Grade
    @NSManaged public var enteredGrade: String?
    @NSManaged public var grade: String?
    @NSManaged public var publishedGrade: String?
    @NSManaged public var gradeMatchesCurrentSubmission: Bool

    public var status: SubmissionStatus {
        .init(
            isLate: isLate,
            isMissing: isMissing,
            isExcused: isExcused,
            isSubmitted: submittedAt != nil,
            isGraded: score != nil,
            customStatusId: customGradeStatusId,
            customStatusName: customGradeStatusName,
            submissionType: nil,
            isGradeBelongToCurrentSubmission: gradeMatchesCurrentSubmission
        )
    }

    // MARK: - Save

    @discardableResult
    public static func save(
        _ item: APISubAssignmentSubmission,
        submissionId: String,
        in moContext: NSManagedObjectContext
    ) -> Self {
        let predicate = NSPredicate(\CDSubAssignmentSubmission.submissionId, equals: submissionId)
            .and(NSPredicate(\CDSubAssignmentSubmission.userId, equals: item.user_id.value))
            .and(NSPredicate(\CDSubAssignmentSubmission.subAssignmentTag, equals: item.sub_assignment_tag))
        let model: Self = moContext.fetch(predicate).first ?? moContext.insert()

        model.submissionId = submissionId
        model.userId = item.user_id.value
        model.subAssignmentTag = item.sub_assignment_tag

        model.isExcused = item.excused ?? false
        model.isLate = item.late ?? false
        model.latePolicyStatus = item.late_policy_status
        model.lateSeconds = item.seconds_late ?? 0
        model.isMissing = item.missing ?? false
        model.submittedAt = item.submitted_at

        model.customGradeStatusId = item.custom_grade_status_id
        if let customStatusId = item.custom_grade_status_id {
            let customStatus: CDCustomGradeStatus? = moContext
                .first(where: \CDCustomGradeStatus.id, equals: customStatusId)
            model.customGradeStatusName = customStatus?.name
        }

        model.enteredScore = item.entered_score
        model.score = item.score
        model.publishedScore = item.published_score

        model.enteredGrade = item.entered_grade
        model.grade = item.grade
        model.publishedGrade = item.published_grade
        model.gradeMatchesCurrentSubmission = item.grade_matches_current_submission ?? false

        return model
    }
}
