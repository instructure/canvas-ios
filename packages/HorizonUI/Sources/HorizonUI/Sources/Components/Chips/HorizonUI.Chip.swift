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

extension HorizonUI {
    public struct Chip: View {
        @AccessibilityFocusState private var isFocused: Bool
        private let cornerRadius: HorizonUI.CornerRadius = .level1

        // MARK: - Dependencies

        private let title: String
        private let style: HorizonUI.Chip.Style
        private let size: HorizonUI.Chip.Size
        private let leadingIcon: Image?
        private let trallingIcon: Image?
        private let onTap: () -> Void

        // MARK: - Init

       public init(
            title: String,
            style: HorizonUI.Chip.Style,
            size: HorizonUI.Chip.Size,
            leadingIcon: Image? = nil,
            trallingIcon: Image? = nil,
            onTap: @escaping () -> Void
        ) {
            self.title = title
            self.style = style
            self.size = size
            self.leadingIcon = leadingIcon
            self.trallingIcon = trallingIcon
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
                        .frame(maxWidth: .infinity, alignment: .leading)

                    if let trallingIcon {
                        Spacer()
                        trallingIcon
                            .resizable()
                            .frame(width: 12, height: 12)
                    }
                }
            }
            .disabled(style.state == .disable)
            .buttonStyle(
                ChipButtonStyle(
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
    VStack {
        ZStack {
            Color.huiColors.surface.cardSecondary
            VStack {
                HorizonUI.Chip(
                    title: "Body Text",
                    style: .ai(state: .default),
                    size: .small,
                    leadingIcon: Image.huiIcons.ai
                ) { }
                HorizonUI.Chip(
                    title: "Body Text",
                    style: .ai(state: .disable),
                    size: .medium,
                    leadingIcon: Image.huiIcons.ai
                ) { }
                HorizonUI.Chip(
                    title: "Body Text",
                    style: .ai(state: .focused),
                    size: .medium,
                    leadingIcon: Image.huiIcons.ai
                ) { }

                HorizonUI.Chip(
                    title: "Body Text",
                    style: .primary(state: .default),
                    size: .small,
                    leadingIcon: Image.huiIcons.ai
                ) {}

                HorizonUI.Chip(
                    title: "Body Text",
                    style: .primary(state: .disable),
                    size: .large,
                    leadingIcon: Image.huiIcons.ai
                ) {}
                HorizonUI.Chip(
                    title: "Body Text",
                    style: .primary(state: .focused),
                    size: .large,
                    leadingIcon: Image.huiIcons.ai
                ) {}
                Spacer()
            }
        }
        Spacer()
    }
}
