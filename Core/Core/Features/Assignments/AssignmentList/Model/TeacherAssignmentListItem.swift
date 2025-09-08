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
import SwiftUI

struct TeacherAssignmentListItem: Equatable, Identifiable {

    struct SubAssignmentRow: Equatable, Identifiable {
        let tag: String
        let title: String
        let dueDate: String
        let needsGrading: String?
        let pointsPossible: String?

        var id: String { tag }
    }

    let id: String
    let title: String
    let icon: Image
    let isPublished: Bool

    let dueDate: String
    let needsGrading: String?
    let pointsPossible: String?

    let route: URL?

    init(
        assignment: Assignment,
        dueDateFormatter: DueDateFormatter = DueDateFormatterLive()
    ) {
        self.id = assignment.id
        self.title = assignment.name
        self.icon = assignment.icon.asImage
        self.isPublished = assignment.published
        self.dueDate = dueDateFormatter.format(
            assignment.dueAt,
            lockDate: assignment.lockAt,
            hasMultipleDueDates: assignment.hasMultipleDueDates
        )
        self.needsGrading = assignment.needsGradingText
        let hasPointsPossible = assignment.pointsPossible != nil
        self.pointsPossible = hasPointsPossible ? assignment.pointsPossibleCompleteText : nil
        self.route = assignment.htmlURL
    }
}

private extension Assignment {
    var needsGradingText: String? {
        guard needsGradingCount > 0, gradingType != .not_graded else {
            return nil
        }

        let format = String(localized: "d_needs_grading", bundle: .core)
        return String.localizedStringWithFormat(format, needsGradingCount).localizedCapitalized
    }
}

#if DEBUG

extension TeacherAssignmentListItem {
    private init(
        id: String,
        title: String,
        icon: Image,
        isPublished: Bool,
        dueDate: String,
        needsGrading: String?,
        pointsPossible: String?,
        route: URL?
    ) {
        self.id = id
        self.title = title
        self.icon = icon
        self.isPublished = isPublished
        self.dueDate = dueDate
        self.needsGrading = needsGrading
        self.pointsPossible = pointsPossible
        self.route = route
    }

    public static func make(
        id: String = "",
        title: String = "",
        icon: Image = .emptyLine,
        isPublished: Bool = false,
        dueDate: String = "",
        needsGrading: String? = nil,
        pointsPossible: String? = nil,
        route: URL? = nil
    ) -> Self {
        self.init(
            id: id,
            title: title,
            icon: icon,
            isPublished: isPublished,
            dueDate: dueDate,
            needsGrading: needsGrading,
            pointsPossible: pointsPossible,
            route: route
        )
    }
}

#endif
