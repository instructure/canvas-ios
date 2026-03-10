//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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

import Core
import SwiftUI

struct WeeklySummaryWidgetAssignmentListView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var viewModel: WeeklySummaryWidgetViewModel
    var assignments: [WeeklySummaryWidgetAssignment]
    var controller: WeakViewController

    var body: some View {
        VStack(spacing: 0) {
            ForEach(assignments) { item in
                Button {
                    viewModel.didTapAssignment(item, from: controller)
                } label: {
                    WeeklySummaryWidgetAssignmentCell(assignment: item)
                }
                .buttonStyle(.plain)
                InstUI.Divider(item.id != assignments.last?.id ? .padded : .hidden)
            }
        }
        .elevation(.cardLarge, background: .backgroundLightest)
    }
}

private struct WeeklySummaryWidgetAssignmentCell: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.displayScale) private var displayScale

    let assignment: WeeklySummaryWidgetAssignment

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            InstUI.JoinedSubtitleLabels(
                label1: {
                    assignment.icon
                        .scaledIcon(size: 16)
                },
                label2: {
                    Text(assignment.courseCode)
                        .font(.regular12)
                }
            )
            .applyTint()
            Text(assignment.title)
                .font(.semibold14, lineHeight: .fit)
                .foregroundStyle(Color.textDarkest)
                .multilineTextAlignment(.leading)
            bottomLabels
        }
        .paddingStyle(.horizontal, .standard)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
        .tint(assignment.courseColor)
    }

    @ViewBuilder
    private var bottomLabels: some View {
        VStack(alignment: .leading, spacing: 2) {
            if let dueDateText = assignment.dueDateText {
                Text(dueDateText)
                    .font(.regular12)
                    .foregroundStyle(Color.textDark)
            }

            if let pointsText = assignment.pointsText, let gradeWeightText = assignment.gradeWeightText {
                InstUI.JoinedSubtitleLabels(
                    label1: { pointsLabel(pointsText) },
                    label2: { gradeWeightPill(gradeWeightText) }
                )
            } else if let pointsText = assignment.pointsText {
                pointsLabel(pointsText)
            }
        }
    }

    private func pointsLabel(_ text: String) -> some View {
        Text(text)
            .font(.regular12)
            .foregroundStyle(Color.textDark)
    }

    private func gradeWeightPill(_ text: String) -> some View {
        InstUI.PillContent(title: text, size: .height20)
            .overlay(
                Capsule()
                    .stroke(assignment.courseColor, lineWidth: 1 / displayScale)
            )
    }
}

#if DEBUG

#Preview {
    let viewModel = WeeklySummaryWidgetViewModel(
        config: .make(id: .weeklySummary),
        router: PreviewEnvironment().router
    )
    WeeklySummaryWidgetAssignmentListView(
        viewModel: viewModel,
        assignments: viewModel.dueFilter.assignments,
        controller: WeakViewController()
    )
    .padding(16)
    .background(Color.backgroundLight)
}

#endif
