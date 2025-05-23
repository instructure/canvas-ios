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
import HorizonUI
import SwiftUI

struct TitleBar<Content>: View where Content: View {

    // MARK: - Dependencies

    private let color: Color
    private let onBack: ((WeakViewController) -> Void)?
    private let onClose: ((WeakViewController) -> Void)?
    private let title: Content

    // MARK: - Properties

    @Environment(\.viewController) private var viewController

    // MARK: - Init

    init(
        onBack: ((WeakViewController) -> Void)? = nil,
        onClose: ((WeakViewController) -> Void)? = nil,
        color: Color = HorizonUI.colors.surface.pagePrimary,
        @ViewBuilder title: () -> Content
    ) {
        self.onBack = onBack
        self.onClose = onClose
        self.color = color
        self.title = title()
    }

    // MARK: - Body

    var body: some View {
        HStack {
            HorizonBackButton(onBack: () { self.onBack?(viewController) })
            titleView
            closeButton
        }
        .background(color)
    }

    // MARK: - Private

    private var closeButton: some View {
        HorizonUI.IconButton(
            .huiIcons.close,
            type: .white,
            isSmall: true
        ) {
            onClose?(viewController)
        }
        .disabled(onClose == nil)
        .opacity(onClose == nil ? 0 : 1)
        .huiElevation(level: .level4)
    }

    private var titleView: some View {
        title
            .frame(maxWidth: .infinity)
    }
}
