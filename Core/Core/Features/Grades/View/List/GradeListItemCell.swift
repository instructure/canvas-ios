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

struct GradeListItemCell: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private let model: StudentAssignmentListItem
    private let whatIfModel: GradeListWhatIfModel?
    private let isLastItem: Bool?
    private let action: () -> Void

    init(
        model: StudentAssignmentListItem,
        whatIfModel: GradeListWhatIfModel?,
        isLastItem: Bool?,
        action: @escaping () -> Void
    ) {
        self.model = model
        self.whatIfModel = whatIfModel
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
            accessory: {
                if whatIfModel?.isEnabled ?? false {
                    editWhatIfScoreButton
                }
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

    private var editWhatIfScoreButton: some View {
        Button {
            whatIfModel?.editScoreAction()
        } label: {
            Image.editLine
                .scaledIcon(size: 20)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityAction(named: Text("Edit What-if score", bundle: .core)) {
            whatIfModel?.editScoreAction()
        }
        .accessibilityAction(named: Text("Revert to official score", bundle: .core)) {
            whatIfModel?.revertScoreAction(model.id)
        }
    }

    // WhatIf feature is not supported as of now.
    // Keeping this here to keep an example of the now unused implementation.
    // It's supposed to work by calling `.onSwipe(trailing: revertWhatIfScoreSwipeButton)` inside the button's label.
    // But it does not work. This may be removed or salvaged later.
    private var revertWhatIfScoreSwipeButton: [SwipeModel] {
        guard let whatIfModel, whatIfModel.isEnabled else { return [] }

        return [
            SwipeModel(
                id: model.id,
                image: { Image.replyLine },
                action: { whatIfModel.revertScoreAction(model.id) },
                style: .init(background: .backgroundDark)
            )
        ]
    }
}

// MARK: - Preview

#if DEBUG

#Preview {
    PreviewContainer {
        let date = Date.now.dateTimeString
        let whatIfModel = GradeListWhatIfModel(isEnabled: true, editScoreAction: {}, revertScoreAction: { _ in })
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
            GradeListItemCell(model: row, whatIfModel: nil, isLastItem: rows.last == row) { }
        }
        GradeListItemCell(model: rows[0], whatIfModel: whatIfModel, isLastItem: false) { }
        GradeListItemCell(model: rows[3], whatIfModel: whatIfModel, isLastItem: true) { }
    }
    .tint(.course10)
}

#endif
