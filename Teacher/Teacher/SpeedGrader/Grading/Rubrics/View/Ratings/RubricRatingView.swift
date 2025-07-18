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

struct RubricRatingView: View {
    @ObservedObject var viewModel: RubricRatingViewModel

    let isExpanded: Bool
    let value: Text
    let expandedFrameHeight: CGFloat

    init(viewModel: RubricRatingViewModel, isExpanded: Bool) {
        self.viewModel = viewModel
        self.isExpanded = isExpanded
        self.value = Text(viewModel.value)
        self.expandedFrameHeight = viewModel.hasLongDescription ? 90 : 70
    }

    var body: some View {
        if isExpanded {
            expanded
        } else {
            collapsed
        }
    }

    private var expanded: some View {
        HStack(alignment: .top, spacing: RubricSpacing.horizontal.rawValue) {
            if viewModel.shouldShowRubricRatings {
                rubricRectangle
            } else {
                InstUI.RadioButton(isSelected: viewModel.isSelected)
            }
            descriptionView
            Spacer()
        }
        .padding(.horizontal, RubricPadding.horizontal.rawValue)
        .padding(.vertical, RubricPadding.vertical.rawValue)
        .frame(minHeight: expandedFrameHeight, maxHeight: expandedFrameHeight)
        .background(rectangleView)
        .onTapGesture { viewModel.isSelected.toggle() }
    }

    private var collapsed: some View {
        rubricRectangle
            .onTapGesture { viewModel.isSelected.toggle() }
            .accessibility(addTraits: viewModel.isSelected ? [.isButton, .isSelected] : .isButton)
            .accessibility(value: value)
            .accessibility(label: Text(viewModel.accessibilityLabel))
    }

    private var rubricRectangle: some View {
        RubricRectangle(isOn: $viewModel.isSelected, changeBackgroundOnTap: !isExpanded) { value }
    }

    @ViewBuilder
    private var rectangleView: some View {
        let roundedRectangle = RoundedRectangle(cornerRadius: RubricSizes.rectangleCornerRadius.rawValue)
        if viewModel.isSelected, viewModel.shouldShowRubricRatings {
            roundedRectangle.fill(.tint)
        } else {
            roundedRectangle.fill(.background)
        }
    }

    private var descriptionView: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(viewModel.shortDescription)
                .font(.semibold16)
            Text(viewModel.longDescription)
                .font(.regular14)
        }
        .foregroundStyle(viewModel.isSelected && viewModel.shouldShowRubricRatings ? .textLightest : .textDarkest)
    }
}
