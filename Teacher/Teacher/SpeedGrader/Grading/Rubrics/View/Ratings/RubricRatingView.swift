//
// This file is part of Canvas.
<<<<<<<< HEAD:packages/HorizonUI/Sources/HorizonUI/Sources/Components/Spinner/HorizonUI.Spinner.Size.swift
// Copyright (C) 2024-present  Instructure, Inc.
========
// Copyright (C) 2025-present  Instructure, Inc.
>>>>>>>> origin/master:Teacher/Teacher/SpeedGrader/Grading/Rubrics/View/Ratings/RubricRatingView.swift
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

<<<<<<<< HEAD:packages/HorizonUI/Sources/HorizonUI/Sources/Components/Spinner/HorizonUI.Spinner.Size.swift
public extension HorizonUI.Spinner {
    enum Size {
        case xSmall
        case small
        case medium
        case large

        var dimension: CGFloat {
            switch self {
            case .xSmall: return 20
            case .small: return 42
            case .medium: return 70
            case .large: return 96
            }
        }

        var strokeWidth: CGFloat {
            switch self {
            case .xSmall: return 2
            case .small: return 4
            case .medium: return 6
            case .large: return 8
            }
========
struct RubricRatingView: View {
    @ObservedObject var viewModel: RubricRatingViewModel
    let leading: (ViewDimensions) -> CGFloat
    let top: (ViewDimensions) -> CGFloat
    let containerFrameInGlobal: CGRect

    var body: some View {
        let value = Text(viewModel.value)
        RubricCircle(
            isOn: $viewModel.isSelected,
            tooltip: viewModel.tooltip,
            containerFrame: containerFrameInGlobal
        ) {
            value
>>>>>>>> origin/master:Teacher/Teacher/SpeedGrader/Grading/Rubrics/View/Ratings/RubricRatingView.swift
        }
        .accessibility(value: value)
        .accessibility(label: Text(viewModel.accessibilityLabel))
        .alignmentGuide(.leading, computeValue: leading)
        .alignmentGuide(.top, computeValue: top)
    }
}
