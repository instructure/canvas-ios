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

extension HorizonUI.FilterChip {
    struct Storybook: View {
        var body: some View {
            VStack(alignment: .leading) {
                unselectedChip
                selectedChip
                darkMenu
                    .padding(.bottom, 120)
                grayMenu
                    .padding(.bottom, 120)
                ghostMenu
                Spacer()
            }
        }

        private var selectedChip: some View {
           VStack {
               Text("Selected Chip")
                   .frame(maxWidth: .infinity, alignment: .leading)
                HStack {
                    HorizonUI.FilterChip(style: .selected(title: "Career APP"), state: .focused)
                    HorizonUI.FilterChip(style: .selected(title: "Career APP"), state: .default)
                    HorizonUI.FilterChip(style: .selected(title: "Career APP"), state: .disable)
                }
            }
        }

        private var unselectedChip: some View {
            VStack {
                Text("Unselected Chip")
                    .frame(maxWidth: .infinity, alignment: .leading)
                HStack {
                    HorizonUI.FilterChip(style: .unselected(title: "Career APP"), state: .focused)
                    HorizonUI.FilterChip(style: .unselected(title: "Career APP"), state: .default)
                    HorizonUI.FilterChip(style: .unselected(title: "Career APP"), state: .disable)
                }
            }
        }

        private var darkMenu: some View {
            VStack {
                Text("Dark menu")
                    .frame(maxWidth: .infinity, alignment: .leading)
                HorizonUI.FilterChip(
                    style: .menu(
                        .darkOutline(
                            selectedItem: nil,
                            items: HorizonUI.DropdownMenuItem.mock,
                            headerAlignment: .leading,
                            showCheckmark: true,
                            placeHolder: "Please select"
                        )
                    )
                )
            }
        }

        private var grayMenu: some View {
            VStack {
                Text("Gray menu")
                    .frame(maxWidth: .infinity, alignment: .leading)
                HorizonUI.FilterChip(
                    style: .menu(
                        .grayOutline(
                            selectedItem: nil,
                            items: HorizonUI.DropdownMenuItem.mock,
                            headerAlignment: .center,
                            showCheckmark: false,
                            placeHolder: "Please select"
                        )
                    )
                )
            }
        }

        private var ghostMenu: some View {
            VStack {
                Text("Ghost menu")
                    .frame(maxWidth: .infinity, alignment: .leading)
                HorizonUI.FilterChip(
                    style: .menu(
                        .ghost(
                            selectedItem: nil,
                            items: HorizonUI.DropdownMenuItem.mock,
                            headerAlignment: .trailing,
                            showCheckmark: true,
                            placeHolder: "Please select"
                        )
                    )
                )
            }
        }
    }
}

#Preview {
    HorizonUI.FilterChip.Storybook()
        .padding()
}
