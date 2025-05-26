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

    var body: some View {
        VStack {
            if let corseID = viewModel.courseID, let enrollmentID = viewModel.enrollmentID {
                LearnAssembly.makeCourseDetailsView(courseID: corseID, enrollmentID: enrollmentID)
                    .id(corseID)
            } else if viewModel.courseID == nil, !viewModel.isLoaderVisible {
               ScrollView {
                    Text("You aren’t currently enrolled in a course.", bundle: .horizon)
                        .padding(.huiSpaces.space24)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        .foregroundStyle(Color.huiColors.text.body)
                        .huiTypography(.h3)
                        .padding(.top, .huiSpaces.space32)
                }
               .refreshable {
                   await viewModel.refreshCourses()
               }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .toolbar(.hidden)
        .background(Color.huiColors.surface.pagePrimary)
        .alert(isPresented: $viewModel.isAlertPresented) {
            Alert(title: Text("Something went wrong", bundle: .horizon), message: Text(viewModel.errorMessage))
        }
        .overlay {
            if viewModel.isLoaderVisible {
                HorizonUI.Spinner(size: .small, showBackground: true)
            }
        }
        .onFirstAppear {
            viewModel.fetchCourses()
        }
    }
}
