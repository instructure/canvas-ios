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
import HorizonUI
import SwiftUI

struct HorizonMessageDetailsView: View {
    @State var model: HorizonMessageDetailsViewModel
    @Environment(\.viewController) private var viewController

    init(model: HorizonMessageDetailsViewModel) {
        self.model = model
    }

    var body: some View {
        guard let attachmentViewModel = model.attachmentViewModel else {
            return AnyView(content)
        }
        return AnyView(
            AttachmentView(viewModel: attachmentViewModel) {
                content
            }
        )
    }

    private var content: some View {
        VStack(alignment: .leading) {
            titleBar
                .padding(.horizontal, HorizonUI.spaces.space24)
            messages
            replyArea
        }
        .background(HorizonUI.colors.surface.pagePrimary)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationBarHidden(true)
    }

    private var messages: some View {
        ScrollViewReader { proxy in
            RefreshableScrollView(
                content: {
                    VStack(spacing: HorizonUI.spaces.space24) {
                        messageBodies
                    }
                    .padding([.leading, .trailing, .bottom], HorizonUI.spaces.space24)
                    .padding(.top, HorizonUI.spaces.space16)
                },
                refreshAction: model.refresh
            )
            .frame(maxHeight: .infinity, alignment: .top)
            .frame(maxWidth: .infinity)
            .background(HorizonUI.colors.surface.pageSecondary)
            .clipShape(
                .rect(
                    topLeadingRadius: 32,
                    bottomLeadingRadius: 0,
                    bottomTrailingRadius: 0,
                    topTrailingRadius: 32
                )
            )
            .onChange(of: model.messages.count) {
                if let last = model.messages.last {
                    withAnimation {
                        proxy.scrollTo(last.id, anchor: .bottom)
                    }
                }
            }
        }
    }

    private var messageBodies: some View {
        ForEach(model.messages) { message in
            messageBody(message)
                .id(message.id)
                .overlay(
                    Rectangle()
                        .frame(height: 1)
                        .foregroundStyle(
                            model.messages.firstIndex(where: { $0.id == message.id }) == 0 || model.messages.count <= 1 ?
                                .clear :
                                HorizonUI.colors.lineAndBorders.lineStroke
                        ),
                    alignment: .top
                )
        }
    }

    private func messageBody(_ message: HorizonMessageViewModel) -> some View {
        VStack(alignment: .leading, spacing: HorizonUI.spaces.space8) {
            HStack {
                Text(message.author)
                    .huiTypography(.labelLargeBold)
                Spacer()
                Text(message.date)
                    .huiTypography(.p3)
                    .foregroundStyle(HorizonUI.colors.text.timestamp)
            }
            Text(message.body)
                .huiTypography(.p1)
            if message.attachments.isNotEmpty {
                VStack(spacing: HorizonUI.spaces.space8) {
                    ForEach(message.attachments, id: \.self) { attachment in
                        AttachmentItemView(viewModel: attachment)
                    }
                }
                .padding(.top, HorizonUI.spaces.space8)
            }
        }
        .padding(.vertical, HorizonUI.spaces.space16)
    }

    @ViewBuilder
    private var replyArea: some View {
        if model.isReplayAreaVisible {
            VStack(spacing: HorizonUI.spaces.space16) {
                HorizonUI.TextArea(
                    $model.reply,
                    placeholder: String(localized: "Reply", bundle: .horizon),
                    autoExpand: true
                )
                replyAreaAttachments
                HStack {
                    replyAreaAttachFileButton
                    Spacer()
                    replyAreaSendButton
                }
            }
            .background(HorizonUI.colors.surface.pagePrimary)
            .padding(.horizontal, HorizonUI.spaces.space24)
            .padding(.top, HorizonUI.spaces.space8)
            .padding(.bottom, HorizonUI.spaces.space16)
        }
    }

    @ViewBuilder
    private var replyAreaAttachments: some View {
        if model.attachmentItems.isNotEmpty {
            VStack(spacing: .huiSpaces.space8) {
                ForEach(model.attachmentItems) { attachment in
                    AttachmentItemView(viewModel: attachment)
                }
            }
            .padding(.zero)
        }
    }

    private var replyAreaAttachFileButton: some View {
        HorizonUI.PrimaryButton(
            String(localized: "Attach file", bundle: .horizon),
            type: .white,
            leading: HorizonUI.icons.attachFile
        ) {
            model.attachFile(viewController: viewController)
        }
    }

    private var replyAreaSendButton: some View {
        HStack {
            Spacer()
            ZStack {
                HorizonUI.Spinner(size: .xSmall)
                    .opacity(model.loadingSpinnerOpacity)

                HorizonUI.PrimaryButton(
                    String(localized: "Send", bundle: .horizon),
                    type: .institution
                ) {
                    model.sendMessage(viewController: viewController)
                }
                .disabled(model.isSendDisabled)
                    .opacity(model.sendButtonOpacity)
            }
        }
    }

    private var titleBar: some View {
        HStack {
            backButton
            Spacer()
            if model.isAnnouncementIconVisible {
                HorizonUI.icons.announcement
                    .renderingMode(.template)
                    .foregroundStyle(HorizonUI.colors.surface.institution)
            }
            Text(model.headerTitle)
                .huiTypography(.labelLargeBold)
                .foregroundColor(HorizonUI.colors.surface.institution)
            Spacer()
            backButton
                .opacity(0)
        }
        .frame(maxWidth: .infinity)
    }

    private var backButton: some View {
        HorizonUI.IconButton(
            HorizonUI.icons.arrowBack,
            type: .ghost
        ) {
            model.pop(viewController: viewController)
        }
    }
}

#Preview {
    HorizonMessageDetailsView(
        model: HorizonMessageDetailsViewModel(
            announcementID: "ConversationID"
        )
    )
}
