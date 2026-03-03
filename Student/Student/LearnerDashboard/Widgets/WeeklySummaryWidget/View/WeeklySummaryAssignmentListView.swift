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

struct WeeklySummaryAssignmentListView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var viewModel: WeeklySummaryWidgetViewModel
    var assignments: [WeeklySummaryAssignment]
    var controller: WeakViewController

    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(assignments.enumerated()), id: \.element.id) { index, item in
                Button {
                    viewModel.didTapAssignment(item, from: controller)
                } label: {
                    WeeklySummaryAssignmentRow(assignment: item)
                }
                .buttonStyle(.plain)
                if index < assignments.count - 1 {
                    InstUI.Divider(.padded)
                }
            }
        }
        .elevation(.cardLarge, background: .backgroundLightest)
    }
}

private struct WeeklySummaryAssignmentRow: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.displayScale) private var displayScale

    let assignment: WeeklySummaryAssignment

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 4) {
                assignment.icon
                    .scaledIcon(size: 16)
                    .foregroundStyle(assignment.courseColor)
                InstUI.SubtitleTextDivider()
                    .scaledFrame(height: 12)
                    .padding(.vertical, 1)
                Text(assignment.courseCode)
                    .font(.regular12)
                    .foregroundStyle(assignment.courseColor)
            }
            Text(assignment.title)
                .font(.semibold14)
                .foregroundStyle(Color.textDarkest)
                .multilineTextAlignment(.leading)
            bottomRow
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private var bottomRow: some View {
        HStack(spacing: 4) {
            if let dueDateText = assignment.dueDateText {
                Text(dueDateText)
                    .font(.regular12)
                    .foregroundStyle(Color.textDark)
            }
            if let pointsText = assignment.pointsText {
                if assignment.dueDateText != nil {
                    InstUI.SubtitleTextDivider()
                        .scaledFrame(height: 12)
                }
                Text(pointsText)
                    .font(.regular12)
                    .foregroundStyle(Color.textDark)
            }
            if let gradeWeightText = assignment.gradeWeightText {
                InstUI.SubtitleTextDivider()
                    .scaledFrame(height: 12)
                Text(gradeWeightText)
                    .font(.regular12)
                    .foregroundStyle(assignment.courseColor)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .overlay(
                        Capsule()
                            .stroke(assignment.courseColor, lineWidth: 1 / displayScale)
                    )
            }
        }
    }
}

#if DEBUG

#Preview {
    let viewModel = WeeklySummaryWidgetViewModel(
        config: .make(id: .weeklySummary),
        router: PreviewEnvironment().router
    )
    WeeklySummaryAssignmentListView(
        viewModel: viewModel,
        assignments: viewModel.dueFilter.assignments,
        controller: WeakViewController()
    )
    .padding(16)
    .background(Color.backgroundLight)
}

#endif
