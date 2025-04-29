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

import HorizonUI
import SwiftUI

struct ScoresView: View {
    @Bindable var viewModel: ScoresViewModel
    @Environment(\.viewController) private var viewController

    var body: some View {
        ScrollView(showsIndicators: false) {
            switch viewModel.viewState {
            case .loading:
                loadingView
            case .data:
                if let details = viewModel.scoreDetails {
                    if details.assignments.isEmpty {
                        emptyScoreView
                    } else {
                        VStack(spacing: .huiSpaces.space24) {
                            ScoresAssignmentGroupsView(details: details)
                            ScoresAssignmentsView(
                                details: details,
                                selectedSortOption: $viewModel.selectedSortOption
                            ) { url in
                                viewModel.navigateToCourseDetails(url: url, viewController: viewController)
                            }
                        }
                    }
                }
            case .error:
                Text("Error loading scores.", bundle: .horizon)
            }
        }
    }

    private var emptyScoreView: some View {
        Text("There are no scored activities in this course.", bundle: .horizon)
            .frame(maxWidth: .infinity, alignment: .leading)
            .huiTypography(.p1)
            .foregroundStyle(Color.huiColors.text.body)
            .padding(.huiSpaces.space24)
            .background(Color.huiColors.primitives.white10)
            .huiCornerRadius(level: .level5)
    }

    private var loadingView: some View {
        VStack {
            Spacer()
            HorizonUI.Spinner(
                size: .small,
                showBackground: true
            )
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .containerRelativeFrame(.vertical)
    }
}

#Preview {
    ScoresAssembly.makePreview()
}
