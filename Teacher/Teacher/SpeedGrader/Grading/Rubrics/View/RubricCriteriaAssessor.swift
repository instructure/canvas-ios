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

struct RubricCriteriaAssessor: View {
    @Environment(\.viewController) var controller
    private var criteria: Rubric
    private let containerFrameInGlobal: CGRect
    private let assessment: APIRubricAssessment?
    @ObservedObject var viewModel: RubricsViewModel

    init(
        criteria: Rubric,
        containerFrameInGlobal: CGRect,
        viewModel: RubricsViewModel
    ) {
        self.criteria = criteria
        self.containerFrameInGlobal = containerFrameInGlobal
        self.viewModel = viewModel
        assessment = viewModel.assessmentForCriteriaID(criteria.id)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack { Spacer() }
            Text(criteria.desc)
                .font(.semibold16).foregroundColor(.textDarkest)
            if criteria.ignoreForScoring {
                Text("This criterion will not impact the score.", bundle: .teacher)
                    .font(.regular12).foregroundColor(.textDark)
                    .padding(.top, 2)
            }

            FlowStack(spacing: UIOffset(horizontal: 8, vertical: 8)) { leading, top in
                if !viewModel.assignment.freeFormCriterionCommentsOnRubric, let ratings = criteria.ratings {
                    ForEach(ratings.reversed(), id: \.id) { rating in
                        let isSelected = assessment?.rating_id == rating.id
                        let value = Text((isSelected ? assessment?.points : nil) ?? rating.points)
                        let tooltip = rating.desc + (rating.longDesc.isEmpty ? "" : "\n" + rating.longDesc)

                        RubricCircle(isOn: Binding(get: { isSelected }, set: { newValue in
                            viewModel.assessments[criteria.id] = newValue ? APIRubricAssessment(
                                comments: assessment?.comments,
                                points: rating.points,
                                rating_id: rating.id
                            ) : APIRubricAssessment(comments: assessment?.comments)
                        }), tooltip: tooltip, containerFrame: containerFrameInGlobal) {
                            value
                        }
                        .accessibility(value: value)
                        .accessibility(label: rating.desc.isEmpty ? value : Text(rating.desc))
                        .alignmentGuide(.leading, computeValue: leading)
                        .alignmentGuide(.top, computeValue: top)
                    }
                }
                customGradeToggle(
                    criteria: criteria,
                    assessment: assessment,
                    leading: leading,
                    top: top
                )
            }
            .padding(.top, 8)

            let showAdd = viewModel.assignment.freeFormCriterionCommentsOnRubric && assessment?.comments?.isEmpty != false
            let showLong = criteria.longDesc.isEmpty == false
            if showAdd || showLong {
                addButtons(
                    criteria: criteria,
                    assessment: assessment,
                    showAdd: showAdd,
                    showLong: showLong
                )
            }
        }
    }

    private func addButtons(
        criteria: Rubric,
        assessment: APIRubricAssessment?,
        showAdd: Bool,
        showLong: Bool
    ) -> some View {
        HStack(spacing: 6) {
            if showAdd {
                Button(
                    action: {
                        withAnimation(.default) {
                            viewModel.rubricComment = ""
                            viewModel.rubricCommentID = criteria.id
                        }
                    },
                    label: {
                        Text("Add Comment", bundle: .teacher)
                            .font(.medium14)
                            .foregroundColor(.accentColor)
                    }
                )
                .identifier("SpeedGrader.Rubric.\(criteria.id).addCommentButton")
            }
            if showAdd, showLong {
                Text(verbatim: "•")
                    .font(.regular12)
                    .foregroundColor(.textDark)
            }
            if showLong {
                Button(
                    action: {
                        viewModel.showLongDescription(rubric: criteria)
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

    private func customGradeToggle(
        criteria: Rubric,
        assessment: APIRubricAssessment?,
        leading: @escaping (ViewDimensions) -> CGFloat,
        top: @escaping (ViewDimensions) -> CGFloat
    ) -> some View {
        let customGrade = (
            viewModel.assignment.freeFormCriterionCommentsOnRubric ||
            assessment?.rating_id.isNilOrEmpty == true
        )
            ? assessment?.points : nil

        let binding = Binding(
            get: { customGrade != nil },
            set: { newValue in
                if newValue {
                    viewModel.promptCustomGrade(criteria, rubricAssessmentComment: assessment?.comments)
                } else {
                    viewModel.assessments[criteria.id] = APIRubricAssessment(comments: assessment?.comments)
                }
            }
        )

        return RubricCircle(isOn: binding) {
            if let grade = customGrade {
                Text(grade)
            } else {
                Image.addSolid
            }
        }
        .accessibilityLabel(Text("Add custom grade", bundle: .teacher))
        .accessibilityRemoveTraits(.isImage)
        .alignmentGuide(.leading, computeValue: leading)
        .alignmentGuide(.top, computeValue: top)
    }
}
