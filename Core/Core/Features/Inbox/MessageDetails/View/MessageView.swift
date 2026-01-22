//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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

@available(iOS, introduced: 26, message: "Legacy version exists")
public struct MessageView: View {
    @Environment(\.viewController) private var controller
    @ScaledMetric private var uiScale: CGFloat = 1

    private var model: MessageViewModel
    private let isReplyButtonVisible: Bool
    private let isStudentAccessRestricted: Bool
    private let replyDidTap: () -> Void
    private let replyAllDidTap: () -> Void
    private let forwardDidTap: () -> Void
    public var deleteDidTap: () -> Void

    public init(
        model: MessageViewModel,
        isReplyButtonVisible: Bool,
        isStudentAccessRestricted: Bool,
        replyDidTap: @escaping () -> Void,
        replyAllDidTap: @escaping () -> Void,
        forwardDidTap: @escaping () -> Void,
        deleteDidTap: @escaping () -> Void
    ) {
        self.model = model
        self.replyDidTap = replyDidTap
        self.isStudentAccessRestricted = isStudentAccessRestricted
        self.replyAllDidTap = replyAllDidTap
        self.isReplyButtonVisible = isReplyButtonVisible
        self.forwardDidTap = forwardDidTap
        self.deleteDidTap = deleteDidTap
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            headerView
            bodyView
            if isReplyButtonVisible {
                replyButton
            }
        }
    }

    private var replyButton: some View {
        Button {
            replyDidTap()
        } label: {
            Text("Reply", bundle: .core)
                .font(.regular16)
                .foregroundColor(Color(Brand.shared.linkColor))
                .accessibilityIdentifier("MessageDetails.replyButton")
        }
    }

    private var headerView: some View {
        HStack(alignment: .top, spacing: 4) {
            Avatar(name: model.avatarName, url: model.avatarURL, size: 36, isAccessible: false)
            VStack(alignment: .leading) {
                Text(model.author)
                    .font(.regular16)
                    .foregroundColor(.textDarkest)
                    .lineLimit(1)
                    .accessibilityIdentifier("MessageDetails.author")

                Text(model.date)
                    .foregroundColor(.textDark)
                    .font(.regular12)
                    .accessibilityIdentifier("MessageDetails.date")
            }
            Spacer()

            if isReplyButtonVisible {
                replyIconButton
            }

            Menu {
                if isReplyButtonVisible {
                    Button(.init("Reply", bundle: .core), image: .replyLine, action: replyDidTap)
                        .accessibilityIdentifier("MessageDetails.reply")

                    if !isStudentAccessRestricted {
                        Button(
                            .init("Reply All", bundle: .core),
                            image: .replyAllLine,
                            action: replyAllDidTap
                        )
                        .accessibilityIdentifier("MessageDetails.replyAll")
                    }
                }

                Button(.init("Forward", bundle: .core), image: .forwardLine, action: forwardDidTap)
                    .accessibilityIdentifier("MessageDetails.forward")

                if !isStudentAccessRestricted {
                    Button(
                        .init("Delete Message", bundle: .core),
                        image: .trashLine,
                        action: deleteDidTap
                    )
                    .accessibilityIdentifier("MessageDetails.delete")
                }
            } label: {
                Image
                    .moreLine
                    .size(uiScale.iconScale * 20)
                    .foregroundColor(.textDark)
                    .padding(.horizontal, 6)
                    .accessibilityLabel(Text("Conversation options", bundle: .core))
                    .accessibilityIdentifier("MessageDetails.options")
            }
        }
    }

    private var replyIconButton: some View {
        Button {
            replyDidTap()
        } label: {
            Image
                .replyLine
                .size(uiScale.iconScale * 20)
                .foregroundColor(.textDark)
                .padding(.leading, 6)
                .accessibilityLabel(Text("Reply", bundle: .core))
                .accessibilityIdentifier("MessageDetails.replyImage")
        }
    }

    private var bodyView: some View {
        VStack(alignment: .leading, spacing: 16) {
            SelectableText(
                attributedText: model.body.toAttributedStringWithLinks(),
                font: .regular16,
                lineHeight: .fit,
                textColor: .textDarkest
            )
            .accessibilityIdentifier("MessageDetails.body")

            if model.showAttachments {
                AttachmentsView(
                    attachments: model.attachments,
                    mediaComment: model.mediaComment,
                    didSelectAttachment: model.handleFileNavigation
                )
            }
        }
        .onAppear {
            model.controller = controller
        }
        .environment(\.openURL, OpenURLAction(handler: model.handleURL))
    }
}

#if DEBUG

#Preview {
    let env = PreviewEnvironment()
    let context = env.globalDatabase.viewContext

    MessageDetailsAssembly.makePreview(
        env: env,
        subject: "Message Title",
        messages: .make(count: 5, body: InstUI.PreviewData.loremIpsumLong, in: context)
    )
}

#endif
