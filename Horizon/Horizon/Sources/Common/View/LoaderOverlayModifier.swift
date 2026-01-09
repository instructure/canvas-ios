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

import HorizonUI
import SwiftUI

private struct LoaderOverlayModifier: ViewModifier {
    let isVisible: Bool
    let accessibilityLabel: String

    func body(content: Content) -> some View {
        content
            .overlay {
                if isVisible {
                    ZStack {
                        // Need padding to make the back button visiable
                        Color.huiColors.surface.pageSecondary
                            .padding(.top, 100)

                        HorizonUI.Spinner(
                            size: .small,
                            showBackground: true
                        )
                        .accessibilityLabel(accessibilityLabel)
                    }
                }
            }
    }
}

extension View {
    func huiLoader(
        isVisible: Bool,
        accessibilityLabel: String = String(localized: "Loading")
    ) -> some View {
        modifier(
            LoaderOverlayModifier(
                isVisible: isVisible,
                accessibilityLabel: accessibilityLabel
            )
        )
    }
}
