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

public extension HorizonUI.Cards {
    struct Storybook: View {
        public var body: some View {
            ScrollView {
                VStack {
                    Text("Module Container")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    HorizonUI.ModuleContainer.Storybook()
                    Text("Module Item Card")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    HorizonUI.LearningObjectItem.Storybook()
                    Text("Learning Object Card")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    HorizonUI.LearningObjectCard.Storybook()
                }
            }
            .navigationTitle("Cards")
            .padding()
            .background(Color.black.opacity(0.1))
        }
    }
}

#Preview {
    HorizonUI.Cards.Storybook()
}

public extension HorizonUI {
    struct Cards { }
}
