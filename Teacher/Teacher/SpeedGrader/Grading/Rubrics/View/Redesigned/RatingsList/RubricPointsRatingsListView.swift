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
import Core

struct RubricPointsRatingsListView: View {

    @Binding var isExpanded: Bool
    @ObservedObject var viewModel: RedesignedRubricCriterionViewModel

    var body: some View {

        if isExpanded {

            VStack(spacing: 0) {
                let ratingModels = Array(viewModel.ratingViewModels.reversed())
                let lastRatingId = ratingModels.last?.id
                ForEach(ratingModels) { ratingViewModel in
                    RubricRatingExpandedView(viewModel: ratingViewModel)
                    InstUI.Divider(ratingViewModel.id == lastRatingId ? .hidden : .padded)
                }
            }
            .padding(.bottom, 8)

            InstUI.Divider()

        } else {
            FlowLayout(spacing: 16, minimumLineSpacing: 16) {
                ForEach(viewModel.ratingViewModels) { ratingViewModel in
                    RedesignedRubricRatingView(viewModel: ratingViewModel)
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
        }

        if let bubble = viewModel.userRatingBubble, isExpanded == false {

            VStack(alignment: .leading) {
                Text(bubble.title)
                    .font(.semibold16)
                    .foregroundStyle(Color.textLightest)

                if bubble.subtitle.isNotEmpty {
                    Text(bubble.subtitle)
                        .font(.regular14)
                        .foregroundStyle(Color.textLightest)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(content: {
                RoundedRectangle(cornerRadius: 24).fill(.tint)
            })
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
    }
}
