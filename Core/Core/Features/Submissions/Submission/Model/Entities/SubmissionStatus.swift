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
    case notSubmitted
    case submitted
    case late
    case missing
    case graded
    case excused
    case custom(id: String, name: String)
    case onPaper
    case noSubmission

    public init(
        isLate: Bool,
        isMissing: Bool,
        isExcused: Bool,
        isSubmitted: Bool,
        isGraded: Bool,
        customStatusId: String?,
        customStatusName: String?,
        submissionType: SubmissionType?,
        isGradeBelongToCurrentSubmission: Bool
    ) {
        self = if isExcused {
            .excused
        } else if let customStatusId, let customStatusName {
            .custom(id: customStatusId, name: customStatusName)
        // graded should have priority over late/missing, but currently
        // all other places in Student app check for late/missing before checking for graded.
        // We should move the `isGraded` check up here once SubmissionStatus is unified in MBL-19323.
        // This logic is currently used only in Student Assignment List, so it won't cause issues in Teacher.
        } else if isLate {
            .late
        } else if isMissing {
            .missing
        } else if isGraded {
            isGradeBelongToCurrentSubmission ? .graded : .submitted
        } else if isSubmitted {
            .submitted
        } else if submissionType == .on_paper {
            .onPaper
        } else if submissionType == SubmissionType.none {
            .noSubmission
        } else {
            .notSubmitted
        }
    }

    public var isGraded: Bool {
        switch self {
        case .excused,
             .custom,
             .graded:
            true
        case .late,
             .missing,
             .submitted,
             .notSubmitted,
             .onPaper,
             .noSubmission:
            false
        }
    }
}

// MARK: - View Model

extension SubmissionStatus {
    public var text: String {
        switch self {
        case .notSubmitted: String(localized: "Not Submitted", bundle: .core)
        case .submitted: String(localized: "Submitted", bundle: .core)
        case .late: String(localized: "Late", bundle: .core)
        case .missing: String(localized: "Missing", bundle: .core)
        case .graded: String(localized: "Graded", bundle: .core)
        case .excused: String(localized: "Excused", bundle: .core)
        case .custom(_, let name): name
        case .onPaper: String(localized: "On Paper", bundle: .core)
        case .noSubmission: String(localized: "No Submission", bundle: .core)
        }
    }

    public var color: Color {
        switch self {
        case .notSubmitted: .textDark
        case .submitted: .textSuccess
        case .late: .textWarning
        case .missing: .textDanger
        case .graded: .textSuccess
        case .excused: .textWarning
        case .custom: .textInfo
        case .onPaper: .textDark
        case .noSubmission: .textDark
        }
    }

    public var icon: Image {
        switch self {
        case .notSubmitted: .noSolid
        case .submitted: .completeLine
        case .late: .clockLine
        case .missing: .noSolid
        case .graded: .completeSolid
        case .excused: .completeSolid
        case .custom: .flagLine
        case .onPaper: .noSolid
        case .noSubmission: .noSolid
        }
    }

    // TODO: remove once not needed
    public var uiImageIcon: UIImage {
        switch self {
        case .notSubmitted: .noSolid
        case .submitted: .completeLine
        case .late: .clockLine
        case .missing: .noSolid
        case .graded: .completeSolid
        case .excused: .completeSolid
        case .custom: .flagLine
        case .onPaper: .noSolid
        case .noSubmission: .noSolid
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
