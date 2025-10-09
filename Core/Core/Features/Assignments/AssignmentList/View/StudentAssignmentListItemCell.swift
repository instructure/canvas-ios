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

struct StudentAssignmentListItemCell: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private let model: StudentAssignmentListItem
    private let isLastItem: Bool?
    private let action: () -> Void

    init(
        model: StudentAssignmentListItem,
        isLastItem: Bool?,
        action: @escaping () -> Void
    ) {
        self.model = model
        self.isLastItem = isLastItem
        self.action = action
    }

    var body: some View {
        InstUI.ContextItemListCell(
            icon: {
                model.icon
                    .scaledIcon()
            },
            labels: {
                titleLabel
                dueDateLabels
                scoreAndStatusLine
            },
            isLastItem: isLastItem,
            action: action
        )
    }

    private var icon: some View {
        model.icon
            .scaledIcon()
            .applyTint()
    }

    private var titleLabel: some View {
        Text(model.title)
            .textStyle(.cellLabel)
    }

    private var dueDateLabels: some View {
        ForEach(Array(model.dueDates.enumerated()), id: \.offset) {
            Text($1)
        }
        .textStyle(.cellLabelSubtitle)
    }

    @ViewBuilder
    private var scoreAndStatusLine: some View {
        if let score = model.score {
            InstUI.JoinedSubtitleLabels(
                label1: { scoreLabel(score) },
                label2: { submissionStatusLabel }
            )
        } else {
            submissionStatusLabel
        }
    }

    private func scoreLabel(_ score: String) -> some View {
        Text(score)
            .font(.semibold16)
            .applyTint()
            .accessibilityLabel(model.scoreA11yLabel)
    }

    private var submissionStatusLabel: some View {
        SubmissionStatusLabel(model: model.submissionStatus)
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
                submissionStatus: .init(text: "Graded", icon: .completeSolid, color: .textSuccess),
                score: "42 / 100"
            ),
            .make(
                id: "2",
                title: "Assignment 2",
                icon: .assignmentLine,
                dueDates: [date],
                submissionStatus: .init(text: "My favorite custom status", icon: .flagLine, color: .textInfo),
                score: "123 456 / 1 000 000 (Some cool grade)"
            ),
            .make(
                id: "3",
                title: "Discussion 3",
                icon: .discussionLine,
                dueDates: [date],
                submissionStatus: .init(text: "Not Submitted", icon: .noSolid, color: .textDark)
            ),
            .make(
                id: "4",
                title: "Long titled assignment to test how layout behaves",
                icon: .assignmentLine,
                dueDates: [.loremIpsumMedium],
                submissionStatus: .init(text: .loremIpsumShort, icon: .completeSolid, color: .textSuccess),
                score: .loremIpsumMedium
            )
        ]

        ForEach(rows) { row in
            StudentAssignmentListItemCell(model: row, isLastItem: rows.last == row) { }
        }
    }
    .tint(.course10)
}

#endif
