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

struct SideMenuItem: View {
    @Environment(\.colorScheme) var colorScheme
    let id: String
    let image: Image
    let title: Text

    @State var badgeValue: UInt = 0

    var body: some View {
        HStack(spacing: 20) {
            image
            title
                .font(.regular16)
                .foregroundColor(colorScheme == .dark ? .white : .licorice)
            Spacer()

            if badgeValue > 0 {
                Badge(value: badgeValue)
            }
        }
        .padding(20)
        .frame(height: 48)
        .contentShape(Rectangle())
        .accessibilityElement(children: .ignore)
        .accessibility(label: title)
        .identifier("Profile.\(id)Button")
    }
}

private struct Badge: View {
    @State var value: UInt

    var body: some View {
        ZStack {
            Capsule().fill(Color.crimson).frame(maxWidth: CGFloat(digitCount()) * 12, maxHeight: 18)
            Text("\(value)").font(.regular12).foregroundColor(.white)
        }
    }

    func digitCount() -> Double {
        let count = Double("\(value)".count)
        return count == 1 ? 1.5 : count
    }
}

#if DEBUG

struct SideMenuItem_Previews: PreviewProvider {
    static var previews: some View {
        SideMenuItem(id: "inbox", image: .emailLine, title: Text("Inbox", bundle: .core), badgeValue: 42).buttonStyle(ContextButton(contextColor: Brand.shared.primary))
    }
}

#endif
