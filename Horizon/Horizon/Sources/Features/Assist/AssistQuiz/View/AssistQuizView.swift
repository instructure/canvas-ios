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

import HorizonUI
import SwiftUI

struct AssistQuizView: View {
    let viewModel: AssistQuizViewModel
    @Environment(\.viewController) private var viewController

    var body: some View {
        VStack(spacing: .zero) {
            headerView
            ScrollView {
                VStack(spacing: .zero) {
                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .huiTypography(.p1)
                            .foregroundStyle(Color.huiColors.text.surfaceColored)
                    } else {
                        questionTitle
                            .padding(.bottom, .huiSpaces.space16)
                        answerOptions
                    }
                }
                .animation(.smooth, value: viewModel.didSubmitQuiz)
                .padding(.huiSpaces.space16)
            }
            .padding(.top, .huiSpaces.space16)
            .scrollBounceBehavior(.basedOnSize)
            .animation(.smooth, value: viewModel.selectedAnswer)
            .safeAreaInset(edge: .bottom) {
                if !viewModel.isLoaderVisible {
                    footerView
                }
            }
            .overlay { loaderView }
        }
        .applyHorizonGradient()
    }
}

// MARK: - Components

extension AssistQuizView {
    @ViewBuilder
    private var loaderView: some View {
        if viewModel.isLoaderVisible {
            ZStack {
                Rectangle()
                    .fill(Color.clear)
                    .applyHorizonGradient()
                    .ignoresSafeArea()
                HorizonUI.Spinner(size: .small, foregroundColor: Color.huiColors.surface.cardPrimary)
            }
        }
    }

    private var headerView: some View {
        AssistTitle(onBack: { viewModel.pop(controller: viewController) }) {
            viewModel.dismiss(controller: viewController)
        }
    }

    private var questionTitle: some View {
        Text(viewModel.quiz?.question ?? "")
            .frame(maxWidth: .infinity, alignment: .leading)
            .huiTypography(.p1)
            .foregroundStyle(Color.huiColors.text.surfaceColored)
    }

    private var answerOptions: some View {
        VStack(spacing: .huiSpaces.space8) {
            ForEach(viewModel.quiz?.options ?? []) { answer in
                Button {
                    viewModel.selectedAnswer = answer
                } label: {
                    let isCorrect = viewModel.isCorrect(answer: answer)
                    AssistQuizAnswerOptionView(
                        selectedAnswer: answer,
                        isSelected: answer == viewModel.selectedAnswer,
                        isCorrect: answer == viewModel.selectedAnswer
                        ? isCorrect
                        : isCorrect == true ? isCorrect : nil
                    )
                }
            }
        }
        .disabled(viewModel.didSubmitQuiz)
    }

    private var submitQuizButton: some View {
        HorizonUI.PrimaryButton(
            String(localized: "Check answer", bundle: .horizon),
            type: .white,
            fillsWidth: true
        ) {
            viewModel.submitQuiz()
        }
        .disabled(viewModel.isSubmitButtonDisabled)
    }

    private var regenerateQuizButton: some View {
        HorizonUI.PrimaryButton(
            String(localized: "Regenerate", bundle: .horizon),
            type: .whiteOutline,
            fillsWidth: true
        ) {
            viewModel.regenerateQuiz()
        }
    }

    private var tryAgainButton: some View {
        Button(action: {
            viewModel.regenerateQuiz()
        }) {
            Text("Regenerate", bundle: .horizon)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.backgroundLightest)
                .foregroundColor(Color.textDarkest)
                .clipShape(.capsule)
        }
    }

    private var footerView: some View {
        VStack(spacing: .huiSpaces.space12) {
            if !viewModel.didSubmitQuiz {
                submitQuizButton
                regenerateQuizButton
            } else {
                tryAgainButton
            }
        }
        .padding([.bottom, .horizontal], .huiSpaces.space16)
    }
}

#if DEBUG
#Preview {
    AssistQuizView(
        viewModel: .init(
            chatBotInteractor: AssistChatInteractorPreview(),
            quizzes: [
                .init(
                    question: "What's your first name?",
                    options: [
                        .init("John"),
                        .init("Sally"),
                        .init("Bob"),
                        .init("Alice")
                    ],
                    correctAnswerIndex: 0
                )
            ]
        )
    )
}
#endif
