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
            HStack(alignment: .top, spacing: InstUI.Styles.Padding.standard.rawValue) {
                VStack(alignment: .leading, spacing: 2) {
                    courseLabel
                    assignmentTitle
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                grade
            }
            discussionCheckPointInfo
            bottomLabels
        }
        .paddingStyle(.horizontal, .standard)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
        .tint(assignment.courseColor)
    }

    private var courseLabel: some View {
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
    }

    private var assignmentTitle: some View {
        Text(assignment.title)
            .font(.semibold14, lineHeight: .fit)
            .foregroundStyle(Color.textDarkest)
            .multilineTextAlignment(.leading)
    }

    @ViewBuilder
    private var discussionCheckPointInfo: some View {
        if let stepText = assignment.discussionCheckpointText {
            Text(stepText)
                .font(.regular12)
                .foregroundStyle(Color.textDark)
        }
    }

    @ViewBuilder
    private var bottomLabels: some View {
        VStack(alignment: .leading, spacing: 2) {
            if let dueDateText = assignment.dueDateText, let statusModel = assignment.submissionStatus {
                InstUI.JoinedSubtitleLabels(
                    label1: { dueDateLabel(dueDateText) },
                    label2: { SubmissionStatusLabel(model: statusModel, iconSize: 12, font: .regular12) }
                )
            } else if let dueDateText = assignment.dueDateText {
                dueDateLabel(dueDateText)
            }

            if let pointsText = assignment.pointsPossible, let gradeWeightText = assignment.gradeWeightText {
                InstUI.JoinedSubtitleLabels(
                    label1: { pointsLabel(pointsText) },
                    label2: { gradeWeightPill(gradeWeightText) }
                )
            } else if let pointsText = assignment.pointsPossible {
                pointsLabel(pointsText)
            }
        }
    }

    @ViewBuilder
    private var grade: some View {
        if let grade = assignment.grade {
            Text(grade)
                .font(.semibold14, lineHeight: .fit)
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

    private func dueDateLabel(_ text: String) -> some View {
        Text(text)
            .font(.regular12)
            .foregroundStyle(Color.textDark)
    }
}

#if DEBUG

#Preview {
    let assignments: [WeeklySummaryWidgetAssignment] = [
        WeeklySummaryWidgetAssignment(
            id: "1",
            courseId: "101",
            courseCode: "BIO 101",
            courseColor: .course1,
            icon: .assignmentLine,
            title: "Lab Report: Cell Division",
            dueDateText: "Mar 20, 2026 at 11:59 PM",
            submissionStatus: .submitted,
            pointsPossible: "50 pts",
            grade: nil,
            gradeWeightText: "12.5% of final grade",
            discussionCheckpointText: "Reply to topic"
        ),
        WeeklySummaryWidgetAssignment(
            id: "2",
            courseId: "102",
            courseCode: "HIST 202",
            courseColor: .course3,
            icon: .discussionLine,
            title: "Week 5 Discussion: Industrial Revolution",
            dueDateText: "Mar 21, 2026 at 9:00 AM",
            submissionStatus: .graded,
            pointsPossible: "25 pts",
            grade: nil,
            gradeWeightText: nil,
            discussionCheckpointText: nil
        ),
        WeeklySummaryWidgetAssignment(
            id: "3",
            courseId: "103",
            courseCode: "MATH 301",
            courseColor: .course5,
            icon: .quizLine,
            title: "Midterm Quiz",
            dueDateText: nil,
            submissionStatus: nil,
            pointsPossible: "100 pts",
            grade: "88",
            gradeWeightText: "20% of final grade",
            discussionCheckpointText: nil
        )
    ]
    WeeklySummaryWidgetAssignmentListView(
        viewModel: WeeklySummaryWidgetViewModel(
            config: .make(id: .weeklySummary),
            router: PreviewEnvironment().router
        ),
        assignments: assignments,
        controller: WeakViewController()
    )
    .padding(16)
    .background(Color.backgroundLight)
}

#endif
