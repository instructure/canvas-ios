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

import UIKit

public protocol SubmissionViewable {
    var submission: Submission? { get }
    var submissionTypes: [SubmissionType] { get }
    var submissionTypesWithQuizLTIMapping: [SubmissionType] { get }
    var allowedExtensions: [String] { get }
}

extension SubmissionViewable {
    public var hasFileTypes: Bool {
        return submissionTypes.contains(.online_upload) && allowedExtensions.isEmpty == false
    }

    public var fileTypeText: String? {
        guard hasFileTypes else { return nil }
        return ListFormatter.localizedString(from: allowedExtensions, conjunction: .or)
    }

    public var submissionTypeText: String {
        let list = submissionTypesWithQuizLTIMapping.map { $0.localizedString }
        return ListFormatter.localizedString(from: list, conjunction: .or)
    }

    public var isSubmitted: Bool {
        return submission != nil && submission?.submittedAt != nil
    }

    public var submissionStatusIsHidden: Bool {
        return submissionTypes.contains(.not_graded)
    }

    public var submissionStatusColor: UIColor {
        return isSubmitted ? .textSuccess : .textDark
    }

    public var submissionStatusIcon: UIImage {
        if !isSubmitted {
            return .noSolid
        }

        if submission?.workflowState == .graded {
            return .completeSolid
        }

        return .completeLine
    }

    public var submissionStatusText: String {
        if !isSubmitted {
            return String(localized: "Not Submitted", bundle: .core)
        }

        if submission?.workflowState == .graded {
            return String(localized: "Graded", bundle: .core)
        }

        return String(localized: "Submitted", bundle: .core)
    }

    public var submissionDateText: String? {
        submission?.submittedAt?.dateTimeString
    }

    public var submissionAttemptNumberText: String? {
        guard let attempt = submission?.attempt else { return nil }

        return String.localizedAttemptNumber(attempt)
    }

    public var hasLatePenalty: Bool {
        return submission?.late == true && (submission?.pointsDeducted ?? 0) > 0
    }

    public var latePenaltyText: String? {
        guard submission?.late == true, let deducted = submission?.pointsDeducted else { return nil }
        let format = String(localized: "late_penalty_g_pts", bundle: .core)
        return String.localizedStringWithFormat(format, -deducted)
    }

    public var isSubmittable: Bool {
        return !submissionTypes.contains { [.none, .not_graded].contains($0) }
    }

    public var isExternalToolAssignment: Bool {
        return submissionTypes.contains(.external_tool)
    }
}
