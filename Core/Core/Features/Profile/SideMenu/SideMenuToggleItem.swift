//
// This file is part of Canvas.
// Copyright (C) 2021-present  Instructure, Inc.
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

struct SideMenuToggleItem: View {
    @Environment(\.colorScheme) var colorScheme
    let id: String
    let image: Image
    let title: Text

    @Binding var isOn: Bool

    var body: some View {
        InstUI.Toggle(isOn: $isOn, label: {
            HStack(spacing: 20) {
                image
                title
            }
        })
        .font(.regular16)
        .foregroundColor(.textDarkest)
        .padding(20)
        .frame(height: 48)
        .contentShape(Rectangle())
        .accessibility(label: title)
        .identifier("Profile.\(id)Toggle")
    }
}

#if DEBUG

struct SideMenuToggleItem_Previews: PreviewProvider {

    static var previews: some View {
        SideMenuToggleItem(id: "showGrades", image: .gradebookLine, title: Text("Show Grades", bundle: .core), isOn: .constant(true))
    }
}

#endif
