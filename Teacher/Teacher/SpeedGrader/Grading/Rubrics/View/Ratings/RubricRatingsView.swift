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
            if viewModel.shouldShowRubricRatings {
                HStack(spacing: RubricSpacing.horizontal.rawValue) {
                    ForEach(viewModel.ratingViewModels) { ratingViewModel in
                        RubricRatingView(
                            viewModel: ratingViewModel,
                            isExpanded: isExpanded
                        )
                    }
                }
            }
            if let selectedRating {
                selectedRatingLine
            }
        }
        .padding(.horizontal, RubricPadding.horizontal.rawValue)
    }

    var expanded: some View {
        VStack(alignment: .leading, spacing: 0) {
            if viewModel.hasLongDescription {
                Text(viewModel.longDescription)
                    .font(.regular14)
                    .padding(.horizontal, RubricPadding.horizontal.rawValue)
                    .padding(.vertical, RubricPadding.vertical.rawValue)
            }
            ForEach(viewModel.ratingViewModels) { ratingViewModel in
                RubricRatingView(
                    viewModel: ratingViewModel,
                    isExpanded: isExpanded
                )
                if let lastRatingViewModel = viewModel.ratingViewModels.last, ratingViewModel != lastRatingViewModel {
                    InstUI.Divider()
                        .padding(.horizontal, RubricPadding.horizontal.rawValue)
                }
            }
        }
    }

    var selectedRatingLine: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(selectedRating!.shortDescription)
                    .font(.semibold16)
                if selectedRating!.longDescription != "" {
                    Text(selectedRating!.longDescription)
                        .font(.regular14)
                }
            }
            Spacer()
        }
        .foregroundColor(.textLightest)
        .padding(RubricPadding.vertical.rawValue)
        .background(
            RoundedRectangle(cornerRadius: RubricSizes.rectangleCornerRadius.rawValue)
                .fill(.tint)
        )
    }
}
