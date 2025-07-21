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
        VStack(alignment: .leading, spacing: .huiSpaces.space8) {
            messageContent
                .frame(maxWidth: .infinity, alignment: message.alignment)
                .onTapGesture {
                    message.onTap?()
                }
            citations
            feedback
            suggestedResponses
        }
    }

    @ViewBuilder
    private var citations: some View {
        if message.citations.isNotEmpty {
            WrappingHStack(
                models: message.citations,
                horizontalSpacing: .zero
            ) {
                Text($0)
                    .huiTypography(.labelSmall)
                    .baselineOffset(2)
                    .foregroundColor(.huiColors.text.surfaceColored)
                    .underline()
                    .padding(.horizontal, .huiSpaces.space4)
                    .overlay(
                        Rectangle()
                            .fill(HorizonUI.colors.text.surfaceColored)
                            .frame(width: $0 == message.citations.last ? 0 : 1),
                        alignment: .trailing
                    )
                    .onTapGesture {
                    }
            }
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
                    HorizonUI.Spinner(
                        size: .xSmall,
                        foregroundColor: .huiColors.surface.cardPrimary
                    )
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

    @ViewBuilder
    private var suggestedResponses: some View {
        if message.chipOptions.isNotEmpty {
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
            .padding(.top, .huiSpaces.space16)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#if DEBUG
#Preview {
    VStack {
        AssistChatMessageView(message: .init(content: "Hi Horizon App", style: .semitransparent))
        AssistChatMessageView(message: .init())
        AssistChatMessageView(message: .init(
            content: "AI response Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.",
            style: .transparent,
            chipOptions: [
                AssistChipOption(chip: "Quick Response 1"),
                AssistChipOption(chip: "Quick Response 2"),
                AssistChipOption(chip: "Quick Response 3"),
                AssistChipOption(chip: "Quick Response 4")
            ],
            onFeedbackChange: { _ in },
            citations: ["Citation 1", "Citation 2", "Citation 3"]
        ))
    }
    .frame(maxHeight: .infinity)
    .applyHorizonGradient()
}
#endif
