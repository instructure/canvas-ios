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

extension HorizonUI.Badge {
    struct Storybook: View {
        var body: some View {
            VStack {
                HStack {
                    HorizonUI.Badge(type: .icon(.huiIcons.check), style: .primary)
                    Spacer()
                    HorizonUI.Badge(type: .empty, style: .primary)
                    Spacer()
                    HorizonUI.Badge(type: .number("5"), style: .primary)
                }

                HStack {
                    HorizonUI.Badge(type: .icon(.huiIcons.check), style: .custom(backgroundColor: .black, foregroundColor: .white))
                    Spacer()
                    HorizonUI.Badge(type: .empty, style: .custom(backgroundColor: .purple))
                    Spacer()
                    HorizonUI.Badge(type: .number("15"), style: .custom(backgroundColor: .orange, foregroundColor: .green))
                }

                HStack {
                    HorizonUI.Badge(type: .icon(.huiIcons.close), style: .success)
                    Spacer()
                    HorizonUI.Badge(type: .empty, style: .success)
                    Spacer()
                    HorizonUI.Badge(type: .number("20"), style: .success)
                }

                HStack {
                    HorizonUI.Badge(type: .icon(.huiIcons.closeSmall), style: .danger)
                    Spacer()
                    HorizonUI.Badge(type: .empty, style: .danger)
                    Spacer()
                    HorizonUI.Badge(type: .number("30"), style: .danger)
                }
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(16)
            .background(Color.black.opacity(0.1))
            .navigationTitle("Badge")
        }
    }
}

#Preview {
    HorizonUI.Badge.Storybook()
}
