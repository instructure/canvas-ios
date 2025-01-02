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

extension HorizonUI.Checkbox {
    struct Storybook: View {
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
                HorizonUI.Checkbox(
                    isOn: .constant(false),
                    style: .default,
                    title: "Title"
                )

                HorizonUI.Checkbox(
                    isOn: .constant(true),
                    style: .default,
                    title: "Title"
                )

                HorizonUI.Checkbox(
                    isOn: .constant(true),
                    style: .partial,
                    title: "Title"
                )
            }
        }

        private var requiredView: some View {
            GridRow {
                HorizonUI.Checkbox(
                    isOn: .constant(false),
                    style: .default,
                    title: "Title",
                    isRequired: true
                )

                HorizonUI.Checkbox(
                    isOn: .constant(true),
                    style: .default,
                    title: "Title",
                    isRequired: true
                )

                HorizonUI.Checkbox(
                    isOn: .constant(true),
                    style: .partial,
                    title: "Title",
                    isRequired: true
                )
            }
        }

        private var descriptionView: some View {
            GridRow {
                HorizonUI.Checkbox(
                    isOn: .constant(false),
                    style: .default,
                    title: "Title",
                    description: "Description",
                    isRequired: true
                )

                HorizonUI.Checkbox(
                    isOn: .constant(true),
                    style: .default,
                    title: "Title",
                    description: "Description",
                    isRequired: true
                )

                HorizonUI.Checkbox(
                    isOn: .constant(true),
                    style: .partial,
                    title: "Title",
                    description: "Description",
                    isRequired: true
                )
            }
        }

        private var errorView: some View {
            GridRow(alignment: .top) {
                HorizonUI.Checkbox(
                    isOn: .constant(false),
                    style: .error,
                    title: "Title",
                    description: "Description",
                    errorMessage: "Error Text",
                    isRequired: false
                )
                
                HorizonUI.Checkbox(
                    isOn: .constant(false),
                    style: .error,
                    title: "Title",
                    errorMessage: "Error Text",
                    isRequired: false
                )
            }
        }

        private var disDisabledView: some View {
            GridRow {
                HorizonUI.Checkbox(
                    isOn: .constant(false),
                    style: .default,
                    title: "Title",
                    description: "Description",
                    isRequired: true,
                    isDisabled: true
                )
                
                HorizonUI.Checkbox(
                    isOn: .constant(true),
                    style: .default,
                    title: "Title",
                    description: "Description",
                    isRequired: true,
                    isDisabled: true
                )
                
                HorizonUI.Checkbox(
                    isOn: .constant(true),
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
    HorizonUI.Checkbox.Storybook()
}
