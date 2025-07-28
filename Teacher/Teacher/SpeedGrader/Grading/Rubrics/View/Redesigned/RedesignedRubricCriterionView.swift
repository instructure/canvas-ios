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

struct RedesignedRubricCriterionView: View {
    @Environment(\.viewController) var controller
    @ObservedObject var viewModel: RubricCriterionViewModel

    @State private var isExpanded: Bool = false
    @State private var isCommentEditing: Bool = false

    init(
        viewModel: RubricCriterionViewModel
    ) {
        
        self.viewModel = viewModel
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer().frame(height: 16)
            Text(viewModel.description)
                .font(.semibold16)
                .foregroundColor(.textDarkest)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)

            if isExpanded {

                if viewModel.longDescription.isNotEmpty {
                    Spacer().frame(height: 16)

                    Text(viewModel.longDescription)
                        .font(.regular14)
                        .foregroundColor(.textDarkest)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 16)

                }

                if viewModel.shouldShowRubricNotUsedForScoringMessage {
                    Spacer().frame(height: 16)

                    Text("This criterion will not impact the score.", bundle: .teacher)
                        .font(.regular12)
                        .foregroundColor(.textDark)
                        .padding(.top, 2)
                }
            }

            if viewModel.shouldShowRubricRatings {
                Spacer().frame(height: 16)

                if isExpanded {

                    VStack {
                        ForEach(viewModel.ratingViewModels) { ratingViewModel in
                            RubricRatingExpandedView(viewModel: ratingViewModel)
                        }
                    }
                    .padding(.bottom, 8)

                } else {
                    FlowLayout(spacing: 16, minimumLineSpacing: 16) {
                        ForEach(viewModel.ratingViewModels) { ratingViewModel in
                            RedesignedRubricRatingView(viewModel: ratingViewModel)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)
                }
            }

            if let model = viewModel.ratingViewModels.first(where: { $0.isSelected }), isExpanded == false {

                VStack(alignment: .leading) {
                    Text(model.title)
                        .font(.semibold16)
                        .foregroundStyle(Color.textLightest)

                    if model.subtitle.isNotEmpty {
                        Text(model.subtitle)
                            .font(.regular14)
                            .foregroundStyle(Color.textLightest)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                .background(content: {
                    RoundedRectangle(cornerRadius: 24).fill(.tint)
                })
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }

            if isExpanded {
                InstUI.Divider()
            }

            RubricScoreInputView(viewModel: viewModel)

            VStack(alignment: .leading, spacing: 8) {
                Text("Rubric Note")
                    .font(.semibold14)
                    .foregroundStyle(Color.textDark)

                if let comment = viewModel.userComment, comment.isNotEmpty, !isCommentEditing {
                    RubricNoteCommentBubbleView(comment: comment) {
                        isCommentEditing = true
                    }
                } else {
                    let comment = viewModel.userComment ?? ""
                    RubricNoteCommentEditView(comment: comment) { newComment in
                        viewModel.updateComment(newComment)
                        isCommentEditing = false
                    }
                }
            }
            .padding(.top, 8)
            .padding(.leading, 16)
            .padding(.bottom, 16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .overlay(alignment: .top) {
                InstUI.Divider()
            }
        }
        .elevation(.cardLarge, background: Color.backgroundLightest)
        .overlay(alignment: .topTrailing) {
            Button(
                action: {
                    withAnimation { isExpanded.toggle() }
                }
            ) {
                Image
                    .chevronDown
                    .scaledIcon(size: 24)
                    .padding(12)
            }
            .tint(.textDark)
            .rotationEffect(isExpanded ? .degrees(180) : .zero)
        }
    }
}

struct RubricScoreInputView: View {

    @ObservedObject var viewModel: RubricCriterionViewModel
    @State private var text: String = ""

    init(viewModel: RubricCriterionViewModel) {
        self.viewModel = viewModel
        self._text = .init(initialValue: viewModel.userPoints?.formatted() ?? "")
    }

    private var pointsPossible: String {
        let pts = viewModel.criterionPoints.formatted(.number.precision(.fractionLength(0)))
        return String.localizedStringWithFormat("%@ pts", pts)
    }

    var body: some View {
        GradeInputTextFieldCell(
            title: "Score",
            inputType: .points,
            pointsPossible: pointsPossible,
            isExcused: false,
            text: $text,
            isSaving: viewModel.isSaving
        )
        .onChange(of: text) { _, newValue in
            let formatter = NumberFormatter()
            guard let newPoints = formatter.number(from: newValue)?.doubleValue else { return }
            viewModel.updateCustomRating(newPoints)
        }
        .onChange(of: viewModel.userPoints) { _, newValue in
            text = newValue?.formatted() ?? ""
        }
    }
}

struct RubricNoteCommentEditView: View {

    @State private var text: String
    private var onSendTapped: (String) -> Void

    init(comment: String, onSendTapped: @escaping (String) -> Void) {
        self._text = .init(initialValue: comment)
        self.onSendTapped = onSendTapped
    }

    @ScaledMetric private var uiScale: CGFloat = 1

    var body: some View {
        TextField("Note", text: $text, axis: .vertical)
            .textFieldStyle(.plain)
            .font(.regular14)
            .lineLimit(3)
            .padding(.leading, 13)
            .padding(.trailing, 30 * uiScale)
            .padding(.vertical, 8)
            .overlay(alignment: .bottomTrailing) {
                Button(
                    action: {
                        onSendTapped(text)
                    }
                ) {

                    let image = Image
                        .circleArrowUpSolid
                        .scaledIcon(size: 24)

                    if text.isEmpty {
                        image.foregroundStyle(Color.disabledGray)
                    } else {
                        image.foregroundStyle(.tint)
                    }
                }
                .padding(.trailing, 4)
                .padding(.bottom, 4)
            }
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.borderMedium, lineWidth: 0.5)
                    .frame(minHeight: 32)
            }
            .padding(.trailing, 16)
    }
}

struct RubricNoteCommentBubbleView: View {

    let comment: String
    let onEdit: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            Text(comment)
                .font(.regular14)
                .foregroundStyle(Color.textDarkest)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(8)
                .background(Color.backgroundLight)
                .cornerRadius(16)
            Button(action: onEdit) {
                Image
                    .editLine
                    .scaledIcon(size: 24)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
            }
            .tint(.textDark)
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
            assignment.rubricPointsPossible = 13
            assignment.rubric = [
                CDRubricCriterion(context: context).with({ cret in
                    cret.points = 7
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

        model.ratingViewModels.first?.isSelected = true
        model.userComment = "Content is perfectly placed, highly relevant, and enhances clarity. Shows strong understanding of audience and purpose."

        return model
    }()

    VStack {
        RedesignedRubricCriterionView(
            viewModel: model
        )
    }
    .padding(16)
    .background(Color.backgroundLight)
    .environment(\.appEnvironment, env)
}

#endif
