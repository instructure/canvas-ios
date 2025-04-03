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

struct NotebookTitleBar: View {

    // MARK: - Dependencies

    private let onBack: ((WeakViewController) -> Void)?
    private let onClose: ((WeakViewController) -> Void)?

    // MARK: - Properties

    @Environment(\.viewController) private var viewController

    // MARK: - Init

    init(
        onBack: ((WeakViewController) -> Void)? = nil,
        onClose: ((WeakViewController) -> Void)? = nil
    ) {
        self.onBack = onBack
        self.onClose = onClose
    }

    // MARK: - Body

    var body: some View {
        HStack {
            backButton
            title
            closeButton
        }
        .background(HorizonUI.colors.surface.pagePrimary)
    }

    // MARK: - Private

    private var backButton: some View {
        HorizonUI.IconButton(
            .huiIcons.arrowBack,
            type: .white,
            isSmall: true
        ) {
            onBack?(viewController)
        }
        .disabled(onBack == nil)
        .opacity(onBack == nil ? 0 : 1)
        .huiElevation(level: .level4)
    }

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

    private var title: some View {
        HStack {
            HorizonUI.icons.menuBookNotebook
                .frame(width: 24, height: 24)

            Text("Notebook", bundle: .horizon)
                .huiTypography(.h3)
        }
        .frame(maxWidth: .infinity)
    }
}
