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

public enum SubmissionStatus: Equatable {

    // MARK: - NOT SUBMITTED (no grade)

    /// not submitted but submittable, before due date, no grade
    case notSubmitted

    /// not submitted for assignment type "On Paper", regardless of due date, no grade
    case onPaper

    /// not submitted for assignment type "No Submission", regardless of due date, no grade
    case noSubmission

    /// not submitted for assignment grading type "Not Graded", regardless of due date, no grade
    case notGradable

    /// not submitted, usually after due date, no grade
    /// (Teacher can mark any submission Missing, regardless of due date or submission type)
    case missing

    /// not submitted, marked Late by teacher, regardless of due date, no grade
    /// (It is an edge case needed for needsGrading calculation)
    case lateButNotSubmitted

    // MARK: - SUBMITTED (no grade)

    /// submitted, before due date, no grade
    case submitted

    /// submitted, usually after due date, no grade
    /// (Teachers can mark any submission Late, regardless of due date or submission type)
    case late

    /// submitted, marked Missing by teacher, regardless of due date, no grade
    /// (It is an edge case needed for needsGrading calculation)
    case missingButSubmitted

    // MARK: - GRADED

    /// graded, regardless of submission or due date
    case graded

    /// graded, marked Missing by teacher, regardless of submission or due date
    case gradedMissing

    /// graded, marked Late, regardless of submission or due date
    case gradedLate

    /// excused, regardless of submission or due date
    case excused

    /// custom status, regardless of submission or due date
    case custom(id: String, name: String)

    // MARK: - Init

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
        self = if isExcused {
            .excused
        } else if let customStatusId, let customStatusName {
            .custom(id: customStatusId, name: customStatusName)
        } else if isGraded && isGradeBelongsToCurrentSubmission {
            if isLate {
                .gradedLate
            } else if isMissing {
                .gradedMissing
            } else {
                .graded
            }
        } else if isLate {
            if isSubmitted {
                .late
            } else {
                .lateButNotSubmitted
            }
        } else if isMissing {
            if isSubmitted {
                .missingButSubmitted
            } else {
                .missing
            }
        } else if isSubmitted {
            .submitted
        } else {
            if submissionType == .on_paper {
                .onPaper
            } else if submissionType == SubmissionType.none {
                .noSubmission
            } else if submissionType == .not_graded {
                .notGradable
            } else {
                .notSubmitted
            }
        }
    }
}

// MARK: - Computed properties

extension SubmissionStatus {

    // TODO: uncomment and replace Submission.isGraded with this one in MBL-19323
    /// Returns `true` for all graded statuses, including `excused` and `custom` too.
    public var isGraded: Bool {
        switch self {
        case .graded,
             .gradedMissing,
             .gradedLate,
             .excused,
             .custom:
            true
        case .notSubmitted,
             .onPaper,
             .noSubmission,
             .notGradable,
             .missing,
             .lateButNotSubmitted,
             .submitted,
             .late,
             .missingButSubmitted:
            false
        }
    }

    /// Returns `true` for all submitted statuses which are not graded.
    public var isSubmittedButNotGraded: Bool {
        switch self {
        case .submitted,
             .late,
             .missingButSubmitted:
            true
        case .notSubmitted,
             .onPaper,
             .noSubmission,
             .notGradable,
             .missing,
             .lateButNotSubmitted,
             .graded,
             .gradedLate,
             .gradedMissing,
             .custom,
             .excused:
            false
        }
    }

    /// Returns `true` for all not submitted but submittable statuses which are not graded.
    public var isNotSubmittedNotGraded: Bool {
        switch self {
        case .notSubmitted,
             .missing,
             .lateButNotSubmitted:
            true
        case
             .onPaper,
             .noSubmission,
             .notGradable,
             .submitted,
             .late,
             .missingButSubmitted,
             .graded,
             .gradedLate,
             .gradedMissing,
             .custom,
             .excused:
            false
        }
    }

    /// Returns `true` for all not submittable statuses which are not graded, marked Missing or Late.
    public var isNotSubmittable: Bool {
        switch self {
        case .onPaper,
             .noSubmission,
             .notGradable:
            true
        case .notSubmitted,
             .missing,
             .lateButNotSubmitted,
             .submitted,
             .late,
             .missingButSubmitted,
             .graded,
             .gradedMissing,
             .gradedLate,
             .custom,
             .excused:
            false
        }
    }

    /// Returns `true` for any late statuses, regardless of graded or not.
    /// Late does not require an actual submission, because teachers can mark a submission Late any time.
    public var isLate: Bool {
        switch self {
        case .late,
             .lateButNotSubmitted,
             .gradedLate:
            true
        case .notSubmitted,
             .onPaper,
             .noSubmission,
             .notGradable,
             .missing,
             .submitted,
             .missingButSubmitted,
             .graded,
             .gradedMissing,
             .custom,
             .excused:
            false
        }
    }

    /// Returns `true` for any missing statuses, regardless of graded or not.
    /// Missing does not necessarily mean there is no submission, because teachers can mark a submission Missing any time.
    public var isMissing: Bool {
        switch self {
        case .missing,
             .missingButSubmitted,
             .gradedMissing:
            true
        case .notSubmitted,
             .onPaper,
             .noSubmission,
             .notGradable,
             .lateButNotSubmitted,
             .submitted,
             .late,
             .graded,
             .gradedLate,
             .custom,
             .excused:
            false
        }
    }

    /// Returns `true` for excused status.
    public var isExcused: Bool {
        self == .excused
    }

    /// Returns `true` for custom statuses.
    public var isCustom: Bool {
        if case .custom = self {
            return true
        }
        return false
    }
}

// MARK: - View Model

extension SubmissionStatus {
    public var viewModel: SubmissionStatusLabel.Model {
        switch self {
        case .notSubmitted:
            .init(
                text: String(localized: "Not Submitted", bundle: .core),
                icon: .noSolid,
                color: .textDark
            )
        case .submitted:
            .init(
                text: String(localized: "Submitted", bundle: .core),
                icon: .completeLine,
                color: .textSuccess
            )
        case .late, .lateButNotSubmitted, .gradedLate:
            .init(
                text: String(localized: "Late", bundle: .core),
                icon: .clockLine,
                color: .textWarning
            )
        case .missing, .missingButSubmitted, .gradedMissing:
            .init(
                text: String(localized: "Missing", bundle: .core),
                icon: .noSolid,
                color: .textDanger
            )
        case .graded:
            .init(
                text: String(localized: "Graded", bundle: .core),
                icon: .completeSolid,
                color: .textSuccess
            )
        case .excused:
            .init(
                text: String(localized: "Excused", bundle: .core),
                icon: .completeSolid,
                color: .textWarning
            )
        case .custom(_, let name):
            .init(
                text: name,
                icon: .flagLine,
                color: .textInfo
            )
        case .onPaper:
            .init(
                text: String(localized: "On Paper", bundle: .core),
                icon: .noSolid,
                color: .textDark
            )
        case .noSubmission:
            .init(
                text: String(localized: "No Submission", bundle: .core),
                icon: .noSolid,
                color: .textDark
            )
        case .notGradable:
            .init(
                text: String(localized: "Not Graded", bundle: .core),
                icon: .noSolid,
                color: .textDark
            )
        }
    }

    // TODO: remove once not needed
    public var uiImageIcon: UIImage {
        switch self {
        case .notSubmitted: .noSolid
        case .submitted: .completeLine
        case .late, .lateButNotSubmitted, .gradedLate: .clockLine
        case .missing, .missingButSubmitted, .gradedMissing: .noSolid
        case .graded: .completeSolid
        case .excused: .completeSolid
        case .custom: .flagLine
        case .onPaper: .noSolid
        case .noSubmission: .noSolid
        case .notGradable: .noSolid
        }
    }
}

// MARK: - To be removed in MBL-19323

public enum SubmissionStatusOld: Hashable {
    case late
    case missing
    case submitted
    case notSubmitted
    case graded
    case excused
    case custom(String)

    public var text: String {
        switch self {
        case .late:
            return String(localized: "Late", bundle: .core)
        case .missing:
            return String(localized: "Missing", bundle: .core)
        case .submitted:
            return String(localized: "Submitted", bundle: .core)
        case .notSubmitted:
            return String(localized: "Not Submitted", bundle: .core)
        case .excused:
            return String(localized: "Excused", bundle: .core)
        case .custom(let name):
            return name
        case .graded:
            return String(localized: "Graded", bundle: .core)
        }
    }

    public var color: UIColor {
        switch self {
        case .late:
            return .textWarning
        case .missing:
            return .textDanger
        case .submitted:
            return .textSuccess
        case .notSubmitted:
            return .textDark
        case .excused:
            return .textWarning
        case .custom:
            return .textInfo
        case .graded:
            return .textSuccess
        }
    }

    public var icon: UIImage {
        switch self {
        case .submitted:
            return .completeLine
        case .late:
            return .clockSolid
        case .missing, .notSubmitted:
            return .noSolid
        case .excused, .graded:
            return .completeSolid
        case .custom:
            return .flagLine
        }
    }

    public var isCustom: Bool {
        if case .custom = self { return true }
        return false
    }
}
