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

import Core
import HorizonUI
import SwiftUI

struct AssistChatMessageView: View {
    let message: AssistChatMessageViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: .zero) {
            messageContent
                .frame(maxWidth: .infinity, alignment: message.alignment)
                .onTapGesture {
                    message.onTap?()
                }
            WrappingHStack(
                models: message.chipOptions,
                horizontalSpacing: .zero
            ) { quickResponse in
                HorizonUI.Pill(title: quickResponse.chip, style: .outline(.light))
                    .onTapGesture {
                        message.onTapChipOption?(quickResponse)
                    }
                    .padding(.vertical, .huiSpaces.space4)
                    .padding(.trailing, .huiSpaces.space4)
            }
            .padding(.vertical, .huiSpaces.space8)
            .frame(maxWidth: .infinity, alignment: .leading)
            feedback
        }
    }

    @ViewBuilder
    private var feedback: some View {
        if let onFeedbackChange = message.onFeedbackChange {
            AssistFeedbackView(onChange: onFeedbackChange)
        }
    }

    private var messageContent: some View {
        VStack(alignment: .center) {
            if message.isLoading {
                HStack(alignment: .center) {
                    HorizonUI.Spinner(size: .xSmall, foregroundColor: .huiColors.surface.cardPrimary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, .huiSpaces.space8)
            } else {
                Text(message.content.toAttributedStringWithLinks())
                    .frame(maxWidth: message.maxWidth, alignment: .leading)
                    .padding(message.padding)
                    .background(message.backgroundColor)
                    .foregroundColor(message.foregroundColor)
                    .cornerRadius(message.cornerRadius)
            }
        }
    }
}

#if DEBUG
#Preview {
    VStack {
        AssistChatMessageView(message: .init(content: "Hi Horizon App", style: .semitransparent))
        AssistChatMessageView(
            message: .init(
                content: "Hi Horizon App",
                style: .white,
                onFeedbackChange: { _ in

                }
            )
        )
        AssistChatMessageView(message: .init())
        AssistChatMessageView(message: .init(
            content: "You are a duck",
            style: .transparent,
            chipOptions: [
                AssistChipOption(chip: "Quick Response 1"),
                AssistChipOption(chip: "Quick Response 2"),
                AssistChipOption(chip: "Quick Response 3"),
                AssistChipOption(chip: "Quick Response 4")
            ]
        ))
    }
    .frame(maxHeight: .infinity)
    .applyHorizonGradient()
}
#endif
