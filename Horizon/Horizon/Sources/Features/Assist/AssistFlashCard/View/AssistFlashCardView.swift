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
import Core

struct AssistFlashCardView: View {
    @Bindable var viewModel: AssistFlashCardViewModel
    @Environment(\.viewController) private var viewController

    var body: some View {
        VStack {
            headerView
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: HorizonUI.spaces.space16) {
                    flashCardsView
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.viewAligned)
            .contentMargins(.horizontal, HorizonUI.spaces.space32, for: .scrollContent)
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
        AssistTitle {
            viewModel.dismiss(controller: viewController)
        }
        .padding(.horizontal, HorizonUI.spaces.space16)
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
                    .degrees(item.isFlipped ? 180 : 0),
                    axis: (x: 0, y: 1, z: 0)
                )
                .scaleEffect(
                    viewModel.currentCardIndex == index ? 1 : 0.8,
                    anchor: (viewModel.currentCardIndex ?? 0) < index ? .leading : .trailing
                )
                .onTapGesture {
                    viewModel.makeCardFlipped(at: index)
                }
                .animation(.easeInOut, value: item.isFlipped)
        }
    }
}

#if DEBUG
#Preview {
    AssistFlashCardView(
        viewModel: .init(
            flashCards: [
                .init(
                    frontContent: "Front Content 1. This is some really long content so that we can see what would happen if we have a lot of text here. This is some really long content so that we can see what would happen if we have a lot of text here. Keep going. This is some really long content so that we can see what would happen if we have a lot of text here. Keep going. This is some really long content so that we can see what would happen if we have a lot of text here. Keep going. This is some really long content so that we can see what would happen if we have a lot of text here. Keep going.",
                    backContent: "Back Content 1"
                ),
                .init(
                    frontContent: "Front Content 2",
                    backContent: "Back Content 2"
                ),
                .init(
                    frontContent: "Front Content 3",
                    backContent: "Back Content 3"
                )
            ],
            router: AppEnvironment.shared.router
        )
    )
}
#endif
