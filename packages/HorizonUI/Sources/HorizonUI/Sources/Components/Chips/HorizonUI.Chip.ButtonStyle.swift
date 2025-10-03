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

extension HorizonUI.Chip {
    struct ChipButtonStyle: ButtonStyle {
        private let cornerRadius: HorizonUI.CornerRadius = .level1
        let style: HorizonUI.Chip.Style
        let isFocused: Bool
        let size: HorizonUI.Chip.Size
        let opacity: Double

        init(
            style: HorizonUI.Chip.Style,
            isFocused: Bool,
            size: HorizonUI.Chip.Size,
            opacity: Double = .zero
        ) {
            self.style = style
            self.isFocused = isFocused
            self.size = size
            self.opacity = opacity
        }

        public func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .huiTypography(.p2)
                .foregroundStyle(style.foregroundColor)
                .padding(.horizontal, .huiSpaces.space8)
                .padding(.vertical, .huiSpaces.space2)
                .frame(height: size.rawValue)
                .background(Color.huiColors.surface.cardPrimary.opacity(opacity))
                .background(style.background(isPressed: configuration.isPressed))
                .clipShape(.rect(cornerRadius: cornerRadius.attributes.radius))
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius.attributes.radius)
                        .stroke(style.borderColor)
                )
                .opacity(style.state == .disable ? 0.5 : 1)
                .padding(.huiSpaces.space2)
        }
    }
}
