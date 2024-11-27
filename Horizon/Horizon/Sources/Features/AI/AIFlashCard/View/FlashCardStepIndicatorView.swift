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

struct FlashCardStepIndicatorView: View {
    let viewModel: AIFlashCardViewModel

    var body: some View {
        VStack {
            HStack {
                perviousButton
                let currentCardIndex = (viewModel.currentCardIndex ?? 0) + 1
                let ofText = String(localized: "of", bundle: .horizon)
                Text("\(currentCardIndex) \(ofText) \(viewModel.flashCards.count)")
                    .font(.headline)
                    .foregroundColor(.white)
                nextButton
            }
        }
    }
}

// MARK: - Components

extension FlashCardStepIndicatorView {
    private var perviousButton: some View {
        Button(action: {
            viewModel.goToPreviousCard()
        }) {
            stepIcon(imageName: "chevron.left", isDisabled: viewModel.isPreviousButtonDisabled)
        }
        .disabled(viewModel.isPreviousButtonDisabled)
    }

    private var nextButton: some View {
        Button(action: {
            viewModel.goToNextCard()
        }) {
            stepIcon(imageName: "chevron.right", isDisabled: viewModel.isNextButtonDisabled)
        }
        .disabled(viewModel.isNextButtonDisabled)
    }

    private func stepIcon(imageName: String, isDisabled: Bool) -> some View {
        Image(systemName: imageName)
            .foregroundColor(Color.textDarkest)
            .padding()
            .background {
                Circle()
                    .fill(isDisabled
                          ? Color.backgroundLightest.opacity(0.2)
                          : Color.backgroundLightest
                    )
            }
    }
}

#if DEBUG
#Preview {
    FlashCardStepIndicatorView(viewModel: .init(router: AppEnvironment.shared.router))
}
#endif
