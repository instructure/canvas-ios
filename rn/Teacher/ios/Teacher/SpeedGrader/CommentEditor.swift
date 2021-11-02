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
    @Environment(\.viewController) var controller

    @Binding var text: String
    let action: () -> Void
    let containerHeight: CGFloat

    var body: some View {
        HStack(alignment: .bottom) {
            if #available(iOS 14, *) {
                DynamicHeightTextEditor(text: $text, maxLines: 3, font: .scaledNamedFont(.regular16), placeholder: NSLocalizedString("Comment", bundle: .core, comment: ""))
                    .accessibility(label: Text("Comment"))
                    .identifier("SubmissionComments.commentTextView")
            } else {
                ZStack(alignment: .leading) {
                    if text.isEmpty {
                        Text("Comment")
                            .font(.regular16).foregroundColor(.textDark)
                            .accessibility(hidden: true)
                    }
                    Core.TextEditor(text: $text, maxHeight: containerHeight / 2)
                        .font(.regular16).foregroundColor(.textDarkest)
                        .accessibility(label: Text("Comment"))
                        .identifier("SubmissionComments.commentTextView")
                        .padding(.vertical, 2)
                }
            }
            Button(action: {
                action()
                controller.view.endEditing(true)
            }, label: {
                Image.miniArrowUpSolid.foregroundColor(Color(Brand.shared.buttonPrimaryText))
                    .background(Circle().fill(Color(Brand.shared.buttonPrimaryBackground)))
            })
                .opacity(text.isEmpty ? 0.5 : 1)
                .disabled(text.isEmpty)
                .accessibility(label: Text("Send"))
                .identifier("SubmissionComments.addCommentButton")
        }
            .padding(EdgeInsets(top: 4, leading: 12, bottom: 4, trailing: 4))
            .background(RoundedRectangle(cornerRadius: 16).fill(Color.backgroundLightest))
            .background(RoundedRectangle(cornerRadius: 16).stroke(Color.borderMedium))
    }
}
