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

public extension HorizonUI.FilterChip {
    enum Style {
        case unselected(title: String)
        case selected(title: String)
        case menu(MenuStyle)

        public struct MenuStyle {
            public enum Kind {
                case darkOutline
                case grayOutline
                case ghost
            }

            let kind: Kind
            let showCheckmark: Bool
            let headerAlignment: HorizontalAlignment
            let placeHolder: String
            let items: [HorizonUI.DropdownMenuItem]
            let selectedItem: HorizonUI.DropdownMenuItem?

            public init(
                kind: Kind,
                items: [HorizonUI.DropdownMenuItem] = [],
                headerAlignment: HorizontalAlignment,
                selectedItem: HorizonUI.DropdownMenuItem? = nil,
                showCheckmark: Bool = true,
                placeHolder: String
            ) {
                self.kind = kind
                self.items = items
                self.selectedItem = selectedItem
                self.headerAlignment = headerAlignment
                self.showCheckmark = showCheckmark
                self.placeHolder = placeHolder
            }

            public static func darkOutline(
                selectedItem: HorizonUI.DropdownMenuItem?,
                items: [HorizonUI.DropdownMenuItem],
                headerAlignment: HorizontalAlignment = .leading,
                showCheckmark: Bool = true,
                placeHolder: String
            ) -> MenuStyle {
                .init(
                    kind: .darkOutline,
                    items: items,
                    headerAlignment: headerAlignment,
                    selectedItem: selectedItem,
                    showCheckmark: showCheckmark,
                    placeHolder: placeHolder
                )
            }

            public static func grayOutline(
                selectedItem: HorizonUI.DropdownMenuItem?,
                items: [HorizonUI.DropdownMenuItem],
                headerAlignment: HorizontalAlignment = .leading,
                showCheckmark: Bool = true,
                placeHolder: String
            ) -> MenuStyle {
                .init(
                    kind: .grayOutline,
                    items: items,
                    headerAlignment: headerAlignment,
                    selectedItem: selectedItem,
                    showCheckmark: showCheckmark,
                    placeHolder: placeHolder
                )
            }

            public static func ghost(
                selectedItem: HorizonUI.DropdownMenuItem?,
                items: [HorizonUI.DropdownMenuItem],
                headerAlignment: HorizontalAlignment = .leading,
                showCheckmark: Bool = true,
                placeHolder: String
            ) -> MenuStyle {
                .init(
                    kind: .ghost,
                    items: items,
                    headerAlignment: headerAlignment,
                    selectedItem: selectedItem,
                    showCheckmark: showCheckmark,
                    placeHolder: placeHolder
                )
            }
        }
    }
}
