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
    @ObservedObject var viewModel: RubricsViewModel
    @Environment(\.viewController) var controller
    @Environment(\.appEnvironment) var env

    var body: some View {
        header
        content
    }

    var header: some View {
        HStack {
            Text("Rubrics", bundle: .teacher)
                .font(.semibold16)
                .foregroundColor(.textDarkest)
                .accessibilityAddTraits(.isHeader)
            Spacer()

            if viewModel.isSaving {
                ProgressView()
                    .progressViewStyle(.indeterminateCircle(size: 18))
            }
        }
        .padding(.horizontal, RubricPadding.horizontal.rawValue)
        .padding(.vertical, RubricPadding.vertical.rawValue)
    }

    var content: some View {
        VStack(spacing: RubricSpacing.vertical.rawValue) {
            ForEach(viewModel.criterionViewModels) { viewModel in
                RubricCriterionView(viewModel: viewModel)
            }
        }
        .multilineTextAlignment(.leading)
        .padding(.horizontal, RubricPadding.horizontal.rawValue)
        .onAppear {
            viewModel.controller = controller
        }
    }
}
