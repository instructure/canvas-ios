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
    struct FilterChip: View {
        private let style: HorizonUI.FilterChip.Style
        private let state: HorizonUI.Chip.ChipState
        private let size: HorizonUI.Chip.Size
        private let onTap: () -> Void
        private let onSelect: (HorizonUI.DropdownMenuItem?) -> Void

        public init(
            style: HorizonUI.FilterChip.Style,
            state: HorizonUI.Chip.ChipState = .default,
            size: HorizonUI.Chip.Size = .medium,
            onTap: @escaping () -> Void = {},
            onSelect: @escaping (HorizonUI.DropdownMenuItem?) -> Void = { _ in }
        ) {
            self.style = style
            self.state = state
            self.size = size
            self.onTap = onTap
            self.onSelect = onSelect
        }
        public var body: some View {
            switch style {
            case .unselected(let title):
                HorizonUI.Chip(
                    title: title,
                    style: .custom(
                        .init(
                            state: state,
                            foregroundColor: Color.huiColors.text.title,
                            backgroundNormal: Color.huiColors.surface.cardPrimary,
                            backgroundPressed: Color.huiColors.surface.hover,
                            borderColor: Color.huiColors.surface.inversePrimary,
                            focusedBorderColor: Color.huiColors.surface.inversePrimary,
                            iconColor: Color.huiColors.surface.inversePrimary
                        )
                    ),
                    size: size
                ) { onTap() }

            case .selected(let title):
                HorizonUI.Chip(
                    title: title,
                    style: .custom(
                        .init(
                            state: state,
                            foregroundColor: Color.huiColors.text.surfaceColored,
                            backgroundNormal: Color.huiColors.surface.inversePrimary,
                            backgroundPressed: Color.huiColors.surface.inverseSecondary,
                            borderColor: Color.huiColors.surface.inversePrimary,
                            focusedBorderColor: Color.huiColors.surface.inversePrimary,
                            iconColor: Color.huiColors.icon.surfaceColored
                        )
                    ),
                    size: size,
                    leadingIcon: Image.huiIcons.check
                ) { onTap() }

            case .menu(let menu):
                HorizonUI.DropdownMenu(
                    items: menu.items,
                    selectedItem: menu.selectedItem,
                    style: style,
                    state: state,
                    size: size,
                    showCheckmark: menu.showCheckmark
                ) { itemSelected in
                   onSelect(itemSelected)
                }
            }
        }
    }
}

#Preview {
    HorizonUI.FilterChip(style: .selected(title: "Career APPsss"))
}
