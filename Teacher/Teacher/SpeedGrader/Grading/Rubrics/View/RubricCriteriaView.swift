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

struct RubricCriteriaView: View {
    @Environment(\.viewController) var controller
    private let containerFrameInGlobal: CGRect
    @ObservedObject var viewModel: RubricCriteriaViewModel

    init(
        containerFrameInGlobal: CGRect,
        viewModel: RubricCriteriaViewModel
    ) {
        self.containerFrameInGlobal = containerFrameInGlobal
        self.viewModel = viewModel
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack { Spacer() }
            Text(viewModel.description)
                .font(.semibold16).foregroundColor(.textDarkest)
            if viewModel.shouldShowRubricNotUsedForScoringMessage {
                Text("This criterion will not impact the score.", bundle: .teacher)
                    .font(.regular12).foregroundColor(.textDark)
                    .padding(.top, 2)
            }

            FlowStack(spacing: UIOffset(horizontal: 8, vertical: 8)) { leading, top in
                preDefinedRubricRatingButtons(leading: leading, top: top)
                RubricCustomRatingView(viewModel: viewModel.customRatingViewModel, leading: leading, top: top)
            }
            .padding(.top, 8)

            let showAdd = viewModel.shouldShowAddFreeFormCommentButton
            let showLong = viewModel.shouldShowLongDescriptionButton
            if showAdd || showLong {
                addButtons(
                    showAdd: showAdd,
                    showLong: showLong
                )
            }

//            if let comments = assessment?.comments, !comments.isEmpty {
//                freeFormRubricCommentBubbleWithEditButton(comments, criteriaID: criteria.id)
//            }
        }
    }

    @ViewBuilder
    private func preDefinedRubricRatingButtons(
        leading: @escaping (ViewDimensions) -> CGFloat,
        top: @escaping (ViewDimensions) -> CGFloat
    ) -> some View {
        if viewModel.shouldShowRubricRatings {
            ForEach(viewModel.ratingViewModels) { ratingViewModel in
                RubricRatingView(viewModel: ratingViewModel, leading: leading, top: top, containerFrameInGlobal: containerFrameInGlobal)
            }
        }
    }

    private func addButtons(
        showAdd: Bool,
        showLong: Bool
    ) -> some View {
        HStack(spacing: 6) {
            if showAdd {
                Button(
                    action: {
                        withAnimation(.default) {
                            viewModel.didTapAddCommentButton()
                        }
                    },
                    label: {
                        Text("Add Comment", bundle: .teacher)
                            .font(.medium14)
                            .foregroundColor(.accentColor)
                    }
                )
                .identifier(viewModel.addCommentButtonA11yID)
            }
            if showAdd, showLong {
                Text(verbatim: "•")
                    .font(.regular12)
                    .foregroundColor(.textDark)
            }
            if showLong {
                Button(
                    action: {
                        viewModel.didTapShowLongDescriptionButton()
                    },
                    label: {
                        Text("View Long Description", bundle: .teacher)
                            .font(.medium14)
                            .foregroundColor(.accentColor)
                    }
                )
            }
        }
        .padding(.top, 8)
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
