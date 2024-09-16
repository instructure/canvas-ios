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

import Core
import SwiftUI

struct BaseHorizonScreen<Content: View>: View {
    let content: () -> Content

    var body: some View {
        content()
            .navigationBarItems(leading: profileMenuButton)
            .toolbarBackground(Color.textDarkest, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
    }

    private var profileMenuButton: some View {
        Button {
            print("route to profile")
        } label: {
            Image.hamburgerSolid
                .foregroundColor(Color.textLightest)
        }
        .frame(width: 44, height: 44).padding(.leading, -6)
    }
}
