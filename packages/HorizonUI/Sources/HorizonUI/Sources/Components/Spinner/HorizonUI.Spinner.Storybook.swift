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

extension HorizonUI.Spinner {
    struct Storybook: View {
        public var body: some View {
            ScrollView {
                VStack(spacing: 20) {
                    HStack(spacing: 10) {
                        HorizonUI.Spinner(size: .xSmall)
                        HorizonUI.Spinner(size: .small)
                        HorizonUI.Spinner(size: .medium)
                        HorizonUI.Spinner(size: .large)
                    }
                    HStack(spacing: 10) {
                        HorizonUI.Spinner(size: .xSmall, showBackground: true)
                        HorizonUI.Spinner(size: .small, showBackground: true)
                        HorizonUI.Spinner(size: .medium, showBackground: true)
                        HorizonUI.Spinner(size: .large, showBackground: true)
                    }
                }
            }
            .navigationTitle("Spinners")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

#Preview {
    HorizonUI.Spinner.Storybook()
}
