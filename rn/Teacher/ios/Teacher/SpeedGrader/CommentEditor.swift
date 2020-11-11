//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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
import Core

struct CommentEditor: View {
    @Binding var text: String
    let action: () -> Void

    var body: some View {
        HStack(alignment: .bottom) {
            ZStack(alignment: .leading) {
                if text.isEmpty {
                    Text("Comment")
                        .font(.regular16).foregroundColor(.textDark)
                        .accessibility(hidden: true)
                }
                TextEditor(text: $text)
                    .font(.regular16).foregroundColor(.textDarkest)
                    .accessibility(label: Text("Comment"))
                    .padding(.vertical, 2)
            }
            Button(action: action, label: {
                Icon.miniArrowUpSolid.foregroundColor(Color(Brand.shared.buttonPrimaryText))
                    .background(Circle().fill(Color(Brand.shared.buttonPrimaryBackground)))
            })
                .accessibility(label: Text("Send"))
                .opacity(text.isEmpty ? 0.5 : 1)
                .disabled(text.isEmpty)
        }
            .padding(EdgeInsets(top: 4, leading: 12, bottom: 4, trailing: 4))
            .background(RoundedRectangle(cornerRadius: 16).fill(Color.backgroundLightest))
            .background(RoundedRectangle(cornerRadius: 16).stroke(Color.borderMedium))
    }
}
