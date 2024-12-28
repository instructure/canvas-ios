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

public extension HorizonUI.ModuleItemCard {
    struct Storybook: View {

        public var body: some View {
            ScrollView {
                VStack {
                    HorizonUI.ModuleItemCard(
                        name: "Module Item Name",
                        type: .externalLink,
                        duration: "XX Mins"
                    )

                    HorizonUI.ModuleItemCard(
                        name: "Module Item Name",
                        type: .externalLink,
                        duration: "XX Mins",
                        dueDate: "22/12",
                        points: 22
                    )

                    HorizonUI.ModuleItemCard(
                        name: "Module Item Name",
                        type: .externalLink,
                        duration: "XX Mins",
                        dueDate: "22/12",
                        points: 22,
                        isOverdue: true
                    )

                }.padding()
            }
        }
    }
}

#Preview {
    HorizonUI.ModuleItemCard.Storybook()
}

struct DummyDemo: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("Hello, World!")
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(.red)
    }
}
