//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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

struct CommentInputView: View {

    enum AttachmentType {
        case audio
        case video
        case file
    }

    @Environment(\.viewController) var controller
    @Environment(\.dynamicTypeSize) var dynamicTypeSize

    @Binding var comment: String

    let hasCommentLibraryButton: Bool
    let hasAttachmentButton: Bool
    let contextColor: Color

    let showCommentLibraryAction: () -> Void
    let addAttachmentAction: (AttachmentType) -> Void
    let sendAction: () -> Void

    @State private var showAttachmentTypeSheet = false

    var body: some View {
        HStack(alignment: .bottom, spacing: InstUI.Styles.Padding.standard.rawValue) {
            if hasCommentLibraryButton {
                commentLibraryButton
                    .commentToolbarButtonOffset()
            }
            if hasAttachmentButton {
                attachmentButton
                    .commentToolbarButtonOffset()
            }
            commentEditor
//                .accessibilityFocused($focusedTab, equals: .comments)
            sendButton
                .commentToolbarButtonOffset()
        }
        .paddingStyle(.horizontal, .standard)
        .padding(.vertical, 4)
    }

    // MARK: - TextField

    private var commentEditor: some View {
        DynamicHeightTextEditor(text: $comment, placeholder: String(localized: "Write your Comment here", bundle: .teacher))
            .font(.regular16)
            .lineLimit(10)
            .accessibilityLabel(Text("Comment", bundle: .teacher))
            .identifier("SubmissionComments.commentTextView")
    }

    // MARK: - Buttons

    private var commentLibraryButton: some View {
        Button(
            action: showCommentLibraryAction,
            label: {
                Image.chatLine
                    .scaledIcon()
                    .foregroundColor(.textDark)
            }
        )
        .accessibilityLabel(Text("Open comment library", bundle: .teacher))
        .identifier("SubmissionComments.showCommentLibraryButton")
    }

    private var attachmentButton: some View {
        Button(
            action: { showAttachmentTypeSheet = true },
            label: {
                Image.paperclipLine
                    .scaledIcon()
                    .foregroundColor(.textDark)
            }
        )
        .accessibility(label: Text("Add Attachment", bundle: .teacher))
        .identifier("SubmissionComments.addMediaButton")
        .actionSheet(isPresented: $showAttachmentTypeSheet) {
            ActionSheet(title: Text("Add Attachment", bundle: .teacher), buttons: [
                .default(Text("Record Audio", bundle: .teacher), action: { addAttachmentAction(.audio) }),
                .default(Text("Record Video", bundle: .teacher), action: { addAttachmentAction(.video) }),
                .default(Text("Choose Files", bundle: .teacher), action: { addAttachmentAction(.file) }),
                .cancel()
            ])
        }
    }

    private var sendButton: some View {
        Button(
            action: {
                sendAction()
                controller.view.endEditing(true)
            },
            label: {
                Image.circleArrowUpSolid
                    .scaledIcon()
                    .foregroundStyle(contextColor)
            }
        )
        .buttonStyle(.plain)
        .disabled(comment.isEmpty)
        .accessibilityLabel(Text("Send", bundle: .teacher))
        .identifier("SubmissionComments.addCommentButton")
    }
}

private extension View {
    // Toolbar buttons should be center aligned with the last row of the comment textfield.
    // This offset is an approximation for that.
    func commentToolbarButtonOffset() -> some View {
        scaledOffset(y: -5, useIconScale: true)
    }
}

#if DEBUG

#Preview {
    CommentInputView(
        comment: .constant("Sample Text"),
        hasCommentLibraryButton: true,
        hasAttachmentButton: true,
        contextColor: .green,
        showCommentLibraryAction: {},
        addAttachmentAction: { _ in },
        sendAction: {}
    )
}

#endif
