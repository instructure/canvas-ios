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

extension HorizonUI.Radio {
    struct Storybook: View {
        @State private var selectedOptions: [Bool] = Array(repeating: false, count: 12)

        var body: some View {
            Grid(alignment: .leading) {
                GridRow {
                    HorizonUI.Radio(
                        isOn: $selectedOptions[0],
                        title: "Content"
                    )
                    HorizonUI.Radio(
                        isOn: $selectedOptions[1],
                        title: "Content"
                    )
                }
                GridRow {
                    HorizonUI.Radio(
                        isOn: $selectedOptions[2],
                        title: "Content",
                        isRequired: true
                    )
                    HorizonUI.Radio(
                        isOn: $selectedOptions[3],
                        title: "Content",
                        isRequired: false
                    )
                }
                GridRow {
                    HorizonUI.Radio(
                        isOn: $selectedOptions[4],
                        title: "Content",
                        description: "Description"
                    )
                    HorizonUI.Radio(
                        isOn: $selectedOptions[5],
                        title: "Content",
                        description: "Description"
                    )
                }
                GridRow {
                    HorizonUI.Radio(
                        isOn: $selectedOptions[6],
                        title: "Content",
                        description: "Description",
                        isRequired: true
                    )
                    HorizonUI.Radio(
                        isOn: $selectedOptions[7],
                        title: "Content",
                        description: "Description",
                        isRequired: true
                    )
                }
                GridRow(alignment: .top) {
                    HorizonUI.Radio(
                        isOn: $selectedOptions[8],
                        title: "Content",
                        errorMessage: "Error Text"
                    )
                    HorizonUI.Radio(
                        isOn: $selectedOptions[9],
                        title: "Content",
                        description: "Description",
                        errorMessage: "Error Text"
                    )
                }
                GridRow {
                    HorizonUI.Radio(
                        isOn: $selectedOptions[10],
                        title: "Content",
                        isDisabled: true
                    )
                    HorizonUI.Radio(
                        isOn: $selectedOptions[11],
                        title: "Content",
                        isDisabled: true
                    )
                }
            }
        }

    }
}

#Preview {
    HorizonUI.Radio.Storybook()
}

