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

struct StudentAssignmentListCell: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private let model: StudentAssignmentListRow
    private let isLastItem: Bool
    private let action: () -> Void

    init(
        model: StudentAssignmentListRow,
        isLastItem: Bool,
        action: @escaping () -> Void
    ) {
        self.model = model
        self.isLastItem = isLastItem
        self.action = action
    }

    var body: some View {
        VStack(spacing: 0) {
            Button {
                action()
            } label: {
                HStack(alignment: .top, spacing: 0) {
                    icon
                        .paddingStyle(.trailing, .cellIconText)

                    VStack(alignment: .leading, spacing: 2) {
                        titleLabel
                        dueDateLabel
                        submissionStatusLabel
                        if let score = model.score {
                            scoreLabel(score)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .paddingStyle(set: .iconCell)
                .contentShape(Rectangle())
            }
            .background(.backgroundLightest)
            .buttonStyle(.tintedContextButton)

            InstUI.Divider(isLast: isLastItem)
        }
        .accessibility(identifier: "AssignmentList.\(model.id)")
    }

    private var icon: some View {
        model.icon
            .scaledIcon()
            .applyTint()
    }

    private var titleLabel: some View {
        Text(model.title)
            .style(.textCellTitle)
            .textStyle(.cellLabel)
    }

    private var dueDateLabel: some View {
        Text(model.dueDate)
            .textStyle(.cellLabelSubtitle)
    }

    private var submissionStatusLabel: some View {
        SubmissionStatusLabel(model: model.submissionStatus)
    }

    private func scoreLabel(_ score: String) -> some View {
        Text(score)
            .font(.semibold16)
            .applyTint()
    }
}

// MARK: - Preview

#if DEBUG

#Preview {
    PreviewContainer {
        let date = Date.now.dateTimeString
        let rows: [StudentAssignmentListRow] = [
            .make(
                id: "1",
                title: "Assignment 1",
                icon: .assignmentLine,
                dueDate: date,
                submissionStatus: .init(text: "Graded", icon: .completeSolid, color: .textSuccess),
                score: "42 / 100"
            ),
            .make(
                id: "2",
                title: "Discussion 2",
                icon: .discussionLine,
                dueDate: date,
                submissionStatus: .init(text: "Not Submitted", icon: .noSolid, color: .textDark)
            ),
            .make(
                id: "3",
                title: "Long titled assignment to test how layout behaves",
                icon: .assignmentLine,
                dueDate: .loremIpsumMedium,
                submissionStatus: .init(text: .loremIpsumMedium, icon: .completeSolid, color: .textSuccess),
                score: .loremIpsumMedium
            )
        ]

        ForEach(rows) { row in
            StudentAssignmentListCell(model: row, isLastItem: rows.last == row) { }
        }
    }
    .tint(.course10)
}

#endif
