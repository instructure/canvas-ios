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
public extension HorizonUI.NavigationBar {
    struct Storybook: View {
        public var body: some View {
            VStack {}
                .navigationBarItems(
                    leading: HorizonUI.NavigationBar.Leading(
                        logoURL: "https://cdn.prod.website-files.com/5f7685be6c8c113f558855d9/62c87dbd6208a1e98e89e707_Logo_Canvas_Red_Vertical%20copy.png"
                    )
                )
                .navigationBarItems(
                    trailing: HorizonUI.NavigationBar.Trailing(
                        onNotebookDidTap: {},
                        onNotificationDidTap: {},
                        onMailDidTap: {}
                    )
                )
                .navigationTitle("NavigationBar")
        }
    }
}

#Preview {
    HorizonUI.NavigationBar.Storybook()
}
