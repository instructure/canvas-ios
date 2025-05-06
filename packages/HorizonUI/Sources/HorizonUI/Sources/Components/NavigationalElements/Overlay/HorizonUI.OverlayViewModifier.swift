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

extension HorizonUI.Overlay {
    struct OverlayViewModifier: ViewModifier {
        // MARK: - Private Properties

        private let optionHeight: CGFloat = 55
        private let sheetHeight: CGFloat = 130

        // MARK: - Dependencies

        let title: String
        let buttons: [ButtonAttribute]
        @Binding var isPresented: Bool

        func body(content: Content) -> some View {
            content
                .sheet(isPresented: $isPresented) {
                    HorizonUI.Overlay(
                        title: title,
                        buttons: buttons,
                        isPresented: $isPresented
                    )
                    .presentationCompactAdaptation(.sheet)
                    .presentationCornerRadius(32)
                    .interactiveDismissDisabled()
                    .presentationDetents([.height(sheetHeight + (CGFloat(buttons.count) * optionHeight))])
                }
        }
    }
}

public extension View {
    func huiOverlay(
        title: String, buttons: [HorizonUI.Overlay.ButtonAttribute], isPresented: Binding<Bool>
    ) -> some View {
        modifier(
            HorizonUI.Overlay.OverlayViewModifier(
                title: title,
                buttons: buttons,
                isPresented: isPresented
            )
        )
    }
}
