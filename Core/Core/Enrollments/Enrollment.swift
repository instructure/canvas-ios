//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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

final public class Enrollment: NSManagedObject {
    @NSManaged public var id: String?
    @NSManaged public var canvasContextID: String?
    @NSManaged public var role: String?
    @NSManaged public var roleID: String?
    @NSManaged public var stateRaw: String?
    @NSManaged public var userID: String?
    @NSManaged public var multipleGradingPeriodsEnabled: Bool
    @NSManaged public var currentGradingPeriodID: String?
    @NSManaged public var totalsForAllGradingPeriodsOption: Bool
    @NSManaged public var type: String
    @NSManaged public var course: Course?
    @NSManaged public var courseSectionID: String?
    @NSManaged public var grades: Set<Grade>
    @NSManaged public var observedUser: User?
    @NSManaged public var isFromInvitation: Bool
    @NSManaged public var lastActivityAt: Date?

    @NSManaged public var computedCurrentScoreRaw: NSNumber?
    @NSManaged public var computedCurrentGrade: String?
    @NSManaged public var computedCurrentLetterGrade: String?
    @NSManaged public var computedFinalScoreRaw: NSNumber?
    @NSManaged public var computedFinalGrade: String?

    @NSManaged public var currentPeriodComputedCurrentScoreRaw: NSNumber?
    @NSManaged public var currentPeriodComputedCurrentGrade: String?
    @NSManaged public var currentPeriodComputedFinalScoreRaw: NSNumber?
    @NSManaged public var currentPeriodComputedFinalGrade: String?

    @NSManaged public var submissions: Set<Submission>

    public var hideQuantitativeData: Bool {
        course?.hideQuantitativeData == true
    }
}

extension Enrollment {
    public var state: EnrollmentState {
        get { return EnrollmentState(rawValue: stateRaw ?? "") ?? .inactive }
        set { stateRaw = newValue.rawValue }
    }

    public var computedCurrentScore: Double? {
        get { return computedCurrentScoreRaw?.doubleValue }
        set { computedCurrentScoreRaw = NSNumber(value: newValue) }
    }

    public var computedFinalScore: Double? {
        get { return computedFinalScoreRaw?.doubleValue }
        set { computedFinalScoreRaw = NSNumber(value: newValue) }
    }

    public var currentPeriodComputedCurrentScore: Double? {
        get { return currentPeriodComputedCurrentScoreRaw?.doubleValue }
        set { currentPeriodComputedCurrentScoreRaw = NSNumber(value: newValue) }
    }

    public var currentPeriodComputedFinalScore: Double? {
        get { return currentPeriodComputedFinalScoreRaw?.doubleValue }
        set { currentPeriodComputedFinalScoreRaw = NSNumber(value: newValue) }
    }

    public var isStudent: Bool {
        return type.lowercased().contains("student")
    }

    public var isTeacher: Bool {
        return type.lowercased().contains("teacher")
    }

    public var isTA: Bool {
        return type.lowercased().contains("ta")
    }

    /// The localized, human-readable `role` or the custom role
    public var formattedRole: String? {
        guard let role = role else { return nil }
        return Role(rawValue: role)?.description()
    }

    public var currentScore: Double? {
        grades.first { $0.gradingPeriodID == currentGradingPeriodID }?.currentScore
    }

    public func finalGrade(gradingPeriodID: String?) -> String? {
        return grades.first { $0.gradingPeriodID == gradingPeriodID }?.finalGrade
    }

    public func currentScore(gradingPeriodID: String?) -> Double? {
        return grades.first { $0.gradingPeriodID == gradingPeriodID }?.currentScore
    }

    public func currentGrade(gradingPeriodID: String?) -> String? {
        grades.first { $0.gradingPeriodID == gradingPeriodID }?.currentGrade
    }

    public func formattedCurrentScore(gradingPeriodID: String?) -> String {
        let notAvailable = NSLocalizedString("N/A", bundle: .core, comment: "")
        if gradingPeriodID == nil, multipleGradingPeriodsEnabled, !totalsForAllGradingPeriodsOption {
            return notAvailable
        }
        if let score = currentScore(gradingPeriodID: gradingPeriodID) {
            return Course.scoreFormatter.string(from: NSNumber(value: score)) ?? notAvailable
        }
        return notAvailable
    }

    public func convertedLetterGrade(gradingPeriodID: String?, gradingScheme: [GradingSchemeEntry]) -> String {
        let notAvailable = NSLocalizedString("N/A", bundle: .core, comment: "")
        if gradingPeriodID == nil, multipleGradingPeriodsEnabled, !totalsForAllGradingPeriodsOption {
            return notAvailable
        }
        if let score = currentScore(gradingPeriodID: gradingPeriodID) {
            let normalizedScore = score / 100.0
            return gradingScheme.convertScoreToLetterGrade(score: normalizedScore) ?? notAvailable
        }
        return notAvailable
    }

    public func convertedLetterGrade(scorePercentage: Double, gradingScheme: [GradingSchemeEntry]) -> String {
        let notAvailable = NSLocalizedString("N/A", bundle: .core, comment: "")
        let normalizedScore = scorePercentage / 100.0
        return gradingScheme.convertScoreToLetterGrade(score: normalizedScore) ?? notAvailable
    }
}

extension Enrollment {
    func update(fromApiModel item: APIEnrollment, course: Course?, gradingPeriodID: String? = nil, in client: NSManagedObjectContext) {
        id = item.id?.value
        role = item.role
        roleID = item.role_id
        state = item.enrollment_state
        type = item.type
        userID = item.user_id.value
        courseSectionID = item.course_section_id?.value
        lastActivityAt = item.last_activity_at

        if let courseID = item.course_id?.value ?? course?.id {
            canvasContextID = "course_\(courseID)"
        }

        self.course = course

        if let apiGrades = item.grades {
            let grade = grades.first { $0.gradingPeriodID == gradingPeriodID } ?? client.insert()
            grade.currentGrade = apiGrades.current_grade
            grade.finalGrade = apiGrades.final_grade
            grade.unpostedCurrentGrade = apiGrades.unposted_current_grade
            grade.overrideGrade = apiGrades.override_grade
            grade.currentScore = apiGrades.current_score
            grade.finalScore = apiGrades.final_score
            grade.unpostedCurrentScore = apiGrades.unposted_current_score
            grade.overrideScore = apiGrades.override_score
            grade.gradingPeriodID = gradingPeriodID
            grades.insert(grade)
        } else {
            multipleGradingPeriodsEnabled = item.multiple_grading_periods_enabled ?? false
            currentGradingPeriodID = item.current_grading_period_id
            totalsForAllGradingPeriodsOption = item.totals_for_all_grading_periods_option ?? false

            computedCurrentLetterGrade = item.computed_current_letter_grade
            computedCurrentGrade = item.computed_current_grade
            computedFinalGrade = item.computed_final_grade
            currentPeriodComputedCurrentGrade = item.current_period_computed_current_grade
            currentPeriodComputedFinalGrade = item.current_period_computed_final_grade

            let grade = grades.first { $0.gradingPeriodID == nil } ?? client.insert()
            grade.gradingPeriodID = nil
            grade.currentScore = item.computed_current_score
            computedCurrentScore = item.computed_current_score
            computedFinalScore = item.computed_final_score
            currentPeriodComputedCurrentScore = item.current_period_computed_current_score
            currentPeriodComputedFinalScore = item.current_period_computed_final_score

            grades.insert(grade)
            if let currentGradingPeriodID = item.current_grading_period_id {
                let currentPeriodGrade = grades.first { $0.gradingPeriodID == currentGradingPeriodID } ?? client.insert()
                currentPeriodGrade.gradingPeriodID = currentGradingPeriodID
                currentPeriodGrade.currentScore = hideQuantitativeData ? nil : item.current_period_computed_current_score
                grades.insert(currentPeriodGrade)
            }
        }

        if let apiObservedUser = item.observed_user {
            let observedUserModel = User.save(apiObservedUser, in: client)
            observedUser = observedUserModel
        } else {
            observedUser = nil
        }

        if let courseID = item.course_id?.value ?? course?.id {
            let submissions: [Submission] = client.fetch(NSPredicate(format: "%K == %@ AND %K == %@",
                #keyPath(Submission.assignment.courseID), courseID,
                #keyPath(Submission.userID), item.user_id.value
            ))
            self.submissions.formUnion(submissions)
        }
    }
}
