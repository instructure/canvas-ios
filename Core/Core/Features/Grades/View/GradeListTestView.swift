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

struct GradeListTestView: View {
    @State private var showingHeader = true

    var body: some View {
        VStack {
            if showingHeader {
                togglesView
                    .transition(
                        .asymmetric(
                            insertion: .push(from: .top),
                            removal: .push(from: .bottom)
                        )
                    )
            }

            GeometryReader { outer in
                let outerHeight = outer.size.height
                ScrollView(.vertical) {
                    content
                        .background {
                            GeometryReader { proxy in
                                let contentHeight = proxy.size.height
                                let minY = max(
                                    min(0, proxy.frame(in: .named("ScrollView")).minY),
                                    outerHeight - contentHeight
                                )
                                Color.clear
                                    .onChange(of: minY) { oldVal, newVal in
                                        if (showingHeader && newVal < oldVal) || !showingHeader && newVal > oldVal {
                                            showingHeader = newVal > oldVal
                                        }
                                    }
                            }
                        }
                }
                .coordinateSpace(name: "ScrollView")
            }
            // Prevent scrolling into the safe area
            .padding(.top, 1)
        }
//        .background(.black)
        .animation(.easeInOut, value: showingHeader)
    }

    @ViewBuilder
    var content: some View {
        VStack(spacing: .zero) {
            ForEach([Color.red, .green, .blue, .yellow, .purple], id: \.hexString) { color in
                color
                    .frame(height: 200)
            }
        }
    }

    @ViewBuilder
    var togglesView: some View {
        VStack(spacing: 0) {
            InstUI.Toggle(isOn: .constant(true)) {
                Text("Based on graded assignments", bundle: .core)
                    .foregroundStyle(Color.textDarkest)
                    .font(.regular16)
                    .multilineTextAlignment(.leading)
            }
            .frame(minHeight: 51)
            .padding(.horizontal, 16)
            .accessibilityIdentifier("BasedOnGradedToggle")

            if true {
                Divider()

                InstUI.Toggle(isOn: .constant(true)) {
                    Text("Show What-if Score", bundle: .core)
                        .foregroundStyle(Color.textDarkest)
                        .font(.regular16)
                        .multilineTextAlignment(.leading)
                }
                .frame(minHeight: 51)
                .padding(.horizontal, 16)
            }
        }
    }
}

#Preview {
    GradeListTestView()
}
