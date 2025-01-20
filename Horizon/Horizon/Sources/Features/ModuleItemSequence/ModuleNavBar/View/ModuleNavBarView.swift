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
    private let contentButtons = ModuleNavBarButtons.contentButtons

    // MARK: - Dependencies

    private let router: Router
    private let isNextButtonEnabled: Bool
    private let isPreviousButtonEnabled: Bool
    private let didTapNext: () -> Void
    private let didTapPrevious: () -> Void

    init(
        router: Router,
        isNextButtonEnabled: Bool,
        isPreviousButtonEnabled: Bool,
        didTapNext: @escaping () -> Void,
        didTapPrevious: @escaping () -> Void
    ) {
        self.router = router
        self.isNextButtonEnabled = isNextButtonEnabled
        self.isPreviousButtonEnabled = isPreviousButtonEnabled
        self.didTapNext = didTapNext
        self.didTapPrevious = didTapPrevious
    }

    var body: some View {
        HStack(spacing: 0) {
            Button {
                didTapPrevious()
            } label: {
                iconView(type: .previous)
            }
            .disableWithOpacity(!isPreviousButtonEnabled)

            Spacer()
            HStack(spacing: 8) {
                ForEach(contentButtons, id: \.self) { button in
                    buttonView(type: button)
                }
            }
            Spacer()
            Button {
                didTapNext()
            } label: {
                iconView(type: .next)
            }
            .disableWithOpacity(!isNextButtonEnabled)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .background(Color.huiColors.surface.pagePrimary)
    }

    private func buttonView(type: ModuleNavBarButtons) -> some View {
        Button {
            router.route(to: "/tutor", from: controller, options: .modal())
        } label: {
            iconView(type: type)
        }
    }

    private func iconView(type: ModuleNavBarButtons) -> some View {
        Circle()
            .fill(Color.disabledGray.opacity(0.2))
            .frame(width: 50, height: 50)
            .overlay(
                type.image.foregroundStyle(Color.textDarkest)
            )
    }
}
