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

struct CustomTextField: View {
    let placeholder: Text
    @Binding var text: String
    let identifier: String
    let accessibilityLabel: Text
    let padding: CGFloat = 16
    let onEditingChanged: (Bool) -> Void = { _ in }
    let onCommit: () -> Void = { }

    var body: some View {
        ZStack(alignment: .leading) {
            if text.isEmpty {
                placeholder
                    .font(.regular16).foregroundColor(.textDark)
                    .padding(.leading, padding)
                    .allowsHitTesting(false)
                    .accessibility(hidden: true)
            }
            let accessibilityText = text.isEmpty ? placeholder : accessibilityLabel
            TextField("", text: $text, onEditingChanged: onEditingChanged, onCommit: onCommit)
                .font(.regular16).foregroundColor(.textDarkest)
                .padding(padding)
                .identifier(identifier)
                .accessibility(label: accessibilityText)
        }
    }
}

#if DEBUG

struct CustomTextField_Previews: PreviewProvider {

    static var previews: some View {
        CustomTextField(placeholder: Text(verbatim: "Placeholder"), text: .constant(""), identifier: "This.TextField", accessibilityLabel: Text(verbatim: "TextField"))
    }
}

#endif
