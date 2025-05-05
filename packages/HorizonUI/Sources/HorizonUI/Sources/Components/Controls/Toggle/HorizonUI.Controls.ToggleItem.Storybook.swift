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

public extension HorizonUI.Controls.ToggleItem {
    struct Storybook: View {
        @State private var toggleStates: [Bool] = [false, true, false, true, false, true, false, false, false, true]

        public var body: some View {
            Grid(alignment: .leading) {
                GridRow {
                    HorizonUI.Controls.ToggleItem(
                        isOn: $toggleStates[0],
                        title: "Content",
                        description: "Description"
                    )
                    HorizonUI.Controls.ToggleItem(
                        isOn: $toggleStates[1],
                        title: "Content",
                        description: "Description"
                    )
                }

                GridRow {
                    HorizonUI.Controls.ToggleItem(
                        isOn: $toggleStates[2],
                        title: "Content"
                    )
                    HorizonUI.Controls.ToggleItem(
                        isOn: $toggleStates[3],
                        title: "Content"
                    )
                }

                GridRow {
                    HorizonUI.Controls.ToggleItem(
                        isOn: $toggleStates[4],
                        title: "Content",
                        description: "Description",
                        isRequired: true
                    )
                    HorizonUI.Controls.ToggleItem(
                        isOn: $toggleStates[5],
                        title: "Content",
                        description: "Description",
                        isRequired: true
                    )
                }

                GridRow(alignment: .top) {
                    HorizonUI.Controls.ToggleItem(
                        isOn: $toggleStates[6],
                        title: "Content",
                        errorMessage: "Error Text"
                    )
                    HorizonUI.Controls.ToggleItem(
                        isOn: $toggleStates[7],
                        title: "Content",
                        description: "Description",
                        errorMessage: "Error Text"
                    )
                }
                
                GridRow {
                    HorizonUI.Controls.ToggleItem(
                        isOn: $toggleStates[8],
                        title: "Content",
                        isDisabled: true
                    )
                    HorizonUI.Controls.ToggleItem(
                        isOn: $toggleStates[9],
                        title: "Content",
                        isDisabled: true
                    )
                }
            }
        }

    }
}

#Preview {
    HorizonUI.Controls.ToggleItem.Storybook()
}
