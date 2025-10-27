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

struct StudentAssignmentCheckpointsCardView: View {
    @Environment(\.dynamicTypeSize) var dynamicTypeSize
    let viewModel: StudentAssignmentCheckpointsViewModel

    init(viewModel: StudentAssignmentCheckpointsViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(viewModel.checkpointItems.enumerated()), id: \.element.id) { index, item in
                if index > 0 {
                    Divider()
                        .padding(.leading, 16)
                }

                checkpointRow(item)
            }
        }
        .elevation(.cardSmall, background: .backgroundLightestElevated)
        .padding(.horizontal, 16)
    }

    private func checkpointRow(_ item: StudentAssignmentCheckpointsViewModel.CheckpointItem) -> some View {
        HStack(alignment: .center, spacing: 0) {
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.regular14, lineHeight: .fit)
                    .foregroundColor(Color.textDarkest)

                SubmissionStatusLabel(model: item.statusLabel)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if let score = item.score {
                Text(score)
                    .font(.semibold16, lineHeight: .fit)
                    .foregroundColor(.brandPrimary)
            }
        }
        .padding(.top, 12)
        .padding(.bottom, 14)
        .padding(.horizontal, 16)
    }
}

#if DEBUG

struct StudentAssignmentCheckpointsCardView_Previews: PreviewProvider {
    static var previews: some View {
        let checkpoint1 = StudentAssignmentCheckpointsViewModel.CheckpointItem(
            id: "1",
            title: "Reply to topic",
            statusLabel: .init(status: .graded),
            score: "5/5"
        )

        let checkpoint2 = StudentAssignmentCheckpointsViewModel.CheckpointItem(
            id: "2",
            title: "Additional replies (3)",
            statusLabel: .init(status: .graded),
            score: "2.5/5"
        )

        let viewModel = StudentAssignmentCheckpointsViewModel(checkpointItems: [checkpoint1, checkpoint2])

        return StudentAssignmentCheckpointsCardView(viewModel: viewModel)
            .background(Color.gray.opacity(0.1))
            .previewLayout(.sizeThatFits)
    }
}

#endif
