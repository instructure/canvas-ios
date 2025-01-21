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

extension HorizonUI.Controls.Checkbox {
    struct Storybook: View {
        @State private var checkboxStates: [Bool] = [false, true, true, false, true, true, false, true, true, false, false, false, true, true, true, true]

        var body: some View {
            Grid(alignment: .leading) {
                notRequiredView
                requiredView
                descriptionView
                errorView
                disDisabledView
            }
        }

        private var notRequiredView: some View {
            GridRow {
                HorizonUI.Controls.Checkbox(
                    isOn: $checkboxStates[0],
                    style: .default,
                    title: "Title"
                )
                HorizonUI.Controls.Checkbox(
                    isOn: $checkboxStates[1],
                    style: .default,
                    title: "Title"
                )
                HorizonUI.Controls.Checkbox(
                    isOn: $checkboxStates[2],
                    style: .partial,
                    title: "Title"
                )
            }
        }

        private var requiredView: some View {
            GridRow {
                HorizonUI.Controls.Checkbox(
                    isOn: $checkboxStates[3],
                    style: .default,
                    title: "Title",
                    isRequired: true
                )
                HorizonUI.Controls.Checkbox(
                    isOn: $checkboxStates[4],
                    style: .default,
                    title: "Title",
                    isRequired: true
                )
                HorizonUI.Controls.Checkbox(
                    isOn: $checkboxStates[5],
                    style: .partial,
                    title: "Title",
                    isRequired: true
                )
            }
        }

        private var descriptionView: some View {
            GridRow {
                HorizonUI.Controls.Checkbox(
                    isOn: $checkboxStates[6],
                    style: .default,
                    title: "Title",
                    description: "Description",
                    isRequired: true
                )
                HorizonUI.Controls.Checkbox(
                    isOn: $checkboxStates[7],
                    style: .default,
                    title: "Title",
                    description: "Description",
                    isRequired: true
                )
                HorizonUI.Controls.Checkbox(
                    isOn: $checkboxStates[8],
                    style: .partial,
                    title: "Title",
                    description: "Description",
                    isRequired: true
                )
            }
        }

        private var errorView: some View {
            GridRow(alignment: .top) {
                HorizonUI.Controls.Checkbox(
                    isOn: $checkboxStates[9],
                    style: .error,
                    title: "Title",
                    description: "Description",
                    errorMessage: "Error Text",
                    isRequired: false
                )
                HorizonUI.Controls.Checkbox(
                    isOn: $checkboxStates[10],
                    style: .error,
                    title: "Title",
                    errorMessage: "Error Text",
                    isRequired: false
                )
            }
        }

        private var disDisabledView: some View {
            GridRow {
                HorizonUI.Controls.Checkbox(
                    isOn: $checkboxStates[11],
                    style: .default,
                    title: "Title",
                    description: "Description",
                    isRequired: true,
                    isDisabled: true
                )
                HorizonUI.Controls.Checkbox(
                    isOn: $checkboxStates[12],
                    style: .default,
                    title: "Title",
                    description: "Description",
                    isRequired: true,
                    isDisabled: true
                )
                HorizonUI.Controls.Checkbox(
                    isOn: $checkboxStates[13],
                    style: .partial,
                    title: "Title",
                    description: "Description",
                    isRequired: true,
                    isDisabled: true
                )
            }
        }
    }
}

#Preview {
    HorizonUI.Controls.Checkbox.Storybook()
}
