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

struct TeacherAssignmentListCell: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @ScaledMetric private var uiScale: CGFloat = 1

    private let model: TeacherAssignmentListRow
    private let isLastItem: Bool
    private let action: () -> Void

    init(
        model: TeacherAssignmentListRow,
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
                        needsGradingAndPointsPossibleLine
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
            .publishedStateOverlay(isPublished: model.isPublished)
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

    @ViewBuilder
    private var needsGradingAndPointsPossibleLine: some View {
        switch (model.needsGrading, model.pointsPossible) {
        case (.some(let needsGrading), .some(let pointsPossible)):
            HStack(alignment: .center, spacing: 2) {
                needsGradingTag(needsGrading)
                InstUI.SubtitleTextDivider(padding: 8)
                    .frame(maxHeight: 16 * uiScale)
                pointsPossibleLabel(pointsPossible)
            }
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
            .padding(.horizontal, 10).padding(.vertical, 4)
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

// MARK: - Preview

#if DEBUG

#Preview {
    PreviewContainer {
        let date = Date.now.dateTimeString
        let rows: [TeacherAssignmentListRow] = [
            .make(
                id: "1",
                title: "Assignment 1",
                icon: .assignmentLine,
                isPublished: true,
                dueDate: date,
                needsGrading: "7 Need Grading",
                pointsPossible: "256 points"
            ),
            .make(
                id: "2",
                title: "Discussion 2 - Only points",
                icon: .discussionLine,
                isPublished: false,
                dueDate: date,
                pointsPossible: "256 points"
            ),
            .make(
                id: "3",
                title: "Quiz 3 - Only NeedsGrading",
                icon: .quizLine,
                dueDate: date,
                needsGrading: "7 Need Grading"
            ),
            .make(
                id: "4",
                title: "No NeedsGrading, No points",
                icon: .quizLine,
                dueDate: date
            ),
            .make(
                id: "5",
                title: "Long titled assignment to test how layout behaves",
                icon: .assignmentLine,
                dueDate: .loremIpsumMedium,
                needsGrading: .loremIpsumMedium,
                pointsPossible: .loremIpsumMedium
            )
        ]

        ForEach(rows) { row in
            TeacherAssignmentListCell(model: row, isLastItem: rows.last == row) { }
        }
    }
    .tint(.course10)
}

#endif
