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

struct RubricAssessor: View {
    let currentScore: Double
    let containerFrameInGlobal: CGRect
    @ObservedObject var viewModel: RubricsViewModel

    @Environment(\.appEnvironment) var env
    @Environment(\.viewController) var controller

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 0) {
                Text("Rubric", bundle: .teacher)
                    .font(.heavy24).foregroundColor(.textDarkest)
                    .accessibilityAddTraits(.isHeader)
                Text("\(currentScore, specifier: "%g") out of \(viewModel.assignment.rubricPointsPossible ?? 0, specifier: "%g")", bundle: .teacher)
                    .font(.medium14).foregroundColor(.textDark)
            }
            Spacer()

            if viewModel.isSaving {
                ProgressView()
                    .progressViewStyle(.indeterminateCircle(size: 24))
            }
        }
        .padding(.horizontal, 16).padding(.vertical, 12)

        VStack(spacing: 12) {
            ForEach(viewModel.assignment.rubric ?? [], id: \.id) { criteria in
                RubricCriteriaAssessor(
                    criteria: criteria,
                    containerFrameInGlobal: containerFrameInGlobal,
                    viewModel: viewModel
                )
            }
        }
        .multilineTextAlignment(.leading)
        .padding(.horizontal, 16)
        .onAppear {
            viewModel.controller = controller
        }
    }

    private func freeFormRubricCommentBubbleWithEditButton(_ comment: String, criteriaID: String) -> some View {
        HStack {
            Text(comment)
                .font(.regular14)
                .foregroundColor(.textDarkest)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(CommentBackground()
                    .fill(Color.backgroundLight)
                )
            Spacer()
            Button(action: { withAnimation(.default) {
                viewModel.rubricComment = comment
                viewModel.rubricCommentID = criteriaID
            } }, label: {
                Text("Edit", bundle: .teacher)
                    .font(.medium14).foregroundColor(.accentColor)
            })
        }
        .padding(.top, 8)
    }
}
