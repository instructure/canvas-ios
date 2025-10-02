//
// This file is part of Canvas.
// Copyright (C) 2021-present  Instructure, Inc.
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

struct StudentAssignmentListSubItemCell: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private let model: StudentAssignmentListItem.SubItem
    private let action: () -> Void

    init(
        model: StudentAssignmentListItem.SubItem,
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
                scoreAndStatusLine
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

    @ViewBuilder
    private var scoreAndStatusLine: some View {
        switch (model.score, model.submissionStatus) {
        case (.some(let score), .some(let status)):
            InstUI.JoinedSubtitleLabels(
                label1: { scoreLabel(score) },
                label2: { submissionStatusLabel(status) }
            )
        case (.some(let score), .none):
            scoreLabel(score)
        case (.none, .some(let status)):
            submissionStatusLabel(status)
        case (.none, .none):
            SwiftUI.EmptyView()
        }
    }

    private func submissionStatusLabel(_ model: SubmissionStatusLabel.Model) -> some View {
        SubmissionStatusLabel(model: model)
    }

    private func scoreLabel(_ score: String) -> some View {
        Text(score)
            .font(.semibold16)
            .applyTint()
            .accessibilityLabel(model.scoreA11yLabel)
    }
}

// MARK: - Preview

#if DEBUG

#Preview {
    PreviewContainer {
        let date = Date.now.dateTimeString
        let rows: [StudentAssignmentListItem] = [
            .make(
                id: "1",
                title: "Assignment 1",
                icon: .assignmentLine,
                dueDates: [date],
                submissionStatus: .init(status: .graded),
                score: "42 / 100",
                subItems: [
                    .make(tag: "a", title: "Sub-assignment A", dueDate: date, submissionStatus: .init(status: .graded), score: "42 / 100")
                ]
            ),
            .make(
                id: "2",
                title: "Assignment 2",
                icon: .assignmentLine,
                dueDates: [date],
                submissionStatus: .init(status: .excused),
                subItems: [
                    .make(tag: "a", title: "Sub-assignment A", dueDate: date, submissionStatus: .init(status: .graded), score: "42 / 100"),
                    .make(tag: "b", title: "Sub-assignment B", dueDate: date, submissionStatus: .init(status: .excused))
                ]
            )
        ]

        ForEach(rows) { row in
            InstUI.CollapsibleListRow(
                cell: StudentAssignmentListItemCell(model: row, isLastItem: nil) {},
                isInitiallyExpanded: true
            ) {
                ForEach(row.subItems ?? []) { subItem in
                    StudentAssignmentListSubItemCell(model: subItem) {}
                }
            }
            InstUI.Divider()
        }
    }
    .tint(.course10)
}

#endif
