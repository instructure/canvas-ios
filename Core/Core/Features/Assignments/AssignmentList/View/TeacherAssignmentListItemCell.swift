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

struct TeacherAssignmentListItemCell: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private let model: TeacherAssignmentListItem
    private let isLastItem: Bool?
    private let action: () -> Void

    init(
        model: TeacherAssignmentListItem,
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
                    .publishedStateOverlay(isPublished: model.isPublished)
            },
            labels: {
                titleLabel
                dueDateLabels
                needsGradingAndPointsPossibleLine
            },
            isLastItem: isLastItem,
            action: action
        )
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
    private var needsGradingAndPointsPossibleLine: some View {
        switch (model.needsGrading, model.pointsPossible) {
        case (.some(let needsGrading), .some(let pointsPossible)):
            InstUI.JoinedSubtitleLabels(
                label1: { needsGradingTag(needsGrading) },
                label2: { pointsPossibleLabel(pointsPossible) },
                spacing: 8,
                dividerVerticalPadding: 4
            )
        case (.some(let needsGrading), .none):
            needsGradingTag(needsGrading)
        case (.none, .some(let pointsPossible)):
            pointsPossibleLabel(pointsPossible)
        case (.none, .none):
            SwiftUI.EmptyView()
        }
    }

    private func needsGradingTag(_ needsGrading: String) -> some View {
        Text(needsGrading)
            .font(.regular12)
            .foregroundColor(.textLightest)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(RoundedRectangle(cornerRadius: 16).applyTint())
            .padding(.top, 4)
            .padding(.bottom, 6)
    }

    private func pointsPossibleLabel(_ pointsPossible: String) -> some View {
        Text(pointsPossible)
            .font(.semibold16)
            .applyTint()
    }
}

extension TeacherAssignmentListItemCell: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.model == rhs.model
        && lhs.isLastItem == rhs.isLastItem
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
                isPublished: true,
                dueDates: [date],
                needsGrading: "7 Need Grading",
                pointsPossible: "256 points"
            ),
            .make(
                id: "2",
                title: "Discussion 2 - Only points",
                icon: .discussionLine,
                isPublished: false,
                dueDates: [date],
                pointsPossible: "256 points"
            ),
            .make(
                id: "3",
                title: "Quiz 3 - Only NeedsGrading",
                icon: .quizLine,
                dueDates: [date],
                needsGrading: "7 Need Grading"
            ),
            .make(
                id: "4",
                title: "No NeedsGrading, No points",
                icon: .quizLine,
                dueDates: [date]
            ),
            .make(
                id: "5",
                title: "Long titled assignment to test how layout behaves",
                icon: .assignmentLine,
                dueDates: [.loremIpsumMedium],
                needsGrading: .loremIpsumMedium,
                pointsPossible: .loremIpsumMedium
            )
        ]

        ForEach(rows) { row in
            TeacherAssignmentListItemCell(model: row, isLastItem: rows.last == row) { }
        }
    }
    .tint(.course10)
}

#endif
