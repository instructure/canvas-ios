//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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

struct RubricsView: View {
    let currentScore: Double
    let containerFrameInGlobal: CGRect
    @ObservedObject var viewModel: RubricsViewModel

    @Environment(\.appEnvironment) var env
    @Environment(\.viewController) var controller

    var body: some View {
        HStack {
            Text("Rubrics", bundle: .teacher)
                .font(.semibold16).foregroundColor(.textDarkest)
                .accessibilityAddTraits(.isHeader)
            Spacer()

            if viewModel.isSaving {
                ProgressView()
                    .progressViewStyle(.indeterminateCircle(size: 18))
            }
        }
        .padding(.horizontal, RubricPadding.horizontal)
        .padding(.vertical, RubricPadding.vertical)

        VStack(spacing: RubricSpacing.vertical) {
            ForEach(viewModel.criterionViewModels) { viewModel in
                RubricCriterionView(
                    containerFrameInGlobal: containerFrameInGlobal,
                    viewModel: viewModel
                )
            }
        }
        .multilineTextAlignment(.leading)
        .padding(.horizontal, RubricPadding.horizontal)
        .onAppear {
            viewModel.controller = controller
        }
    }
}
