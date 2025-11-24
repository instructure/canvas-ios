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
import UIKit
import SwiftUI

public struct SubmissionStatus: Equatable {
    public enum GradeStatus: Equatable {
        case excused
        case custom(id: String, name: String)
        case late
        case missing
    }

    public enum NonSubmittableType: Equatable {
        case onPaper
        case noSubmission
        case notGradable
    }

    public let isSubmitted: Bool
    public let hasGrade: Bool
    public let gradeStatus: GradeStatus?
    public let nonSubmittableType: NonSubmittableType?

    public init(
        isSubmitted: Bool,
        isGraded: Bool,
        isGradeBelongsToCurrentSubmission: Bool,
        isLate: Bool,
        isMissing: Bool,
        isExcused: Bool,
        customStatusId: String?,
        customStatusName: String?,
        submissionType: SubmissionType?
    ) {
        self.isSubmitted = isSubmitted
        self.hasGrade = isGraded && isGradeBelongsToCurrentSubmission

        self.gradeStatus = if isExcused {
            .excused
        } else if let customStatusId, let customStatusName {
            .custom(id: customStatusId, name: customStatusName)
        } else if isLate {
            .late
        } else if isMissing {
            .missing
        } else {
            nil
        }

        self.nonSubmittableType = switch submissionType {
        case .on_paper: .onPaper
        case .some(.none): .noSubmission
        case .not_graded: .notGradable
        default: nil
        }
    }
}

// MARK: - Default value

extension SubmissionStatus {
    public static let notSubmitted = Self(
        isSubmitted: false,
        isGraded: false,
        isGradeBelongsToCurrentSubmission: true,
        isLate: false,
        isMissing: false,
        isExcused: false,
        customStatusId: nil,
        customStatusName: nil,
        submissionType: nil
    )
}

// MARK: - Computed properties

extension SubmissionStatus {

    /// True if the teacher marks the submission Excused.
    /// Excused submissions are considered graded,
    /// but they can't have an actual regular grade.
    public var isExcused: Bool {
        gradeStatus == .excused
    }

    /// True if the teacher marks the submission with a custom status.
    /// Submissions with custom statuses are considered graded,
    /// whether they have an actual grade or not.
    public var isCustom: Bool {
        if case .custom = gradeStatus {
            return true
        }
        return false
    }

    /// True if there is a submission, due date is passed and it's not graded.
    /// Or if the teacher marks the submission Late, regardless of
    /// due date, submission, submission type or grade.
    public var isLate: Bool {
        gradeStatus == .late
    }

    /// True if there is no submission, due date is passed and it's not graded.
    /// Or if the teacher marks the submission Missing, regardless of
    /// due date, submission, submission type or grade.
    public var isMissing: Bool {
        gradeStatus == .missing
    }

    /// True if the submission is graded, excused or has a custom status.
    /// This means submissions considered graded may or may not have an actual grade.
    public var isGraded: Bool {
        hasGrade || isExcused || isCustom
    }

    /// True if there is a submission and it is not considered graded.
    public var needsGrading: Bool {
        isSubmitted && !isGraded
    }

    /// True if there is no submission, the assignment is submittable
    /// and it is not considered graded.
    public var needsSubmission: Bool {
        !isSubmitted && isTypeSubmittable && !isGraded
    }

    /// True if the assignment has an online submission type
    /// and its grading type is other than "Not Graded".
    public var isTypeSubmittable: Bool {
        nonSubmittableType == nil
    }

    /// True if the assignment is not submittable, the submission
    /// is not graded and not marked Excused / Custom / Late / Missing.
    public var isNotSubmittableWithNoGradeNoGradeStatus: Bool {
        nonSubmittableType != nil && !hasGrade && gradeStatus == nil
    }

    /// True if the assignment's grading type is "Not Graded"
    /// and the submission is not marked Excused / Custom / Late / Missing.
    public var isNotGradableWithNoGradeStatus: Bool {
        nonSubmittableType == .notGradable && gradeStatus == nil
    }
}

// MARK: - View Model

extension SubmissionStatus {

    /// The displayed status is always a single label, even though multiple properties
    /// can apply to a given submission. The order of priority is the following:
    /// - Grade statuses (Excused / Custom / Late / Missing)
    /// - Graded
    /// - Submitted
    /// - Non-submittable types (On Paper / No Submission / Not Graded)
    /// - Not Submitted
    public var labelModel: SubmissionStatusLabel.Model {
        if let gradeStatus {
            switch gradeStatus {
            case .excused: .excused
            case .custom(_, let name): .custom(name)
            case .late: .late
            case .missing: .missing
            }
        } else if hasGrade {
            .graded
        } else if isSubmitted {
            .submitted
        } else if let nonSubmittableType {
            switch nonSubmittableType {
            case .onPaper: .onPaper
            case .noSubmission: .noSubmission
            case .notGradable: .notGradable
            }
        } else {
            .notSubmitted
        }
    }

    // TODO: remove once not needed
    public var uiImageIcon: UIImage {
        switch labelModel.icon {
        case .completeSolid: .completeSolid
        case .completeLine: .completeLine
        case .noSolid: .noSolid
        case .flagLine: .flagLine
        case .clockLine: .clockLine
        default: .noSolid
        }
    }
}
