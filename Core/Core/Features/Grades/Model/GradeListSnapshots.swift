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

import Snapshots

struct CourseSnapshot: Snapshot {
    let attributes: Course.Snapshot

    let enrollments: [EnrollmentSnapshot]?

    init(model: Course) {
        self.attributes = model.snapshot
        self.enrollments = model.enrollments?.map(EnrollmentSnapshot.init)
    }

    func enrollmentForGrades(userId: String?, includingCompleted: Bool = false) -> EnrollmentSnapshot? {
        func first(of state: EnrollmentState) -> EnrollmentSnapshot? {
            enrollments?.first {
                let attributes = $0.attributes

                return attributes.state == state &&
                attributes.userID == userId &&
                attributes.type.lowercased().contains("student") &&
                attributes.id == nil
            }
        }

        if let enrollment = first(of: .active) {
            return enrollment
        } else if includingCompleted {
            return first(of: .completed)
        } else {
            return nil
        }
    }
}

public struct AssignmentSnapshot: Snapshot {
    let attributes: Assignment.Snapshot
    let submission: SubmissionSnapshot?
    let submissions: [SubmissionSnapshot]?
    let assignmentGroup: AssignmentGroup.Snapshot?
    let checkpoints: [AssignmentCheckpointSnapshot]

    public init(model: Assignment) {
        self.attributes = model.snapshot
        self.submission = model.submission.map(SubmissionSnapshot.init)
        self.submissions = model.submissions.map { $0.map(SubmissionSnapshot.init) }
        self.assignmentGroup = model.assignmentGroup?.snapshot
        self.checkpoints = model.checkpoints.map(AssignmentCheckpointSnapshot.init)
    }
}

public struct AssignmentCheckpointSnapshot: Snapshot {
    let attributes: CDAssignmentCheckpoint.Snapshot
    let overrides: [AssignmentOverride.Snapshot]

    public init(model: CDAssignmentCheckpoint) {
        attributes = model.snapshot
        overrides = model.overrides.snapshots()
    }
}

public struct SubmissionSnapshot: Snapshot {
    let attributes: Submission.Snapshot
    let assignment: Assignment.Snapshot?
    let subAssignmentSubmissions: [CDSubAssignmentSubmission.Snapshot]

    var userID: String? { attributes.userID }

    public init(model: Submission) {
        self.attributes = model.snapshot
        self.assignment = model.assignment?.snapshot
        self.subAssignmentSubmissions = model.subAssignmentSubmissions.snapshots()
    }
}

struct EnrollmentSnapshot: Snapshot {
    let attributes: Enrollment.Snapshot
    let grades: [Grade.Snapshot]

    init(model: Enrollment) {
        self.attributes = model.snapshot
        self.grades = model.grades.snapshots()
    }

    var multipleGradingPeriodsEnabled: Bool { attributes.multipleGradingPeriodsEnabled }
    var totalsForAllGradingPeriodsOption: Bool { attributes.totalsForAllGradingPeriodsOption }

    public func finalScore(gradingPeriodID: String?) -> Double? {
        return grades.first { $0.gradingPeriodID == gradingPeriodID }?.finalScore
    }

    public func currentScore(gradingPeriodID: String?) -> Double? {
        return grades.first { $0.gradingPeriodID == gradingPeriodID }?.currentScore
    }

    public func currentGrade(gradingPeriodID: String?) -> String? {
        grades.first { $0.gradingPeriodID == gradingPeriodID }?.currentGrade
    }

    public func finalGrade(gradingPeriodID: String?) -> String? {
        return grades.first { $0.gradingPeriodID == gradingPeriodID }?.finalGrade
    }

    // Used when "Base on graded assignment" is ON
    public func formattedCurrentScore(gradingPeriodID: String?, gradingScheme: any GradingScheme) -> String {
        let notAvailable = String(localized: "N/A", bundle: .core)
        if gradingPeriodID == nil, multipleGradingPeriodsEnabled, !totalsForAllGradingPeriodsOption {
            return notAvailable
        }
        if let score = currentScore(gradingPeriodID: gradingPeriodID) {
            return gradingScheme.formattedScore(from: score) ?? notAvailable
        }
        return notAvailable
    }

    // Used when "Base on graded assignment" is OFF
    public func formattedFinalScore(gradingPeriodID: String?, gradingScheme: any GradingScheme) -> String {
        let notAvailable = String(localized: "N/A", bundle: .core)
        if gradingPeriodID == nil, multipleGradingPeriodsEnabled, !totalsForAllGradingPeriodsOption {
            return notAvailable
        }
        if let score = finalScore(gradingPeriodID: gradingPeriodID) {
            return gradingScheme.formattedScore(from: score) ?? notAvailable
        }
        return notAvailable
    }

    // Used when "Base on graded assignment" is ON
    public func convertedLetterGrade(gradingPeriodID: String?, gradingScheme: any GradingScheme) -> String {
        let notAvailable = String(localized: "N/A", bundle: .core)
        if gradingPeriodID == nil, multipleGradingPeriodsEnabled, !totalsForAllGradingPeriodsOption {
            return notAvailable
        }
        if let score = currentScore(gradingPeriodID: gradingPeriodID) {
            let normalizedScore = score / 100.0
            return gradingScheme.convertNormalizedScoreToLetterGrade(normalizedScore) ?? notAvailable
        }
        return notAvailable
    }
}
