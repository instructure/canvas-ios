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

public extension HorizonUI {
    struct ActionChip: View {
        @AccessibilityFocusState private var isFocused: Bool
        private let cornerRadius: HorizonUI.CornerRadius = .level1

        // MARK: - Dependencies

        private let title: String
        private let style: HorizonUI.Chip.Style
        private let size: HorizonUI.Chip.Size
        private let leadingIcon: Image?
        private let onTap: () -> Void

        // MARK: - Init

        public init(
            title: String,
            style: HorizonUI.Chip.Style,
            size: HorizonUI.Chip.Size,
            leadingIcon: Image? = nil,
            onTap: @escaping () -> Void
        ) {
            self.title = title
            self.style = style
            self.size = size
            self.leadingIcon = leadingIcon
            self.onTap = onTap
        }

        public var body: some View {
            Button {
                onTap()
            } label: {
                HStack(spacing: .huiSpaces.space2) {
                    if let leadingIcon {
                        leadingIcon
                            .resizable()
                            .frame(width: 12, height: 12)
                            .foregroundStyle(style.iconForeground())
                    }
                    Text(title)
                }
            }
            .disabled(style.state == .disable)
            .buttonStyle(
                HorizonUI.Chip.ChipButtonStyle(
                    style: style,
                    isFocused: isFocused,
                    size: size,
                    opacity: style.opacity
                )
            )
            .accessibilityFocused($isFocused)
            .padding(.huiSpaces.space2)
            .overlay {
                if isFocused || style.state == .focused {
                    RoundedRectangle(cornerRadius: cornerRadius.attributes.radius)
                        .stroke(style.focusedBorderColor, lineWidth: 2)
                }
            }
        }
    }
}

#Preview {
    HorizonUI.ActionChip(
        title: "Body Text",
        style: .ai(state: .default),
        size: .small,
        leadingIcon: Image.huiIcons.ai
    ) { }
}
