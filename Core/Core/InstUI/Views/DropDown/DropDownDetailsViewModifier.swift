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

struct DropDownDetailsViewModifier<ListContent: View>: ViewModifier {
    @Binding var state: DropDownButtonState
    @ViewBuilder let listContent: () -> ListContent

    @State private var screenFrame: CGRect = .zero
    @State private var preferredDetailsHeight: CGFloat?

    func body(content: Content) -> some View {
        content
            .background(content: {
                GeometryReader(content: { geometry in
                    Color.clear.screenFrame(geometry.frame(in: .global))
                })
            })
            .overlay(content: {

                if state.isDetailsShown {
                    let dims = state
                        .dimensions(given: screenFrame,
                                    prefHeight: preferredDetailsHeight)

                    ZStack {
                        Color
                            .clear
                            .contentShape(Rectangle())
                            .onTapGesture {
                                withAnimation {
                                    state.isDetailsShown = false
                                }
                        }

                        VStack {
                            Spacer()
                                .frame(width: 100, height: dims.topSpacerHeight)
                                .border(Color.green)

                            HStack {
                                Spacer()

                                    .frame(width: dims.leftSpacerWidth, height: 100)
                                    .border(Color.mint)

                                ZStack {
                                    Color.white
                                    listContent()

                                }
                                    .frame(maxWidth: dims.listMaxSize.width,
                                           maxHeight: dims.listMaxSize.height)
                                    .clipped()
                                    .shadow(radius: 4)
                                    .border(Color.blue)
                                Spacer()
                            }
                            Spacer()
                        }
                    }
                    .transition(
                        .opacity.animation(
                            .spring(duration: 0.3)
                        )
                    )
                }
            })
            .onPreferenceChange(DropDownDetailsHeightPrefKey.self, perform: { value in
                preferredDetailsHeight = value
            })
            .onPreferenceChange(ScreenFramePrefKey.self, perform: { value in
                screenFrame = value
            })
    }
}

extension View {

    func dropDownDetails<C: View>(
        state: Binding<DropDownButtonState>,
        @ViewBuilder content: @escaping () -> C) -> some View {
        modifier(DropDownDetailsViewModifier(state: state, listContent: content))
    }
}
