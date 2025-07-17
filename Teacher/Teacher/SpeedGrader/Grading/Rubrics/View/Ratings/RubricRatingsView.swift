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

struct RubricRatingsView: View {
    @ObservedObject var viewModel: RubricCriterionViewModel
    var isExpanded: Bool
    let selectedRating: RubricRatingViewModel?

    init(viewModel: RubricCriterionViewModel, isExpanded: Bool) {
        self.viewModel = viewModel
        self.isExpanded = isExpanded
        self.selectedRating = viewModel.ratingViewModels.first(where: \.isSelected)
    }

    var body: some View {
        if isExpanded {
            expanded
        } else {
            collapsed
        }
    }

    var collapsed: some View {
        VStack(alignment: .leading) {
            HStack(spacing: RubricSpacing.horizontal) {
                ForEach(viewModel.ratingViewModels) { ratingViewModel in
                    RubricRatingView(viewModel: ratingViewModel, isExpanded: isExpanded)
                }
            }
            if let selectedRating {
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(.tint)
                    Text(selectedRating.tooltip)
                        .font(.regular14)
                        .foregroundColor(.textLightest)
                        .padding(RubricPadding.vertical)
                }
            }
        }
        .padding(.horizontal, RubricPadding.horizontal)
    }

    var expanded: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(viewModel.longDescription)
            ForEach(viewModel.ratingViewModels) { ratingViewModel in
                RubricRatingView(viewModel: ratingViewModel, isExpanded: isExpanded)
                if let lastRatingViewModel = viewModel.ratingViewModels.last, ratingViewModel != lastRatingViewModel {
                    InstUI.Divider()
                        .padding(.horizontal, RubricPadding.horizontal)
                }
            }
        }
    }
}
