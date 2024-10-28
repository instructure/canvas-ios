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

struct AssignmentDetails: View {
    let viewModel: AssignmentViewModel

    init(viewModel: AssignmentViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack(spacing: 0) {
            LearningObjectHeaderView(
                type: "Assignment",
                duration: viewModel.assignment.duration,
                courseName: viewModel.assignment.courseName,
                courseProgress: viewModel.assignment.courseProgress,
                courseDueDate: viewModel.assignment.courseDueDate,
                courseState: viewModel.assignment.courseState
            )
            .padding(.top, 16)
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
            .background(Color.backgroundLight)

            ScrollView(.vertical) {
                VStack(spacing: 8) {
                    Size14RegularTextDarkestTitle(title: viewModel.assignment.dueAt)
                    if let pointsPossible = viewModel.assignment.pointsPossible {
                        Size14RegularTextDarkestTitle(title: "\(pointsPossible)")
                    }
                    if viewModel.assignment.allowedAttempts > 0 {
                        Size14RegularTextDarkestTitle(title: "\(viewModel.assignment.allowedAttempts) attempt(s)")
                    } else {
                        Size14RegularTextDarkestTitle(title: "Unlimited Attempts Allowed")
                    }
                }
                .padding(.top, 8)
                .padding(.horizontal, 16)
                if let details = viewModel.assignment.details {
                    Size14RegularTextDarkestTitle(title: details)
                        .padding(.top, 8)
                        .padding(.horizontal, 16)
                }
            }
        }
        .navigationTitle(viewModel.assignment.name)
        .toolbarBackground(.visible, for: .navigationBar)
    }
}

#Preview {
    AssignmentDetails(viewModel: AssignmentDetailsAssembly.makeViewModel())
}
