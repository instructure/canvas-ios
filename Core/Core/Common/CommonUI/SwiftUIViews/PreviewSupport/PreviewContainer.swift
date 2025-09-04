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

#if DEBUG

/// Moves the `content` to the top, so we don't need to scroll down all the time,
/// when Preview is displayed at the bottom.
/// Embeds the `content` in `VStack` with zero padding by default.
public struct PreviewContainer<Content: View>: View {

    private let alignment: HorizontalAlignment
    private let spacing: CGFloat?
    private let content: () -> Content

    public init(
        alignment: HorizontalAlignment = .center,
        spacing: CGFloat? = 0,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.alignment = alignment
        self.spacing = spacing
        self.content = content
    }

    public var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(alignment: alignment, spacing: spacing) {
                    content()
                }
                .padding(.top)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .scrollBounceBehavior(.basedOnSize)
    }
}

#endif
