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

public extension HorizonUI.LearningObjectItem {
    struct Storybook: View {

        public var body: some View {
            ScrollView {
                VStack {
                    HorizonUI.LearningObjectItem(
                        name: "Module Item Name",
                        isSelected: true,
                        requirement: .required,
                        status: .completed,
                        type: .externalLink,
                        duration: "XX Mins",
                        points: "22",
                        description: "Score at least 10",
                        isOverdue: false
                    )

                    HorizonUI.LearningObjectItem(
                        name: "Module Item Name",
                        isSelected: false,
                        requirement: .optional,
                        status: .completed,
                        type: .externalLink,
                        duration: "XX Mins",
                        dueDate: "22/12",
                        points: "22",
                        description: "Optional",
                        isOverdue: false
                    )

                    HorizonUI.LearningObjectItem(
                        name: "Module Item Name",
                        isSelected: true,
                        requirement: .required,
                        status: .locked,
                        type: .externalLink,
                        duration: "XX Mins",
                        dueDate: "22/12",
                        points: "22",
                        description: "Required",
                        isOverdue: true
                    )

                    HorizonUI.LearningObjectItem(
                        name: "Module Item Name",
                        isSelected: false,
                        requirement: .required,
                        type: .externalLink,
                        duration: "XX Mins",
                        dueDate: "22/12",
                        points: "22",
                        description: "View",
                        isOverdue: true
                    )

                }.padding()
            }
        }
    }
}

#Preview {
    HorizonUI.LearningObjectItem.Storybook()
}
