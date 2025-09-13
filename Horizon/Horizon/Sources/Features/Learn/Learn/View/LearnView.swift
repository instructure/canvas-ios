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

import Core
import SwiftUI
import HorizonUI

struct LearnView: View {
    @Bindable var viewModel: LearnViewModel
    let isBackButtonVisible: Bool

    var body: some View {
        VStack(spacing: .zero) {
            if !viewModel.isLoaderVisible {
                switch viewModel.state {
                case .programs:
                    ProgramView(viewModel: viewModel, isBackButtonVisible: isBackButtonVisible)
                case .courseDetails:
                    if let courseDetailsViewModel = viewModel.courseDetailsViewModel {
                        LearnAssembly.makeCourseDetailsView(viewModel: courseDetailsViewModel, isBackButtonVisible: false)
                    }
                case .empty:
                    emptyView
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onFirstAppear { viewModel.featchPrograms() }
        .background(Color.huiColors.surface.pagePrimary)
        .toolbar(.hidden)
        .overlay {
            if viewModel.isLoaderVisible {
                HorizonUI.Spinner(size: .small, showBackground: true)
                    .padding(.horizontal, .huiSpaces.space24)
                    .padding(.top, .huiSpaces.space10)
                    .padding(.bottom, .huiSpaces.space4)
                    .background(Color.huiColors.surface.pagePrimary)
            }
        }
    }

    private var emptyView: some View {
        ScrollView {
            Text("You aren’t currently enrolled in a course or program.", bundle: .horizon)
                .padding(.huiSpaces.space24)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .foregroundStyle(Color.huiColors.text.body)
                .huiTypography(.h3)
                .padding(.top, .huiSpaces.space32)
        }
        .refreshable {
            await viewModel.fetchPrograms(ignoreCache: true)
        }
    }
}

#if DEBUG
#Preview {
    LearnView(
        viewModel: .init(
            interactor: ProgramInteractorPreview(),
            learnCoursesInteractor: GetLearnCoursesInteractorPreview(),
            router: AppEnvironment.shared.router,
            programID: nil
        ),
        isBackButtonVisible: true
    )
}
#endif
