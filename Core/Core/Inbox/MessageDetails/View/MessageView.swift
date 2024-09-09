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

public struct MessageView: View {
    @Environment(\.viewController) private var controller
    @ScaledMetric private var uiScale: CGFloat = 1

    private var model: MessageViewModel
    private let hideReplyButton: Bool
    private var replyDidTap: () -> Void
    private var moreDidTap: () -> Void

    public init(
        model: MessageViewModel,
        hideReplyButton: Bool,
        replyDidTap: @escaping () -> Void,
        moreDidTap: @escaping () -> Void
    ) {
        self.model = model
        self.replyDidTap = replyDidTap
        self.moreDidTap = moreDidTap
        self.hideReplyButton = hideReplyButton
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            headerView
            bodyView
            if !hideReplyButton {
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
            if !hideReplyButton {
                replyIconButton
            }
            Button {
                moreDidTap()
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
            Text(model.body.toAttributedStringWithLinks())
                .font(.regular16)
                .textSelection(.enabled)
                .accessibilityIdentifier("MessageDetails.body")
            if model.showAttachments {
                AttachmentsView(attachments: model.attachments, didSelectAttachment: model.handleFileNavigation)
            }
        }
        .onAppear {
            model.controller = controller
        }
        .environment(\.openURL, OpenURLAction(handler: model.handleURL))
    }
}
