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

import SwiftUI
import Core
import HorizonUI

struct ModuleNavBarView: View {
    // MARK: - Private Properties

    @Environment(\.viewController) private var controller

    // MARK: - Dependencies

    private let router: Router
    private let isNextButtonEnabled: Bool
    private let isPreviousButtonEnabled: Bool
    private let isShowUtilityButtons: Bool
    private let didTapNext: () -> Void
    private let didTapPrevious: () -> Void

    init(
        router: Router,
        isNextButtonEnabled: Bool,
        isPreviousButtonEnabled: Bool,
        isShowUtilityButtons: Bool = true,
        didTapNext: @escaping () -> Void,
        didTapPrevious: @escaping () -> Void
    ) {
        self.router = router
        self.isNextButtonEnabled = isNextButtonEnabled
        self.isPreviousButtonEnabled = isPreviousButtonEnabled
        self.isShowUtilityButtons = isShowUtilityButtons
        self.didTapNext = didTapNext
        self.didTapPrevious = didTapPrevious
    }

    var body: some View {
        HStack(spacing: .zero) {
            previousButton

            Spacer()
            if isShowUtilityButtons {
                HStack(spacing: .huiSpaces.space8) {
                    buttonView(type: .tts)
                    chatBotButton
                    buttonView(type: .notebook)
                }
            }
            Spacer()
            nextButton
        }
    }

    private var previousButton: some View {
        HorizonUI.IconButton(
            ModuleNavBarButtons.previous.image,
            type: .white
        ) {
            didTapPrevious()
        }
        .huiElevation(level: .level2)
        .hidden(!isPreviousButtonEnabled)
    }

    private var nextButton: some View {
        HorizonUI.IconButton(
            ModuleNavBarButtons.next.image,
            type: .white
        ) {
            didTapNext()
        }
        .huiElevation(level: .level2)
        .hidden(!isNextButtonEnabled)
    }

    private func buttonView(type: ModuleNavBarButtons) -> some View {
        HorizonUI.IconButton(
            type.image,
            type: .white
        ) {
            navigateToTutor()
        }
        .huiElevation(level: .level2)
    }

    private var chatBotButton: some View {
        Button {
            navigateToTutor()
        } label: {
            ModuleNavBarButtons.chatBot.image
                .resizable()
                .frame(width: 44, height: 44)
                .huiElevation(level: .level2)
        }
    }

    private func navigateToTutor() {
        router.route(to: "/tutor", from: controller, options: .modal())
    }
}
