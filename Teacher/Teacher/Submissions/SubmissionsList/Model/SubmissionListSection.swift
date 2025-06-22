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
import Core

struct SubmissionListSection: Identifiable {

    enum Kind: String, CaseIterable {
        case submitted
        case unsubmitted
        case graded
        case others // Keep this case the last

        var title: String {
            switch self {
            case .submitted:
                return String(localized: "Submitted", bundle: .teacher)
            case .unsubmitted:
                return String(localized: "Not Submitted", bundle: .teacher)
            case .graded:
                return String(localized: "Graded", bundle: .teacher)
            case .others:
                return String(localized: "Others", bundle: .teacher)
            }
        }

        var filter: (Submission) -> Bool {
            switch self {
            case .submitted:
                { $0.submittedAt != nil && $0.isGraded == false }
            case .unsubmitted:
                { $0.workflowState == .unsubmitted }
            case .graded:
                { $0.isGraded }
            case .others:
                { submission in
                    let matchesTheOtherCases = Self
                        .allCases
                        .dropLast()
                        .contains(where: { $0.filter(submission) })
                    return matchesTheOtherCases == false
                }
            }
        }
    }

    let kind: Kind
    var items: [SubmissionListItem]
    var isCollapsed: Bool

    var id: String { kind.rawValue }

    init(kind: Kind, items: [SubmissionListItem], isCollapsed: Bool = false) {
        self.kind = kind
        self.items = items
        self.isCollapsed = isCollapsed
    }
}
