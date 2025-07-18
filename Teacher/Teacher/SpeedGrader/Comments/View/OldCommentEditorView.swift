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

struct OldCommentEditorView: View {
    @Environment(\.viewController) var controller

    @Binding var text: String
    let shouldShowCommentLibrary: Bool
    @Binding var showCommentLibrary: Bool
    let action: () -> Void
    let containerHeight: CGFloat
    let contextColor: Color

    var body: some View {
        HStack(alignment: .bottom) {
            InstUI.ScrollableTextEditor(
                text: $text,
                placeholder: String(localized: "Comment", bundle: .teacher),
                font: .regular16,
                lineLimit: 10
            )
                .accessibility(label: Text("Comment", bundle: .teacher))
                .identifier("SubmissionComments.commentTextView")
                .highPriorityGesture( // High priority to take precedence over comment field activation.
                    TapGesture().onEnded { _ in showCommentLibrary = true },
                    isEnabled: shouldShowCommentLibrary
                )
                .accessibilityActions {
                    if shouldShowCommentLibrary {
                        Button {
                            showCommentLibrary = true
                        } label: {
                            Text("Open comment library", bundle: .teacher)
                        }
                    }
                }
            Button(
                action: {
                    action()
                    controller.view.endEditing(true)
                },
                label: {
                    Image.circleArrowUpSolid
                        .scaledIcon()
                        .foregroundStyle(contextColor)
                }
            )
            .scaledOffset(y: -5, useIconScale: true)
            .buttonStyle(.plain)
            .disabled(text.isEmpty)
            .accessibility(label: Text("Send", bundle: .teacher))
            .identifier("SubmissionComments.addCommentButton")
        }
            .padding(EdgeInsets(top: 4, leading: 12, bottom: 4, trailing: 6))
            .background(RoundedRectangle(cornerRadius: 22).fill(Color.backgroundLightest))
            .background(RoundedRectangle(cornerRadius: 22).stroke(Color.borderMedium))
    }
}

#if DEBUG

struct CommentEditor_Previews: PreviewProvider {
    static var previews: some View {
        @State var showCommentLibrary = false
        OldCommentEditorView(
            text: .constant("Sample Text"),
            shouldShowCommentLibrary: true,
            showCommentLibrary: $showCommentLibrary,
            action: {},
            containerHeight: 30,
            contextColor: .green
        )
        .frame(width: 200)
        .previewLayout(.sizeThatFits)
    }
}

#endif
