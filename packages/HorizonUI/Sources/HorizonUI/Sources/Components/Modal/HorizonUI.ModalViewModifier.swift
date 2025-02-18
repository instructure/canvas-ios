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

fileprivate extension HorizonUI {
    struct ModalViewModifier<Body: View>: ViewModifier {
        private let headerTitle: String
        private let headerIcon: Image?
        private let headerIconColor: Color?
        private let isShowCancelButton: Bool
        private let confirmButton: HorizonUI.ButtonAttribute?
        @Binding private var isPresented: Bool
        private let content: Body

        init(
            headerTitle: String,
            headerIcon: Image? = nil,
            headerIconColor: Color? = nil,
            isShowCancelButton: Bool = true,
            confirmButton:  HorizonUI.ButtonAttribute? = nil,
            isPresented: Binding<Bool>,
            @ViewBuilder body: () -> Body
        ) {
            self.headerTitle = headerTitle
            self.headerIcon = headerIcon
            self.headerIconColor = headerIconColor
            self.isShowCancelButton = isShowCancelButton
            self.confirmButton = confirmButton
            self._isPresented = isPresented
            self.content = body()
        }

        func body(content: Content) -> some View {
            ZStack {
                content

                if isPresented {
                    Color.huiColors.surface.inverseSecondary.opacity(0.75)
                        .ignoresSafeArea()
                    Modal(
                        headerTitle: headerTitle,
                        headerIcon: headerIcon,
                        headerIconColor: headerIconColor,
                        isShowCancelButton: isShowCancelButton,
                        confirmButton: confirmButton,
                        isPresented: $isPresented,
                        content: { self.content }
                    )
                }
            }
            .animation(.easeOut, value: isPresented)
        }
    }
}

public extension View {
    func huiModal<Content: View>(
        headerTitle: String,
        headerIcon: Image? = nil,
        headerIconColor: Color? = nil,
        isShowCancelButton: Bool = true,
        confirmButton: HorizonUI.ButtonAttribute? = nil,
        isPresented: Binding<Bool>,
        @ViewBuilder content: () -> Content
    ) -> some View {
        modifier(HorizonUI.ModalViewModifier(
            headerTitle: headerTitle,
            headerIcon: headerIcon,
            headerIconColor: headerIconColor,
            isShowCancelButton: isShowCancelButton,
            confirmButton: confirmButton,
            isPresented: isPresented,
            body: content
        ))
    }
}
