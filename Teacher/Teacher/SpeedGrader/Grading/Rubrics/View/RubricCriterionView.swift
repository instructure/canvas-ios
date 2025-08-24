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

struct RubricCriterionView: View {
    @Environment(\.viewController) var controller
    @ObservedObject var viewModel: RubricCriterionViewModel

    @State private var isExpanded: Bool

    init(viewModel: RubricCriterionViewModel) {
        self.viewModel = viewModel

        let expanded = viewModel.hideRubricPoints && viewModel.userRatingId == nil
        self._isExpanded = .init(initialValue: expanded)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(
                action: {
                    withAnimation { isExpanded.toggle() }
                },
                label: {
                    HStack {
                        Text(viewModel.title)
                            .font(.semibold16)
                            .foregroundColor(.textDarkest)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 16)

                        Image
                            .chevronDown
                            .scaledIcon(size: 24)
                            .foregroundStyle(Color.textDark)
                            .padding(12)
                            .rotationEffect(isExpanded ? .degrees(180) : .zero)
                    }
                    .contentShape(Rectangle())
                }
            )
            .buttonStyle(.plain)
            .accessibilityAddTraits(.isHeader)
            .accessibilityHint(
                isExpanded
                    ? String(localized: "Expanded", bundle: .teacher)
                    : String(localized: "Collapsed", bundle: .teacher)
            )

            if isExpanded {

                if viewModel.longDescription.isNotEmpty {

                    Text(viewModel.longDescription)
                        .font(.regular14)
                        .foregroundColor(.textDarkest)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 16)
                }
            }

            if viewModel.shouldShowRubricRatings {

                if viewModel.hideRubricPoints {
                    RubricTextRatingsListView(isExpanded: $isExpanded, viewModel: viewModel)
                } else {
                    RubricPointsRatingsListView(isExpanded: $isExpanded, viewModel: viewModel)
                }
            }

            if shouldShowPointsScoreInput {
                RubricScoreInputView(viewModel: viewModel)
            }

            RubricNoteView(comment: viewModel.userComment) { newComment in
                viewModel.updateComment(newComment)
            }
        }
        .elevation(.cardLarge, background: Color.backgroundLightest)
    }

    private var shouldShowPointsScoreInput: Bool {
        if viewModel.shouldShowRubricRatings {
            return viewModel.hideRubricPoints == false
        } else {
            return viewModel.hideRubricPoints == false && isExpanded == false
        }
    }
}

#if DEBUG

#Preview {

    let env = PreviewEnvironment()
    let context = env.database.viewContext
    let assignment = Assignment(context: context)
        .with { assignment in
            assignment.id = "234"
            assignment.hideRubricPoints = true
            assignment.freeFormCriterionCommentsOnRubric = false
            assignment.rubric = [
                CDRubricCriterion(context: context).with({ cret in
                    cret.points = 12
                    cret.shortDescription = "Effective Use of Space"
                    cret.longDescription = "Great use of space to show depth with use of foreground, middleground, and background."
                    cret.id = "1"
                    cret.assignmentID = "234"
                    cret.ratings = [
                        CDRubricRating(context: context).with({ rating in
                            rating.id = "11"
                            rating.points = 2
                            rating.shortDescription = "Poor"
                            rating.longDescription = "Comprehensive, insightful, and relevant. Information is completely accurate."
                        }),
                        CDRubricRating(context: context).with({ rating in
                            rating.id = "22"
                            rating.points = 3
                            rating.shortDescription = "Good"
                            rating.longDescription = "Comprehensive, insightful, and relevant. Information is completely accurate."
                        }),
                        CDRubricRating(context: context).with({ rating in
                            rating.id = "33"
                            rating.points = 4
                            rating.shortDescription = "Very Good"
                            rating.longDescription = "Comprehensive, insightful, and relevant. Information is completely accurate."
                        }),
                        CDRubricRating(context: context).with({ rating in
                            rating.id = "44"
                            rating.points = 5
                            rating.shortDescription = "Excellent"
                            rating.longDescription = "Comprehensive, insightful, and relevant. Information is completely accurate."
                        })
                    ]
                })
            ]
        }

    let submission = Submission(context: env.database.viewContext).with { sub in
        sub.assignment = assignment
    }

    let interactor = RubricGradingInteractorPreview()

    let model = {

        let model = RubricsViewModel(
            assignment: assignment,
            submission: submission,
            interactor: interactor,
            router: env.router
        ).criterionViewModels.first!

        model.ratingViewModels.last?.isSelected = true
        model.userComment = "Content is perfectly placed, highly relevant, and enhances clarity. Shows strong understanding of audience and purpose."
        model.userRatingBubble = .init(
            title: "Excellent",
            subtitle: "Comprehensive, insightful, and relevant. Information is completely accurate."
        )

        return model
    }()

    VStack {
        RubricCriterionView(
            viewModel: model
        )
    }
    .padding(16)
    .background(Color.backgroundLight)
    .environment(\.appEnvironment, env)
}

#endif
