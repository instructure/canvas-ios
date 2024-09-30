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
    @Binding var badgeValue: UInt

    let id: String
    let image: Image
    let title: Text
    var accessibilityHint: Text {
        guard badgeValue > 0 else { return Text(verbatim: "") }
        return Text(String.localizedStringWithFormat(
            String(localized: "conversation_unread_messages", bundle: .core),
            badgeValue))
    }

    init(id: String, image: Image, title: Text, badgeValue: Binding<UInt>) {
        self.id = id
        self.image = image
        self.title = title
        _badgeValue = badgeValue
    }

    init(id: String, image: Image, title: Text) {
        self.id = id
        self.image = image
        self.title = title
        _badgeValue = .constant(0)
    }

    var body: some View {
        HStack(spacing: 20) {
            image
            title
                .font(.regular16)
                .foregroundColor(.textDarkest)
            Spacer()

            if badgeValue > 0 {
                Badge(value: $badgeValue)
                    .accessibilityHidden(true)
            }
        }
        .padding(20)
        .frame(height: 48)
        .contentShape(Rectangle())
        .accessibilityElement(children: .ignore)
        .accessibility(label: title)
        .accessibilityHint(accessibilityHint)
        .identifier("Profile.\(id)Button")
    }
}

private struct Badge: View {
    @Binding var value: UInt

    var body: some View {
        clampedValueText()
            .font(.semibold12)
            .padding(EdgeInsets(top: 2.5, leading: 6.5, bottom: 3, trailing: 6.5))
            .foregroundColor(.textLightest)
            .background(Color.backgroundDanger)
            .clipShape(Capsule())
    }

    func clampedValueText() -> Text {
        guard value < 100 else { return Text(verbatim: "99+") }
        return Text("\(value)")
    }
}

#if DEBUG

struct SideMenuItem_Previews: PreviewProvider {
    static var previews: some View {
        SideMenuItem(id: "inbox", image: .emailLine, title: Text("Inbox", bundle: .core), badgeValue: .constant(123)).buttonStyle(ContextButton(contextColor: Brand.shared.primary))
    }
}

#endif
