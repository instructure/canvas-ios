//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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

struct CourseListView: View {
    @ObservedObject private var viewModel: CourseListViewModel
    @Environment(\.viewController) private var viewController

    init(viewModel: CourseListViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        BaseHorizonScreen {
            InstUI.BaseScreen(
                state: viewModel.state,
                config: .init(refreshable: false)
            ) { _ in
                ForEach(viewModel.courses) { course in
                    VStack(spacing: 16) {
                        Button {
                            viewModel.courseDidSelect.accept((course, viewController))
                        } label: {
                            VStack(alignment: .leading, spacing: 12) {
                                Size12RegularTextDarkestTitle(title: course.institutionName)
                                Size16RegularTextDarkestTitle(title: course.name)
                                ContentProgressBar(progress: course.progress)
                                HStack(spacing: 0) {
                                    Size12RegularTextDarkTitle(title: course.progressString)
                                    Spacer()
                                    Size12RegularTextDarkTitle(title: course.progressState.rawValue)
                                }
                            }
                            .padding(.all, 24)
                        }
                        .background(Color.backgroundLight)
                        .cornerRadius(8)
                        .padding([.leading, .top, .trailing], 16)
                    }
                }
            }
        }
        .navigationTitle("Your Courses")
    }
}
