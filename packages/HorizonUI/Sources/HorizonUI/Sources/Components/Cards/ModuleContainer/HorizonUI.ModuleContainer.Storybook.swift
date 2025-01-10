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
public extension HorizonUI.ModuleContainer {
    struct Storybook: View {
        public var body: some View {
            ScrollView {
                VStack {
                    HorizonUI.ModuleContainer(
                        title: "Introduction this could be a very long name for a module so keep that in mind lol ",
                        status: .completed,
                        numberOfItems: 4
                    )

                    HorizonUI.ModuleContainer(
                        title: "Introduction this could be a very long name for a module so keep that in mind lol ",
                        status: .optional,
                        numberOfItems: 4,
                        duration: "10 mins",
                        isCollapsed: true
                    )

                    HorizonUI.ModuleContainer(
                        title: "[Module name]",
                        subtitle: "Choose and complete one of the required items.",
                        status: .inProgress,
                        numberOfItems: 4,
                        duration: "XX Min",
                        isCollapsed: true
                    )

                    HorizonUI.ModuleContainer(
                        title: "[Module name]",
                        status: .notStarted,
                        numberOfItems: 4,
                        numberOfPastDueItems: 3,
                        duration: "XX Min"
                    )

                    HorizonUI.ModuleContainer(
                        title: "[Module name]",
                        status: .locked,
                        numberOfItems: 4,
                        numberOfPastDueItems: 32
                    )
                }
                .padding()
            }
            .frame(maxWidth: .infinity)
            .background(Color.gray.opacity(0.2))
        }
    }
}

#Preview {
    HorizonUI.ModuleContainer.Storybook()
}
