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

struct RubricRatingView: View {
    @ObservedObject var viewModel: RubricRatingViewModel
    let leading: (ViewDimensions) -> CGFloat
    let top: (ViewDimensions) -> CGFloat
    let containerFrameInGlobal: CGRect

    var body: some View {
        let value = Text(viewModel.value)
        RubricRectangle(
            isOn: $viewModel.isSelected,
            containerFrame: containerFrameInGlobal
        ) {
            value
        }
        .accessibility(value: value)
        .accessibility(label: Text(viewModel.accessibilityLabel))
        .alignmentGuide(.leading, computeValue: leading)
        .alignmentGuide(.top, computeValue: top)
    }
}
