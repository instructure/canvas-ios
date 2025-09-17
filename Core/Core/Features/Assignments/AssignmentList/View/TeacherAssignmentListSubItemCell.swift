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

import SwiftUI

struct TeacherAssignmentListSubItemCell: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private let model: TeacherAssignmentListItem.SubItem
    private let action: () -> Void

    init(
        model: TeacherAssignmentListItem.SubItem,
        action: @escaping () -> Void
    ) {
        self.model = model
        self.action = action
    }

    var body: some View {
        InstUI.ContextItemListSubItemCell(
            labels: {
                titleLabel
                dueDateLabel
                if let pointsPossible = model.pointsPossible {
                    pointsPossibleLabel(pointsPossible)
                }
            },
            action: action
        )
    }

    private var titleLabel: some View {
        Text(model.title)
            .textStyle(.cellLabel)
    }

    private var dueDateLabel: some View {
        Text(model.dueDate)
            .textStyle(.cellLabelSubtitle)
    }

    private func pointsPossibleLabel(_ pointsPossible: String) -> some View {
        Text(pointsPossible)
            .font(.semibold16)
            .applyTint()
    }
}

// MARK: - Preview

#if DEBUG

#Preview {
    PreviewContainer {
        let date = Date.now.dateTimeString
        let rows: [TeacherAssignmentListItem] = [
            .make(
                id: "1",
                title: "Assignment 1",
                icon: .assignmentLine,
                dueDates: [date],
                needsGrading: "5 Need Grading",
                pointsPossible: "100",
                subItems: [
                    .make(tag: "a", title: "Sub-assignment A", dueDate: date, pointsPossible: "100")
                ]
            ),
            .make(
                id: "2",
                title: "Assignment 2",
                icon: .assignmentLine,
                dueDates: [date],
                needsGrading: "1 Needs Grading",
                subItems: [
                    .make(tag: "a", title: "Sub-assignment A", dueDate: date, pointsPossible: nil),
                    .make(tag: "b", title: "Sub-assignment B", dueDate: date, pointsPossible: "40")
                ]
            )
        ]

        ForEach(rows) { row in
            InstUI.CollapsibleListRow(
                cell: TeacherAssignmentListItemCell(model: row, isLastItem: nil) {},
                isInitiallyExpanded: true
            ) {
                ForEach(row.subItems ?? []) { subItem in
                    TeacherAssignmentListSubItemCell(model: subItem) {}
                }
            }
            InstUI.Divider()
        }
    }
    .tint(.course10)
}

#endif
