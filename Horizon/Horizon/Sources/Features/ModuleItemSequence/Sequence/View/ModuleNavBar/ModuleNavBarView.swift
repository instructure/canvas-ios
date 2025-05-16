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
    struct ButtonAttribute {
        let isVisible: Bool
        let action: () -> Void

        init(isVisible: Bool, action: @escaping () -> Void) {
            self.isVisible = isVisible
            self.action = action
        }

    }
    // MARK: - Private Properties

    @Environment(\.viewController) private var controller

    // MARK: - Dependencies

    private let router: Router
    private let nextButton: ModuleNavBarView.ButtonAttribute
    private let previousButton: ModuleNavBarView.ButtonAttribute
    private let visibleButtons: [ModuleNavBarUtilityButtons]

    init(
        router: Router,
        nextButton: ModuleNavBarView.ButtonAttribute,
        previousButton: ModuleNavBarView.ButtonAttribute,
        visibleButtons: [ModuleNavBarUtilityButtons]
    ) {
        self.router = router
        self.nextButton = nextButton
        self.previousButton = previousButton
        self.visibleButtons = visibleButtons
    }

    var body: some View {
        HStack(spacing: .zero) {
            previousButtonView
            Spacer()
            HStack(spacing: .huiSpaces.space8) {
                ForEach(visibleButtons, id: \.self) { button in
                    buttonView(button)
                }
            }
            Spacer()
            nextButtonView
        }
    }

    private var previousButtonView: some View {
        HorizonUI.IconButton(
            ModuleNavBarButtons.previous.image,
            type: .white
        ) {
            previousButton.action()
        }
        .huiElevation(level: .level2)
        .hidden(!previousButton.isVisible)
    }

    private var nextButtonView: some View {
        HorizonUI.IconButton(
            ModuleNavBarButtons.next.image,
            type: .white
        ) {
            nextButton.action()
        }
        .huiElevation(level: .level2)
        .hidden(!nextButton.isVisible)
    }

    private func buttonView(_ button: ModuleNavBarUtilityButtons) -> some View {
        HorizonUI.IconButton(
            button.image,
            type: button.buttonStyle,
            badgeType: button.hasBadge ? .solidColor : nil
        ) {
            button.onTap?(controller)
        }
        .huiElevation(level: .level2)
    }
}
