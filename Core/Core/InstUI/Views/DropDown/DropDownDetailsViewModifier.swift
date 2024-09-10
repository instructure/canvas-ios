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

import SwiftUI

struct DropDownDetailsContainerViewModifier<DetailsContent: View>: ViewModifier {

    @Environment(\.layoutDirection) private var layoutDirection

    @Binding var state: DropDownButtonState
    @ViewBuilder let detailsContent: () -> DetailsContent

    @State private var screenFrame: CGRect = .zero
    @State private var preferredDetailsSize: CGSize?

    @AccessibilityFocusState var isFocused: Bool

    func body(content: Content) -> some View {
        content
            .accessibilityHidden(state.isDetailsShown)
            .allowsHitTesting(state.isDetailsShown == false)
            .background(content: {
                GeometryReader(content: { geometry in
                    Color.clear.screenFrame(geometry.frame(in: .global))
                })
            })
            .overlay(content: {

                if state.isDetailsShown {
                    let dims = state
                        .dimensions(given: screenFrame,
                                    prefSize: preferredDetailsSize)

                    ZStack {
                        Color
                            .clear
                            .contentShape(Rectangle())
                            .onTapGesture {
                                withAnimation {
                                    state.isDetailsShown = false
                                }
                            }
                            .accessibilityElement()
                            .accessibilitySortPriority(1)
                            .accessibilityHint(Text("Dismiss Drop Down Details", bundle: .core))
                            .accessibilityAction {
                                state.isDetailsShown = false
                            }

                        VStack {
                            Spacer()
                                .frame(width: 5, height: dims.topSpacerHeight)

                            HStack {

                                if layoutDirection == .leftToRight {
                                    Spacer().frame(width: dims.leftSpacerWidth, height: 5)
                                } else {
                                    Spacer()
                                }

                                ZStack {
                                    Color.backgroundLightest
                                    detailsContent()
                                        .accessibilityFocused($isFocused)
                                        .accessibilitySortPriority(2)
                                }
                                    .frame(maxWidth: dims.listMaxSize.width,
                                           maxHeight: dims.listMaxSize.height)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                    .shadow(color: .shadow(opacity: 0.16), radius: 100, y: 10)

                                if layoutDirection == .rightToLeft {
                                    Spacer().frame(width: dims.leftSpacerWidth, height: 5)
                                } else {
                                    Spacer()
                                }
                            }
                            Spacer()
                        }
                    }
                    .transition(
                        .opacity.combined(with: .scale(scale: 0.80)).animation(
                            .spring(duration: 0.25)
                        )
                    )
                }
            })
            .onPreferenceChange(DropDownDetailsSizePrefKey.self, perform: { size in
                preferredDetailsSize = size
            })
            .onPreferenceChange(ScreenFramePrefKey.self, perform: { value in
                screenFrame = value
            })
            .onChange(of: state.isDetailsShown) { newValue in
                if newValue { isFocused = true }
            }
    }
}

extension View {

    func dropDownDetailsContainer<C: View>(
        state: Binding<DropDownButtonState>,
        @ViewBuilder detailsContent: @escaping () -> C) -> some View {
        modifier(DropDownDetailsContainerViewModifier(state: state, detailsContent: detailsContent))
    }
}

private extension Color {
    static func shadow(opacity: CGFloat = 0.33) -> Color {
        Color(.sRGBLinear, white: 0, opacity: opacity)
    }
}
