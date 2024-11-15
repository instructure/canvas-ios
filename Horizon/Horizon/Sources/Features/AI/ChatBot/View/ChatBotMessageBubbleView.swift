//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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

struct ChatBotMessageBubbleView: View {
    let message: ChatBotMessageModel
    let maxWidth: CGFloat

    var body: some View {
        HStack {
            if message.isMine {
                Spacer()
            }

            if message.isLoading {
                TypingAnimationView()
            } else {
                messageContent
            }

            if !message.isMine {
                Spacer()
            }
        }
    }

    private var messageContent: some View {
        Text(message.content.toAttributedStringWithLinks())
            .padding()
            .background(message.isMine ? Color.backgroundLightest : Color.backgroundLightest.opacity(0.2))
            .foregroundColor(message.isMine ? Color.textDarkest : Color.backgroundLightest)
            .cornerRadius(16)
            .frame(maxWidth: maxWidth, alignment: message.isMine ? .trailing : .leading)
    }
}

#if DEBUG
#Preview {
    VStack {
        ChatBotMessageBubbleView(message: .init(content: "Hi Horizon App", isMine: true), maxWidth: 250)
        ChatBotMessageBubbleView(message: .init(content: "Hi Horizon App", isMine: false), maxWidth: 250)
        ChatBotMessageBubbleView(message: .init(isMine: false, isLoading: true), maxWidth: 250)
    }
    .frame(maxHeight: .infinity)
    .applyHorizonGradient()
}
#endif
