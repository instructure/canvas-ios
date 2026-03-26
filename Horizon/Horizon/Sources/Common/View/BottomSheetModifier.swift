//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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

private struct BottomSheetModifier<SheetContent: View>: ViewModifier {
    @AccessibilityFocusState private var isFocused: Bool
    @Binding var isPresented: Bool
    let cornerRadius: CGFloat
    let backgroundColor: Color
    let backgroundDismissible: Bool
    let onDismiss: (() -> Void)?
    @ViewBuilder let content: SheetContent

    func body(content: Content) -> some View {
        content.overlay(alignment: .bottom) {
            ZStack(alignment: .bottom) {
                if isPresented {
                    Color.black.opacity(0.2)
                        .ignoresSafeArea()
                        .transition(.opacity)
                        .onTapGesture {
                            if backgroundDismissible {
                                isPresented = false
                                onDismiss?()
                            }
                        }
                        .accessibilityElement(children: .ignore)
                        .accessibilityAddTraits(.isButton)
                        .accessibilityLabel(String(localized: "Close"))

                    self.content
                        .background(
                            backgroundColor
                                .clipShape(
                                    .rect(
                                        topLeadingRadius: cornerRadius,
                                        bottomLeadingRadius: 0,
                                        bottomTrailingRadius: 0,
                                        topTrailingRadius: cornerRadius
                                    )
                                )
                                .ignoresSafeArea(edges: .bottom)
                        )
                        .accessibilityFocused($isFocused, equals: true)
                        .transition(.move(edge: .bottom))
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                                isFocused = true
                            }
                        }
                }
            }
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity,
                alignment: .bottom
            )
            .animation(.easeInOut, value: isPresented)
        }
    }
}

extension View {
    func bottomSheet<Content: View>(
        isPresented: Binding<Bool>,
        cornerRadius: CGFloat = 25,
        backgroundColor: Color = Color.huiColors.surface.cardPrimary,
        backgroundDismissible: Bool = true,
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        modifier(
            BottomSheetModifier(
                isPresented: isPresented,
                cornerRadius: cornerRadius,
                backgroundColor: backgroundColor,
                backgroundDismissible: backgroundDismissible,
                onDismiss: onDismiss,
                content: content
            )
        )
    }
}
