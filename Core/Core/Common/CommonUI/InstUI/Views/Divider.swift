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

extension InstUI {

    public struct Divider: View {
        public enum Style {
            case full
            case padded
            case hidden
        }

        private let style: Style

        public init(_ style: Style = .full) {
            self.style = style
        }

        public init(isLast: Bool) {
            self.style = isLast ? .full : .padded
        }

        public var body: some View {
            switch style {
            case .full:
                divider
            case .padded:
                divider.paddingStyle(.horizontal, .standard)
            case .hidden:
                SwiftUI.EmptyView()
            }
        }

        private var divider: some View {
            SwiftUI.Divider()
                .overlay(Color.borderMedium)
        }
    }

    /// A Divider that slides under the view above it.
    /// It can be used before the first item of a list to make it
    /// have a top divider visible only when it is scrolled down.
    public struct TopDivider: View {
        private static let offset: CGFloat = 1

        private let style: Divider.Style
        private let backgroundColor: Color

        public init(
            _ style: Divider.Style = .full,
            backgroundColor: Color = .backgroundLightest
        ) {
            self.style = style
            self.backgroundColor = backgroundColor
        }

        public var body: some View {
            backgroundColor
                .frame(height: Self.offset)
                .overlay {
                    InstUI.Divider(style)
                        .offset(y: -Self.offset)
                }
        }
    }
}

#if DEBUG

#Preview("Vertical") {
    VStack {
        Text(verbatim: "AAA")
        InstUI.Divider()
        Text(verbatim: "BBB")
    }
}

#Preview("Horizontal") {
    HStack {
        Text(verbatim: "AAA")
        InstUI.Divider()
        Text(verbatim: "BBB")
    }
}

#endif
