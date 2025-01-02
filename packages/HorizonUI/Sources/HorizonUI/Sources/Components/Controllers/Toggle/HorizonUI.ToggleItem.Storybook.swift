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

public extension HorizonUI.ToggleItem {
    struct Storybook: View {

        public var body: some View {
                Grid(alignment: .leading) {
                    GridRow {
                        HorizonUI.ToggleItem(
                            isOn: .constant(false),
                            title: "Content",
                            description: "Description"
                        )

                        HorizonUI.ToggleItem(
                            isOn: .constant(true),
                            title: "Content",
                            description: "Description"
                        )
                    }

                    GridRow {
                        HorizonUI.ToggleItem(
                            isOn: .constant(false),
                            title: "Content"
                        )
                        HorizonUI.ToggleItem(
                            isOn: .constant(true),
                            title: "Content"
                        )
                    }

                    GridRow {
                        HorizonUI.ToggleItem(
                            isOn: .constant(false),
                            title: "Content",
                            description: "Description",
                            isRequired: true
                        )

                        HorizonUI.ToggleItem(
                            isOn: .constant(true),
                            title: "Content",
                            description: "Description",
                            isRequired: true
                        )
                    }

                    GridRow(alignment: .top) {
                        HorizonUI.ToggleItem(
                            isOn: .constant(false),
                            title: "Content",
                            errorMessage: "Error Text"
                        )

                        HorizonUI.ToggleItem(
                            isOn: .constant(false),
                            title: "Content",
                            description: "Description",
                            errorMessage: "Error Text"
                        )
                    }

                    GridRow {
                        HorizonUI.ToggleItem(
                            isOn: .constant(false),
                            title: "Content",
                            isDisabled: true
                        )

                        HorizonUI.ToggleItem(
                            isOn: .constant(true),
                            title: "Content",
                            isDisabled: true
                        )
                    }
                }
            }
    }
}

#Preview {
    HorizonUI.ToggleItem.Storybook()
}
