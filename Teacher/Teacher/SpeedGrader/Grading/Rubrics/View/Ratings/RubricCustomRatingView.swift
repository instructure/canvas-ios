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

struct RubricCustomRatingView: View {
    @ObservedObject var viewModel: RubricCustomRatingViewModel
    let leading: (ViewDimensions) -> CGFloat
    let top: (ViewDimensions) -> CGFloat

    var body: some View {
        let isOnBinding = Binding(
            get: {
                viewModel.state.isSelected
            },
            set: { isSelected in
                if isSelected {
                    viewModel.didTapAddCustomScoreButton()
                } else {
                    viewModel.didTapClearCustomScoreButton()
                }
            }
        )

        return RubricCircle(isOn: isOnBinding) {
            switch viewModel.state {
            case .addCustomRating:
                Image.addSolid
            case .value(let value):
                Text(value)
            }
        }
        .accessibilityLabel(Text("Add custom grade", bundle: .teacher))
        .accessibilityRemoveTraits(.isImage)
        .alignmentGuide(.leading, computeValue: leading)
        .alignmentGuide(.top, computeValue: top)
    }
}
