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

    struct SubItem: Equatable, Identifiable {
        let tag: String
        let title: String

        let dueDate: String
        let pointsPossible: String?

        var id: String { tag }
    }

    let id: String
    let title: String
    let icon: Image
    let isPublished: Bool

    let dueDates: [String]
    let needsGrading: String?
    let pointsPossible: String?

    let subItems: [SubItem]?

    let route: URL?

    init(
        assignment: Assignment,
        dateTextsProvider: AssignmentDateTextsProvider = .live
    ) {
        let hasSubAssignments = assignment.hasSubAssignments

        self.id = assignment.id
        self.title = assignment.name
        self.icon = assignment.icon.asImage
        self.isPublished = assignment.published

        self.dueDates = dateTextsProvider.summarizedDueDates(for: assignment)

        let canBeGraded = assignment.gradingType != .not_graded
        self.needsGrading = canBeGraded ? String.format(needsGrading: assignment.needsGradingCount) : nil
        self.pointsPossible = String.format(points: assignment.pointsPossible)
        self.route = assignment.htmlURL

        if hasSubAssignments {
            self.subItems = assignment.checkpoints
                .map { checkpoint in
                    SubItem(
                        tag: checkpoint.tag,
                        title: checkpoint.title,
                        dueDate: DueDateFormatter.format(
                            checkpoint.dueDate,
                            lockDate: checkpoint.lockDate,
                            hasOverrides: checkpoint.overrides.isNotEmpty
                        ),
                        pointsPossible: String.format(points: checkpoint.pointsPossible)
                    )
                }
        } else {
            self.subItems = nil
        }
    }
}

#if DEBUG

extension TeacherAssignmentListItem {
    private init(
        id: String,
        title: String,
        icon: Image,
        isPublished: Bool,
        dueDates: [String],
        needsGrading: String?,
        pointsPossible: String?,
        subItems: [SubItem]?,
        route: URL?
    ) {
        self.id = id
        self.title = title
        self.icon = icon
        self.isPublished = isPublished
        self.dueDates = dueDates
        self.needsGrading = needsGrading
        self.pointsPossible = pointsPossible
        self.subItems = subItems
        self.route = route
    }

    public static func make(
        id: String = "",
        title: String = "",
        icon: Image = .emptyLine,
        isPublished: Bool = false,
        dueDates: [String] = [],
        needsGrading: String? = nil,
        pointsPossible: String? = nil,
        subItems: [SubItem]? = nil,
        route: URL? = nil
    ) -> Self {
        self.init(
            id: id,
            title: title,
            icon: icon,
            isPublished: isPublished,
            dueDates: dueDates,
            needsGrading: needsGrading,
            pointsPossible: pointsPossible,
            subItems: subItems,
            route: route
        )
    }
}

extension TeacherAssignmentListItem.SubItem {
    public static func make(
        tag: String = "",
        title: String = "",
        dueDate: String = "",
        pointsPossible: String? = nil
    ) -> Self {
        self.init(
            tag: tag,
            title: title,
            dueDate: dueDate,
            pointsPossible: pointsPossible
        )
    }
}

#endif
