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

import Core
import SwiftUI

struct StudentSubAssignmentsCardView: View {
    @Environment(\.dynamicTypeSize) var dynamicTypeSize

    private let viewModel: StudentSubAssignmentsCardViewModel
    private let contextColor: Color?

    init(viewModel: StudentSubAssignmentsCardViewModel, contextColor: Color?) {
        self.viewModel = viewModel
        self.contextColor = contextColor
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(viewModel.items) { item in
                StudentSubAssignmentsCardItemCell(model: item)
                InstUI.Divider(viewModel.items.last == item ? .hidden : .padded)
            }
        }
        .tint(contextColor)
        .elevation(.cardSmall, background: .backgroundLightestElevated)
        .paddingStyle(.horizontal, .standard)
    }
}

private struct StudentSubAssignmentsCardItemCell: View {
    @Environment(\.dynamicTypeSize) var dynamicTypeSize

    let model: StudentSubAssignmentsCardItem

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            VStack(alignment: .leading, spacing: 2) {
                titleLabel
                if let status = model.submissionStatus {
                    submissionStatusLabel(status)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if let score = model.score {
                scoreLabel(score)
            }
        }
        .paddingStyle(set: .standardCell)
        .accessibilityElement(children: .combine)
    }

    private var titleLabel: some View {
        Text(model.title)
            .font(.regular14, lineHeight: .fit)
            .foregroundStyle(.textDarkest)
    }

    private func submissionStatusLabel(_ status: SubmissionStatusLabel.Model) -> some View {
        SubmissionStatusLabel(model: status)
    }

    private func scoreLabel(_ score: String) -> some View {
        Text(score)
            .font(.semibold16)
            .applyTint()
            .accessibilityLabel(model.scoreA11yLabel)
    }
}

#if DEBUG

#Preview {
    PreviewContainer {
        let viewModel = StudentSubAssignmentsCardViewModel(items: [
            .make(
                id: "1",
                title: "Reply to topic",
                submissionStatus: .init(status: .graded),
                score: "5/5"
            ),
            .make(
                id: "2",
                title: "Additional replies (3)",
                submissionStatus: .init(status: .notSubmitted),
                score: "2.5/5"
            ),
            .make(
                id: "3",
                title: "Another step",
                submissionStatus: .init(status: .excused),
                score: nil
            )
        ])

        StudentSubAssignmentsCardView(viewModel: viewModel, contextColor: .orange)
    }
}

#endif
