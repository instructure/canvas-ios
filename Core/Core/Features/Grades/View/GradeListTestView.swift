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

public struct GradeListTestView: View {
    @State var headerHeight: CGFloat?
    @State var scrollOffset: CGFloat?

    public init(headerHeight: CGFloat? = nil, scrollOffset: CGFloat? = nil) {
        self.headerHeight = headerHeight
        self.scrollOffset = scrollOffset
    }

    public var body: some View {
        ZStack(alignment: .top) {
            ScrollView {
                VStack(spacing: .zero) {
                    Color.clear.frame(height: 0)
                        .bindTopPosition(
                            id: "scrollPosition",
                            coordinateSpaceName: "scroll",
                            to: $scrollOffset
                        )

                    Color.clear.frame(height: 0)
                        .padding(.top, headerHeight)

                    ForEach([Color.red, .green, .blue, .yellow, .purple], id: \.hexString) { color in
                        color
                            .frame(height: 200)
                    }
                }
            }
            .coordinateSpace(name: "scroll")

            TogglesView(scrollOffset: scrollOffset ?? 0)
                .onFrameChange(id: "header", coordinateSpace: .local) { newFrame in
                    if headerHeight == nil || newFrame.height > headerHeight ?? 0 {
                        self.headerHeight = newFrame.height
                    }
                }
        }
    }
}

struct TogglesView: View {
    @State var originalHeight: CGFloat?

    let scrollOffset: CGFloat

    var body: some View {
        let height: CGFloat? = {
            guard let originalHeight else {
                return nil
            }

            if scrollOffset > 0 {
                return originalHeight
            }

            return max(0, originalHeight + scrollOffset)
        }()

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

            Divider()

            InstUI.Toggle(isOn: .constant(false)) {
                Text("Show What-if Score", bundle: .core)
                    .foregroundStyle(Color.textDarkest)
                    .font(.regular16)
                    .multilineTextAlignment(.leading)
            }
            .frame(minHeight: 51)
            .padding(.horizontal, 16)
            .onFrameChange(id: "collapsableHeader", coordinateSpace: .global) { frame in
                if originalHeight == nil {
                    self.originalHeight = frame.height
                }
            }
            .frame(maxHeight: height, alignment: .bottom)
            .clipped()
        }
        .background(Color.backgroundLight)
    }
}

struct CollapsableHeader: View {
    let scrollOffset: CGFloat
    @State var originalHeight: CGFloat?

    var body: some View {
        let height: CGFloat? = {
            guard let originalHeight else {
                return nil
            }

            if scrollOffset > 0 {
                return originalHeight
            }

            return max(0, originalHeight + scrollOffset)
        }()

        VStack {
            Text(scrollOffset)
            Text("Should collapse")
                .onFrameChange(id: "collapsableHeader", coordinateSpace: .global) { frame in
                    if originalHeight == nil {
                        self.originalHeight = frame.height
                    }
                }
                .frame(maxHeight: height, alignment: .bottom)
                .background(.thinMaterial)
                .clipped()
        }
    }
}

#Preview {
    GradeListTestView()
}
