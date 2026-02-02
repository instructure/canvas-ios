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
    // MARK: - Propertites a11y

    @AccessibilityFocusState private var focusedAttachedFile: Bool?

    @State var viewModel: HMessageDetailsViewModel
    @Environment(\.viewController) private var viewController
    @State private var attachmentsHeight: CGFloat?
    @FocusState private var isTextAreaFocused: Bool

    init(viewModel: HMessageDetailsViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        AttachmentView(viewModel: viewModel.attachmentViewModel) {
            content
        }
        .onChange(of: viewModel.attachmentViewModel.isPickerVisible) { _, newValue in
            if newValue == false {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    focusedAttachedFile = true
                }
            }
        }
    }

    private var content: some View {
        VStack(alignment: .leading) {
            messages
            replyArea
        }
        .background(HorizonUI.colors.surface.pagePrimary)
        .safeAreaInset(edge: .top) { titleBar }
        .navigationBarHidden(true)
    }

    private var messages: some View {
        ScrollViewReader { proxy in
            ScrollView {
                messagesView
                    .padding([.leading, .trailing, .bottom], HorizonUI.spaces.space24)
                    .padding(.top, HorizonUI.spaces.space16)
            }
            .refreshable(action: viewModel.refresh)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(HorizonUI.colors.surface.pageSecondary)
            .roundedTopCorners()
            .onChange(of: viewModel.messages.count) {
                withAnimation {
                    proxy.scrollTo(viewModel.messages.last?.id, anchor: .bottom)
                }
            }
            .onPreferenceChange(ScrollOffsetReader.ScrollOffsetPreferenceKey.self) { _ in
                ScrollOffsetReader.dismissKeyboard()
            }
        }
    }

    private var messagesView: some View {
        ForEach(viewModel.messages) { message in
            InboxMessageRowView(message: message, viewModel: viewModel)
                .id(message.id)
        }
    }

    @ViewBuilder
    private var replyArea: some View {
        VStack(spacing: HorizonUI.spaces.space16) {
            HorizonUI.TextArea(
                $viewModel.reply,
                placeholder: String(localized: "Reply", bundle: .horizon),
                focused: _isTextAreaFocused,
                autoExpand: true
            )
            .focused($isTextAreaFocused)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(
                String(
                    format: String(localized: "Your reply is %@"),
                    viewModel.reply.isEmpty ? String(localized: "Empty.") : viewModel.reply
                )
            )
            .accessibilityHint(String(localized: "Double tap to start typing."))
            .accessibilityAction {
                isTextAreaFocused = true
            }
            .accessibilityRemoveTraits(.isButton)
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
            if !isTextAreaFocused {
                viewModel.reply = viewModel.reply.trimmed()
            }
        }
    }

    @ViewBuilder
    private var replyAreaAttachments: some View {
        if viewModel.attachmentItems.isNotEmpty {
            ScrollView(.vertical, showsIndicators: false) {
                replyAreaAttachmentsList
            }
            .frame(maxHeight: attachmentsHeight, alignment: .top)
            .scrollBounceBehavior(.basedOnSize)
        }
    }

    private var replyAreaAttachmentsList: some View {
        VStack(spacing: .huiSpaces.space8) {
            ForEach(viewModel.attachmentItems) { attachment in
                HorizonUI.UploadedFile(
                    fileName: attachment.filename,
                    actionType: attachment.uploadState
                ) {
                    viewModel.attachmentViewModel.removeFile(attachment: attachment)
                }
                .accessibilityElement(children: .ignore)
                .accessibilityAddTraits(.isButton)
                .accessibilityLabel(String(format: "File name is %@. ", attachment.filename))
                .accessibilityHint(String(localized: "Double tap to delete"))
                .accessibilityAction {
                    viewModel.attachmentViewModel.removeFile(attachment: attachment)
                }
            }
        }
        .readingFrame { frame in
            attachmentsHeight = min(frame.height, 300)
        }
    }

    private var replyAreaAttachFileButton: some View {
        HorizonUI.PrimaryButton(
            String(localized: "Attach file", bundle: .horizon),
            type: .white,
            leading: HorizonUI.icons.attachFile
        ) {
            viewModel.attachFile(viewController: viewController)
        }
        .accessibilityFocused($focusedAttachedFile, equals: true)
    }

    private var replyAreaSendButton: some View {
        HorizonUI.LoadingButton(
            title: String(localized: "Send"),
            type: .institution,
            fillsWidth: false,
            isLoading: $viewModel.isSending
        ) {
            ScrollOffsetReader.dismissKeyboard()
            viewModel.sendMessage(viewController: viewController)
        }
        .disabled(viewModel.isSendDisabled)
    }

    private var titleBar: some View {
        ZStack(alignment: .topLeading) {
            Text(viewModel.headerTitle)
                .lineLimit(2)
                .huiTypography(.labelLargeBold)
                .frame(maxWidth: .infinity)
                .foregroundColor(HorizonUI.colors.surface.institution)
                .accessibilityAddTraits(.isHeader)
            backButton
        }
        .padding(.horizontal, HorizonUI.spaces.space24)
        .frame(maxWidth: .infinity)
    }

    private var backButton: some View {
        HorizonUI.IconButton(
            HorizonUI.icons.arrowBack,
            type: .ghost
        ) {
            viewModel.pop(viewController: viewController)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(String(localized: "Back"))
        .accessibilityAddTraits(.isButton)
    }
}

#if DEBUG
#Preview {
    HorizonMessageDetailsAssembly.makePreview()
}
#endif
