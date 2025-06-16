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

    enum CommentLibraryButtonType {
        case openLibrary
        case closeLibrary
        case hidden
    }

    @Environment(\.viewController) var controller
    @Environment(\.dynamicTypeSize) var dynamicTypeSize

    @Binding var comment: String

    let commentLibraryButtonType: CommentLibraryButtonType
    let isAttachmentButtonEnabled: Bool
    let contextColor: Color

    let commentLibraryAction: () -> Void
    let addAttachmentAction: (AttachmentType) -> Void
    let sendAction: () -> Void

    @State private var showAttachmentTypeSheet = false

    var body: some View {
        VStack(spacing: 0) {
            InstUI.Divider()
            content
                .paddingStyle(.horizontal, .standard)
                .padding(.vertical, 8)
                .background(.backgroundLightest)
        }
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 12) {
            commentEditor

            HStack(alignment: .bottom, spacing: InstUI.Styles.Padding.standard.rawValue) {
                switch commentLibraryButtonType {
                case .openLibrary:
                    commentLibraryButton(isCurrentlyClosed: true)
                case .closeLibrary:
                    commentLibraryButton(isCurrentlyClosed: false)
                case .hidden:
                    SwiftUI.EmptyView()
                }

                attachmentButton

                sendButton
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
        // TODO: Area outside of buttons could focus the TextField
        .padding(.leading, 16)
        .padding(.trailing, 8)
        .padding(.vertical, 8)
        .background(RoundedRectangle(cornerRadius: 24).fill(Color.backgroundLightest))
        .background(RoundedRectangle(cornerRadius: 24).stroke(Color.borderMedium))
        .accessibilityElement(children: .contain)
    }

    // MARK: - TextField

    @ViewBuilder
    private var commentEditor: some View {
        VStack(alignment: .leading, spacing: 2) {
            if comment.isNotEmpty {
                Text("Comment", bundle: .teacher)
                    .font(.regular12)
                    .foregroundStyle(.textPlaceholder)
            }
            DynamicHeightTextEditor(
                text: $comment,
                placeholder: String(localized: "Comment", bundle: .teacher),
                font: .regular14
            )
            .lineLimit(6)
            .accessibilityLabel(Text("Comment", bundle: .teacher))
            .identifier("SubmissionComments.commentTextView")
        }
    }

    // MARK: - Buttons

    @ViewBuilder
    private func commentLibraryButton(isCurrentlyClosed: Bool) -> some View {
        let icon = isCurrentlyClosed ? Image.chatLine : Image.chevronDown
        let label = isCurrentlyClosed ? Text("Open comment library", bundle: .teacher) : Text("Close comment library", bundle: .teacher)
        Button(
            action: commentLibraryAction,
            label: {
                icon
                    .scaledIcon()
                    .foregroundStyle(.textDark)
            }
        )
        .accessibilityLabel(label)
        .identifier("SubmissionComments.showCommentLibraryButton")
    }

    private var attachmentButton: some View {
        Button(
            action: { showAttachmentTypeSheet = true },
            label: {
                Image.paperclipLine
                    .scaledIcon()
                    .foregroundStyle(isAttachmentButtonEnabled ? .textDark : .disabledGray)
            }
        )
        .disabled(!isAttachmentButtonEnabled)
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
                    .foregroundStyle(comment.isNotEmpty ? contextColor : .disabledGray)
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
    @Previewable @State var text: String = "Sample text"
    @Previewable @State var textShort: String = .loremIpsumShort
    @Previewable @State var textLong: String = .loremIpsumLong
    @Previewable @State var textEmpty: String = ""

    VStack {
        CommentInputView(
            comment: $textShort,
            commentLibraryButtonType: .openLibrary,
            isAttachmentButtonEnabled: true,
            contextColor: .green,
            commentLibraryAction: {},
            addAttachmentAction: { _ in },
            sendAction: {}
        )
        .background(Color.backgroundLightest)

        CommentInputView(
            comment: $textLong,
            commentLibraryButtonType: .closeLibrary,
            isAttachmentButtonEnabled: false,
            contextColor: .green,
            commentLibraryAction: {},
            addAttachmentAction: { _ in },
            sendAction: {}
        )
        .background(Color.backgroundLightest)

        CommentInputView(
            comment: $textLong,
            commentLibraryButtonType: .hidden,
            isAttachmentButtonEnabled: true,
            contextColor: .green,
            commentLibraryAction: {},
            addAttachmentAction: { _ in },
            sendAction: {}
        )
        .background(Color.backgroundLightest)

        CommentInputView(
            comment: $textEmpty,
            commentLibraryButtonType: .openLibrary,
            isAttachmentButtonEnabled: true,
            contextColor: .green,
            commentLibraryAction: {},
            addAttachmentAction: { _ in },
            sendAction: {}
        )
        .background(Color.backgroundLightest)
    }
    .padding(.vertical)
    .background(Color.yellow)
}

#endif
