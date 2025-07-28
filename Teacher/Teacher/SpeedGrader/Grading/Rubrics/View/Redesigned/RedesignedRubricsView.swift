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

struct RedesignedRubricsView: View {
    let currentScore: Double
    let containerFrameInGlobal: CGRect
    @ObservedObject var viewModel: RubricsViewModel

    @Environment(\.appEnvironment) var env
    @Environment(\.viewController) var controller

    var body: some View {

        VStack {

            InstUI.Divider()

            Text("Rubric", bundle: .teacher)
                .font(.semibold16)
                .foregroundColor(.textDarkest)
                .accessibilityAddTraits(.isHeader)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 14)
                .padding(.horizontal, 16)

            VStack(spacing: 16) {
                ForEach(viewModel.criterionViewModels) { viewModel in
                    RedesignedRubricCriterionView(
                        viewModel: viewModel
                    )
                }
            }
            .padding(.horizontal, 16)
            .onAppear {
                viewModel.controller = controller
            }

        }
        .padding(.bottom, 32)
        .background(Color.backgroundLight)
    }
}

#if DEBUG

#Preview {
    let env = PreviewEnvironment()
    let context = env.database.viewContext
    let assignment = Assignment(context: context)
        .with { assignment in

            assignment.id = "234"
            assignment.rubricPointsPossible = 10
            assignment.rubric = [
                CDRubricCriterion(context: context).with({ cret in
                    cret.points = 10
                    cret.shortDescription = "Effective Use of Space"
                    cret.assignmentID = "234"
                    cret.ratings = [
                        CDRubricRating(context: context).with({ rating in
                            rating.points = 2
                        }),
                        CDRubricRating(context: context).with({ rating in
                            rating.points = 3
                        }),
                        CDRubricRating(context: context).with({ rating in
                            rating.points = 4
                        }),
                        CDRubricRating(context: context).with({ rating in
                            rating.points = 56
                        })
                    ]
                }),
                CDRubricCriterion(context: context).with({ cret in
                    cret.points = 10
                    cret.shortDescription = "Rubric default empty"
                    cret.assignmentID = "234"
                    cret.criterionUseRange = true
                    cret.ratings = [
                        CDRubricRating(context: context).with({ rating in
                            rating.points = 2
                            rating.shortDescription = "Good"
                        }),
                        CDRubricRating(context: context).with({ rating in
                            rating.points = 3
                            rating.shortDescription = "Very good"
                        }),
                        CDRubricRating(context: context).with({ rating in
                            rating.points = 4
                            rating.shortDescription = "Excellent"
                        })
                    ]
                }),
                CDRubricCriterion(context: context).with({ cret in
                    cret.points = 10
                    cret.shortDescription = "Content Placing"
                    cret.longDescription = "Long Effective Use of Space"
                    cret.assignmentID = "234"
                    cret.ratings = [
                        CDRubricRating(context: context).with({ rating in
                            rating.points = 2
                            rating.shortDescription = "33 33333"
                            rating.longDescription = "Excellent"
                        }),
                        CDRubricRating(context: context).with({ rating in
                            rating.points = 3
                            rating.shortDescription = "34-23"
                        }),
                        CDRubricRating(context: context).with({ rating in
                            rating.points = 4
                            rating.shortDescription = "34-23"
                        }),
                        CDRubricRating(context: context).with({ rating in
                            rating.points = 56
                            rating.shortDescription = "34-23"
                        })
                    ]
                }),
                CDRubricCriterion(context: context).with({ cret in
                    cret.points = 10
                    cret.shortDescription = "Score attribution"
                    cret.assignmentID = "234"
                    cret.ratings = [
                        CDRubricRating(context: context).with({ rating in
                            rating.points = 2
                        }),
                        CDRubricRating(context: context).with({ rating in
                            rating.points = 3
                        }),
                        CDRubricRating(context: context).with({ rating in
                            rating.points = 4
                        }),
                        CDRubricRating(context: context).with({ rating in
                            rating.points = 56
                        })
                    ]
                })
            ]
        }

    let submission = Submission(context: env.database.viewContext)

    let model = {
        let rubrics = RubricsViewModel(
            assignment: assignment,
            submission: submission,
            interactor: RubricGradingInteractorPreview(),
            router: env.router
        )

        rubrics.criterionViewModels[1].userComment = "Content is perfectly placed, highly relevant, and enhances clarity. Shows strong understanding of audience and purpose."

        return rubrics
    }()

    InstUI.BaseScreen(
        state: .data,
        config: .init(
            refreshable: false,
            emptyPandaConfig: .init(
                scene: SpacePanda(),
                title: String(localized: "Moderated Grading Unsupported", bundle: .teacher)
            )
        )
    ) { geometry in

        VStack(spacing: 0) {
            RedesignedRubricsView(
                currentScore: 43,
                containerFrameInGlobal: geometry.frame(in: .global),
                viewModel: model
            )
        }
        .padding(.bottom, 16)
    }
    .environment(\.appEnvironment, env)
}

extension NSObject {
    func with(_ block: (Self) -> Void) -> Self {
        block(self)
        return self
    }
}

#endif
