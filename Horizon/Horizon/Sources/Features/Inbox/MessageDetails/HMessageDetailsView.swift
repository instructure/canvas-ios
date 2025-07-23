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

struct HMessageDetailsView: View {
    @State var model: HMessageDetailsViewModel
    @Environment(\.viewController) private var viewController
    @State private var attachmentsHeight: CGFloat?
    @FocusState private var isTextAreaFocused: Bool
    private let scrollOffsetNamespace = "ScrollOffsetNamespace"

    init(model: HMessageDetailsViewModel) {
        self.model = model
    }

    var body: some View {
        if let attachmentViewModel = model.attachmentViewModel {
            AttachmentView(viewModel: attachmentViewModel) {
                content
            }
        } else {
            content
        }
    }

    private var content: some View {
        VStack(alignment: .leading) {
            titleBar
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
                    ZStack(alignment: .top) {
                        HorizonUI.Spinner(size: .small)
                            .padding(.top, HorizonUI.spaces.space24)
                            .opacity(model.spinnerOpacity)
                            .animation(.easeInOut(duration: 0.3), value: model.loadingSpinnerOpacity)

                        VStack(spacing: HorizonUI.spaces.space24) {
                            messageBodies
                            ScrollOffsetReader(named: "ScrollOffsetNamespace")
                        }
                        .padding([.leading, .trailing, .bottom], HorizonUI.spaces.space24)
                        .padding(.top, HorizonUI.spaces.space16)
                        .opacity(model.messagesOpacity)
                        .animation(.easeInOut(duration: 0.3), value: model.messagesOpacity)
                    }
                    .frame(maxHeight: .infinity, alignment: .top)
                    .frame(maxWidth: .infinity)
                },
                refreshAction: model.refresh
            )
            .frame(maxHeight: .infinity, alignment: .top)
            .frame(maxWidth: .infinity)
            .background(HorizonUI.colors.surface.pageSecondary)
            .clipShape(
                .rect(
                    topLeadingRadius: HorizonUI.CornerRadius.level4.attributes.radius,
                    topTrailingRadius: HorizonUI.CornerRadius.level4.attributes.radius
                )
            )
            .onChange(of: model.messages.count) {
                if let last = model.messages.last {
                    if model.isAnimationEnabled {
                        withAnimation {
                            proxy.scrollTo(last.id, anchor: .bottom)
                        }
                    } else {
                        proxy.scrollTo(last.id, anchor: .bottom)
                    }
                }
            }
            .onPreferenceChange(ScrollOffsetReader.ScrollOffsetPreferenceKey.self) { _ in
                dismissKeyboard()
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

    private func messageBody(_ message: HMessageViewModel) -> some View {
        VStack(alignment: .leading, spacing: HorizonUI.spaces.space8) {
            HStack(spacing: .zero) {
                Text(message.author)
                    .huiTypography(.labelLargeBold)
                Spacer()
                Text(message.date)
                    .huiTypography(.p3)
                    .foregroundStyle(HorizonUI.colors.text.timestamp)
            }
            Text(message.body)
                .foregroundStyle(HorizonUI.colors.text.body)
                .huiTypography(.p1)
            if message.attachments.isNotEmpty {
                VStack(spacing: HorizonUI.spaces.space8) {
                    ForEach(message.attachments, id: \.self) { attachment in
                        HorizonUI.UploadedFile(
                            fileName: attachment.filename,
                            actionType: attachment.actionType
                        ) {
                            attachment.performAction(viewController)
                        }
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
                    focused: _isTextAreaFocused,
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
            .onChange(of: isTextAreaFocused) { _, _ in
                model.onTextAreaFocusChange(isTextAreaFocused)
            }
        }
    }

    @ViewBuilder
    private var replyAreaAttachments: some View {
        if model.attachmentItems.isNotEmpty {
            if model.isAttachmentsListScrollViewVisible {
                ScrollView(.vertical, showsIndicators: false) {
                    replyAreaAttachmentsList
                }
                .frame(maxHeight: attachmentsHeight, alignment: .top)
            } else {
                replyAreaAttachmentsList
            }
        }
    }

    private var replyAreaAttachmentsList: some View {
        VStack(spacing: .huiSpaces.space8) {
            ForEach(model.attachmentItems) { attachment in
                HorizonUI.UploadedFile(
                    fileName: attachment.filename,
                    actionType: attachment.actionType
                ) {
                    attachment.delete()
                }
            }
        }
        .readingFrame { frame in
            attachmentsHeight = min(frame.height, 300)
        }
        .padding(.zero)
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
                    dismissKeyboard()
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
                .lineLimit(2)
                .huiTypography(.labelLargeBold)
                .foregroundColor(HorizonUI.colors.surface.institution)
            Spacer()
            backButton
                .opacity(0)
        }
        .padding(.horizontal, HorizonUI.spaces.space24)
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

    private func dismissKeyboard() {
        ScrollOffsetReader.dismissKeyboard()
    }
}

#Preview {
    HMessageDetailsView(
        model: HMessageDetailsViewModel(
            announcementID: "ConversationID"
        )
    )
}
