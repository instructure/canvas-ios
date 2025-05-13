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

struct AssistFlashCardStepIndicatorView: View {
    let viewModel: AssistFlashCardViewModel

    var body: some View {
        VStack {
            HStack(spacing: HorizonUI.spaces.space24) {
                previousButton

                Text(viewModel.ofText)
                    .huiTypography(.p1)
                    .foregroundColor(HorizonUI.colors.text.surfaceColored)

                nextButton
            }
        }
    }
}

// MARK: - Components

extension AssistFlashCardStepIndicatorView {
    private var previousButton: some View {
        stepButton(
            image: Image.huiIcons.chevronLeft,
            disabled: viewModel.isPreviousButtonDisabled
        ) {
            viewModel.goToPreviousCard()
        }
    }

    private var nextButton: some View {
        stepButton(
            image: Image.huiIcons.chevronRight,
            disabled: viewModel.isNextButtonDisabled
        ) {
            viewModel.goToNextCard()
        }
    }

    private func stepButton(image: Image, disabled: Bool, action: @escaping () -> Void) -> some View {
        HorizonUI.IconButton(
            image,
            type: .white,
            action: action
        )
        .disabled(disabled)
    }
}

#if DEBUG
#Preview {
    AssistFlashCardStepIndicatorView(viewModel: .init(router: AppEnvironment.shared.router))
}
#endif
