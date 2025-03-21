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

import SwiftUI
import Core

struct AssistQuizView: View {
    let viewModel: AssistQuizViewModel
    @Environment(\.viewController) private var viewController

    var body: some View {
        InstUI.BaseScreen(
            state: viewModel.state,
            config: .init(
                refreshable: false,
                loaderBackgroundColor: Color.backgroundDark.opacity(0.3)
            )
        ) { _ in
            VStack(spacing: 20) {
                headerView
                questionTitle
                answerOptions
            }
            .animation(.smooth, value: viewModel.didSubmitQuiz)
            .paddingStyle(.all, .standard)
        }
        .applyHorizonGradient()
        .safeAreaInset(edge: .bottom) {
            if viewModel.state == .data {
                footerView
            }
        }
    }
}

// MARK: - Components

extension AssistQuizView {
    private var headerView: some View {
        ZStack(alignment: .trailingLastTextBaseline) {
            AssistTitle()

            Button {
                viewModel.dismiss(controller: viewController)
            } label: {
                Image(systemName: "xmark")
                    .foregroundColor(.textLightest)
                    .padding()
                    .background(Color.backgroundLightest.opacity(0.2))
                    .clipShape(.circle)
            }
        }
    }

    private var questionTitle: some View {
        Text(viewModel.quiz?.question ?? "")
            .frame(maxWidth: .infinity, alignment: .leading)
            .font(.regular24)
            .foregroundStyle(Color.textLightest)
            .padding(.top, 40)
            .padding(.bottom, 20)
    }

    private var answerOptions: some View {
        VStack(spacing: 20) {
            ForEach(viewModel.quiz?.options ?? []) { answer in
                Button {
                    viewModel.selectedAnswer = answer
                } label: {
                    AssistQuizAnswerOptionView(
                        selectedAnswer: answer,
                        isSelected: answer == viewModel.selectedAnswer,
                        isCorrect: viewModel.isCorrect(answer: answer)
                    )
                }
            }
        }
        .disabled(viewModel.didSubmitQuiz)
    }

    private var submitQuizButton: some View {
        Button(action: {
            viewModel.submitQuiz()
        }) {
            Text("Check Answer", bundle: .horizon)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(viewModel.isSubmitButtonDisabled ? Color.backgroundLightest.opacity(0.2) : Color.backgroundLightest)
                .foregroundColor(viewModel.isSubmitButtonDisabled ? Color.textDarkest.opacity(0.2) : Color.textDarkest)
                .clipShape(.capsule)
        }
        .disabled(viewModel.isSubmitButtonDisabled)
    }

    private var regenerateQuizButton: some View {
        Button(action: {
            viewModel.regenerateQuiz()
        }) {
            Text("Regenerate", bundle: .horizon)
                .underline()
                .foregroundColor(.textLightest)
                .font(.regular16)
        }
    }

    private var tryAgainButton: some View {
        Button(action: {
            viewModel.regenerateQuiz()
        }) {
            Text("Try Again", bundle: .horizon)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.backgroundLightest)
                .foregroundColor(Color.textDarkest)
                .clipShape(.capsule)
        }
    }

    private var footerView: some View {
        VStack(spacing: 20) {
            if !viewModel.didSubmitQuiz {
                submitQuizButton
                regenerateQuizButton
            } else {
                tryAgainButton
            }

        }
        .paddingStyle([.bottom, .horizontal], .standard)
    }
}

#if DEBUG
#Preview {
    AssistQuizView(viewModel: .init(chatBotInteractor: AssistChatInteractorPreview()))
}
#endif
