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

extension HorizonUI.Controls {
    struct Storybook: View {
        public var body: some View {
            ScrollView(showsIndicators: false) {
                VStack {
                    titleView("Checkbox")
                    HorizonUI.Controls.Checkbox.Storybook()
                    titleView("ToggleItem")

                    HorizonUI.Controls.ToggleItem.Storybook()
                    titleView("Radio")
                    HorizonUI.Controls.Radio.Storybook()
                }
                .padding(16)
                .navigationTitle("Controls")
            }
        }

        private func titleView(_ title: String) -> some View {
            Text(title)
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 8)
        }
    }
}

#Preview {
    HorizonUI.Controls.Storybook()
}
