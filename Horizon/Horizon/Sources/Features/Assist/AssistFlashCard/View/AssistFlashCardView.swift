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

struct AssistFlashCardView: View {
    @Bindable var viewModel: AssistFlashCardViewModel
    @Environment(\.viewController) private var viewController

    var body: some View {
        VStack {
            headerView
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack {
                    flashCardsView
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.viewAligned)
            .contentMargins(.horizontal, 30, for: .scrollContent)
            .scrollPosition(id: $viewModel.currentCardIndex)
        }
        .animation(.smooth, value: viewModel.currentCardIndex)
        .paddingStyle(.top, .standard)
        .safeAreaInset(edge: .bottom) {
            AssistFlashCardStepIndicatorView(viewModel: viewModel)
                .padding(.bottom, 5)
        }
        .applyHorizonGradient()
    }
}

// MARK: - Components

extension AssistFlashCardView {
    private var headerView: some View {
        ZStack(alignment: .trailingLastTextBaseline) {
            Text("AI Assist", bundle: .horizon)
                .foregroundStyle(Color.textLightest)
                .frame(maxWidth: .infinity)
                .font(.bold20)

            Button {
                viewModel.dismiss(controller: viewController)
            } label: {
                Image(systemName: "xmark")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.white.opacity(0.2))
                    .clipShape(.circle)
            }
        }
        .paddingStyle(.trailing, .standard)
    }

    @ViewBuilder
    private var flashCardsView: some View {
        ForEach(Array(viewModel.flashCards.enumerated()), id: \.offset) { index, item in
            AssistFlashCardItemView(item: item)
                .containerRelativeFrame(.horizontal)
                .containerRelativeFrame(.vertical) { height, _ in
                    height * 0.8
                }
                .rotation3DEffect(
                    .degrees(item.isFlipped  ? 180 : 0),
                    axis: (x: 0, y: 1, z: 0)
                )
                .onTapGesture {
                    viewModel.makeCardFlipped(at: index)
                }
                .animation(.easeInOut, value: item.isFlipped)
                .scrollTransition(.animated, axis: .horizontal) { content, phase in
                    content
                        .opacity(phase.isIdentity ? 1 : 0.75)
                        .offset(y: phase.isIdentity ? 0 : 32)
                }
        }
    }
}

#if DEBUG
#Preview {
    AssistFlashCardView(viewModel: .init(router: AppEnvironment.shared.router))
}
#endif
