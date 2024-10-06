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

public struct ComposeMessageView: View, ScreenViewTrackable {
    @ObservedObject private var model: ComposeMessageViewModel
    @Environment(\.viewController) private var controller
    @ScaledMetric private var uiScale: CGFloat = 1
    public let screenViewTrackingParameters: ScreenViewTrackingParameters
    @State private var recipientViewHeight: CGFloat = .zero
    @State private var searchTextFieldHeight: CGFloat = .zero
    private let attachmentsViewId = "attachmentsView"
    private enum FocusedInput {
        case subject
        case message
        case search
    }
    @FocusState private var focusedInput: FocusedInput?
    @State private var headerHeight = CGFloat.zero

    private let defaultVerticalPaddingValue: CGFloat = 12
    private let defaultHorizontalPaddingValue: CGFloat = 16

    init(model: ComposeMessageViewModel) {
        self.model = model

        screenViewTrackingParameters = ScreenViewTrackingParameters(
            eventName: "/conversations/compose"
        )
    }

    public var body: some View {
        InstUI.BaseScreen(state: model.state, config: model.screenConfig) { geometry in
            ScrollViewReader { proxy in
                VStack(spacing: 0) {
                    headerView
                        .background(
                            GeometryReader { proxy in
                                Color.clear
                                    .onAppear {
                                        headerHeight = proxy.size.height
                                        model.showSearchRecipientsView = false
                                        focusedInput = nil
                                    }
                            }
                        )
                    separator
                    courseView
                    separator
                    ZStack(alignment: .topLeading) {
                        VStack(spacing: 0) {
                            propertiesView
                            separator

                            bodyView(geometry: geometry) {
                                withAnimation {
                                    proxy.scrollTo(attachmentsViewId)
                                }
                            }
                            attachmentsView
                                .id(attachmentsViewId)
                            if !model.includedMessages.isEmpty {
                                includedMessages
                            }
                            // This Rectangle adds extra height to ensure smoother display of the list of recipients
                            // without affecting the UI or any logic.
                            Rectangle()
                                .fill(Color.clear)
                                .frame(height: 150)
                                .allowsHitTesting(false)
                        }
                        if model.showSearchRecipientsView {
                            RecipientFilterView(recipients: model.searchedRecipients) { selectedRecipient in
                                model.showSearchRecipientsView = false
                                model.textRecipientSearch = ""
                                model.didSelectRecipient.accept(selectedRecipient)
                            }
                            .accessibilityHidden(true)
                            .offset(y: model.recipients.isEmpty ? searchTextFieldHeight : recipientViewHeight + searchTextFieldHeight)
                            .padding(.horizontal, 35)
                            .fixedSize(horizontal: false, vertical: true)
                            .animation(.smooth, value: model.showSearchRecipientsView)
                        }

                    }
                }
            }
            .font(.regular12)
            .foregroundColor(.textDarkest)
            .background(
                GeometryReader { reader in
                    return Color.backgroundLightest
                        .onTapGesture {
                            model.clearSearchedRecipients()
                            focusedInput = nil
                        }
                        .preference(key: ViewSizeKey.self, value: -reader.frame(in: .named("scroll")).origin.y)
                }
            )
            .navigationBarItems(leading: cancelButton, trailing: extraSendButton)
            .navigationBarStyle(.modal)
        }
        .onPreferenceChange(ViewSizeKey.self) { offset in
            model.showExtraSendButton = offset > headerHeight
        }
        .coordinateSpace(name: "scroll")
        .background(Color.backgroundLightest)
        .fileImporter(
            isPresented: $model.isFilePickerVisible,
            allowedContentTypes: [.item],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                model.addFiles(urls: urls)
            case .failure:
                break
            }
        }
        .sheet(isPresented: $model.isImagePickerVisible) {
            ImagePickerViewController(sourceType: .photoLibrary, imageHandler: model.addFile)
        }
        .sheet(isPresented: $model.isTakePhotoVisible) {
            ImagePickerViewController(sourceType: .camera, imageHandler: model.addFile)
                .interactiveDismissDisabled()
        }
        .sheet(isPresented: $model.isAudioRecordVisible) {
            AttachmentPickerAssembly.makeAudioPickerViewcontroller(router: model.router, onSelect: model.addFile)
                .interactiveDismissDisabled()
        }
        .confirmationAlert(
            isPresented: $model.isShowingCancelDialog,
            presenting: model.confirmAlert
        )
        .confirmationAlert(
            isPresented: $model.isShowingErrorDialog,
            presenting: model.errorAlert
        )
    }

    @ViewBuilder
    private var extraSendButton: some View {
        if model.showExtraSendButton {
            sendButton
        } else {
            Color.clear
        }
    }

    private var separator: some View {
        Color.borderMedium
            .frame(height: 0.5)
    }

    private var cancelButton: some View {
        Button {
            model.didTapCancel.accept(controller)
        } label: {
            Text("Cancel", bundle: .core)
                .font(.regular16)
                .foregroundColor(.accentColor)
                .accessibilityIdentifier("ComposeMessage.cancel")
        }
    }

   @ViewBuilder
    private var sendButton: some View {
        Button {
            model.didTapSend.accept(controller)
        } label: {
            sendButtonImage
        }
        .accessibility(label: Text("Send", bundle: .core))
        .disabled(!model.sendButtonActive)
        .frame(maxHeight: .infinity, alignment: .top)
        .accessibilityIdentifier("ComposeMessage.send")
    }

    private var sendButtonImage: some View {
        Image.circleArrowUpSolid
            .resizable()
            .frame(width: 40 * uiScale.iconScale, height: 40 * uiScale.iconScale)
            .foregroundStyle(model.sendButtonActive ? .accentColor : Color.backgroundMedium)
    }

    private var addRecipientButton: some View {
        Button {
            model.addRecipientButtonDidTap(viewController: controller)
        } label: {
            Image.addLine
                .foregroundColor(Color.textDarkest)
                .padding(.vertical, 12)
        }
        .accessibilityLabel(Text("Add recipient", bundle: .core))
        .accessibilityElement(children: .ignore)
        .accessibilityIdentifier("ComposeMessage.addRecipient")
    }

    private var headerView: some View {
        HStack(alignment: .center) {
            Text(model.subject.isEmpty ? model.title : model.subject)
                .accessibilityIdentifier("ComposeMessage.subjectLabel")
                .multilineTextAlignment(.leading)
                .font(.semibold22)
                .foregroundColor(.textDarkest)
                .onTapGesture {
                    focusedInput = .subject
                }
            Spacer()
            sendButton
        }
        .padding(.horizontal, defaultHorizontalPaddingValue)
        .padding(.vertical, defaultVerticalPaddingValue)
        .frame(minHeight: 52)
    }

    private var propertiesView: some View {
        VStack(spacing: 0) {
            if model.selectedContext != nil || model.alwaysShowRecipients {
                toView
                separator
            }
            subjectView
            if !model.isIndividualDisabled {
                separator
                individualView
            }
        }
        .fixedSize(horizontal: false, vertical: true)
    }

    private var courseSelectorAccessibilityLabel: Text {
        model.selectedContext == nil ? Text("Select course", bundle: .core) : Text("Selected course: \(model.selectedContext!.name)", bundle: .core)
    }

    private var courseView: some View {
        Button {
            model.courseSelectButtonDidTap(viewController: controller)
        } label: {
            HStack {
                Text("Course", bundle: .core)
                    .font(.regular16, lineHeight: .condensed)
                    .foregroundColor(.textDark)
                    .accessibilityIdentifier("ComposeMessage.course")
                if let context = model.selectedContext {
                    Text(context.name)
                        .font(.regular16, lineHeight: .condensed)
                        .multilineTextAlignment(.leading)
                        .foregroundColor(.textDarkest)
                }
                Spacer()
                if !model.isContextDisabled { DisclosureIndicator() }
            }
            .padding(.horizontal, defaultHorizontalPaddingValue)
            .padding(.vertical, defaultVerticalPaddingValue)
        }
        .disabled(model.isContextDisabled)
        .opacity(model.isContextDisabled ? 0.6 : 1)
        .accessibilityLabel(courseSelectorAccessibilityLabel)
    }

    private var toView: some View {
        HStack(alignment: .top) {
            toRecipientText
            VStack {
                if !model.recipients.isEmpty {
                    recipientsView
                        .accessibilitySortPriority(1)
                }

                TextField(String(localized: "Search", bundle: .core), text: $model.textRecipientSearch)
                    .font(.regular16)
                    .focused($focusedInput, equals: .search)
                    .foregroundColor(.textDark)
                    .frame(minHeight: 50)
                    .frame(maxHeight: .infinity, alignment: .center)
                    .padding(.leading, 5)
                    .accessibilityHidden(true)
                    .readingFrame { frame in
                        searchTextFieldHeight = frame.height - 5
                    }
            }
            Spacer()

            addRecipientButton
                .frame(maxHeight: .infinity, alignment: .center)
                .accessibilitySortPriority(2)
        }
        .animation(.easeInOut, value: model.recipients.isEmpty)
        .accessibilityElement(children: .contain)
        .padding(.horizontal, defaultHorizontalPaddingValue)
        .disabled(model.isRecipientsDisabled)
        .opacity(model.isRecipientsDisabled ? 0.6 : 1)
    }

    private var toRecipientText: some View {
        Text("To", bundle: .core)
            .font(.regular16, lineHeight: .condensed)
            .foregroundColor(.textDark)
            .padding(.vertical, 12)
            .accessibilitySortPriority(3)
            .accessibilityIdentifier("ComposeMessage.to")
    }

    private var recipientsView: some View {
        WrappingHStack(models: model.recipients) { recipient in
            RecipientPillView(recipient: recipient, removeDidTap: { recipient in
                model.didRemoveRecipient.accept(recipient)
            })
        }
        .readingFrame { frame in
            recipientViewHeight = frame.height
        }
    }

    private var subjectView: some View {
        HStack {
            Text("Subject", bundle: .core)
                .font(.regular16, lineHeight: .condensed)
                .foregroundColor(.textDark)
                .onTapGesture {
                    self.focusedInput = .subject
                }
                .accessibilityHidden(true)
            TextField("", text: $model.subject)
                .multilineTextAlignment(.leading)
                .font(.regular16, lineHeight: .condensed)
                .foregroundColor(.textDarkest)
                .textInputAutocapitalization(.sentences)
                .focused($focusedInput, equals: .subject)
                .submitLabel(.done)
                .accessibility(label: Text("Subject", bundle: .core))
                .accessibilityIdentifier("ComposeMessage.subjectInput")
        }
        .disabled(model.isSubjectDisabled)
        .opacity(model.isSubjectDisabled ? 0.6 : 1)
        .padding(.horizontal, defaultHorizontalPaddingValue)
        .padding(.vertical, defaultVerticalPaddingValue)
    }

    private var individualView: some View {
        Toggle(isOn: $model.sendIndividual) {
            Text("Send individual message to each recipient", bundle: .core)
                .font(.regular16, lineHeight: .condensed)
                .foregroundColor(.textDarkest)
        }
        .tint(.accentColor)
        .padding(.horizontal, defaultHorizontalPaddingValue)
        .padding(.vertical, defaultVerticalPaddingValue)
        .contentShape(Rectangle())
        .accessibilityIdentifier("ComposeMessage.individual")
    }

    @ViewBuilder
    private func bodyView(
        geometry: GeometryProxy,
        onPaste: @escaping () -> Void
    ) -> some View {
        VStack(spacing: 0) {
            HStack {
                Text("Message", bundle: .core)
                    .font(.regular16, lineHeight: .condensed)
                    .foregroundColor(.textDark)
                    .onTapGesture {
                        self.focusedInput = .message
                    }
                    .accessibilityHidden(true)
                Spacer()
                Button {
                    model.attachmentButtonDidTap(viewController: controller)
                } label: {
                    Image.paperclipLine
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(.textDarkest)
                        .frame(width: 24, height: 24)
                        .padding(.horizontal, defaultHorizontalPaddingValue)
                }
                .accessibility(label: Text("Add attachment", bundle: .core))
                .accessibilityIdentifier("ComposeMessage.attachment")
            }
            .padding(.leading, defaultHorizontalPaddingValue)
            .padding(.top, defaultVerticalPaddingValue)

            UITextViewWrapper(text: $model.bodyText, onPaste: onPaste) {
                let tv = UITextView()
                tv.isScrollEnabled = false
                tv.textContainer.widthTracksTextView = true
                tv.textContainer.lineBreakMode = .byWordWrapping
                tv.font = UIFont.scaledNamedFont(.regular16)
                tv.translatesAutoresizingMaskIntoConstraints = false
                tv.widthAnchor.constraint(equalToConstant: geometry.frame(in: .global).width - (2 * defaultHorizontalPaddingValue)).isActive = true
                tv.backgroundColor = .backgroundLightest
                return tv
            }
            .font(.regular16, lineHeight: .condensed)
            .textInputAutocapitalization(.sentences)
            .focused($focusedInput, equals: .message)
            .foregroundColor(.textDarkest)
            .padding(.horizontal, defaultHorizontalPaddingValue)
            .frame(minHeight: 60)
            .accessibility(label: Text("Message", bundle: .core))
            .accessibilityIdentifier("ComposeMessage.body")
        }
        .disabled(model.isMessageDisabled)
        .opacity(model.isMessageDisabled ? 0.6 : 1)
    }

    private var includedMessages: some View {
        VStack(alignment: .leading) {
            Text("Previous messages", bundle: .core)
                .font(.regular16, lineHeight: .condensed)
                .foregroundColor(.textDark)
                .padding(.horizontal, defaultHorizontalPaddingValue)

            ForEach(model.includedMessages, id: \.id) { conversationMessage in
                separator
                    .padding(.horizontal, 4)

                messageView(for: conversationMessage)
                    .padding(.horizontal, 4)
            }
        }
        .padding(.top, 2 * defaultVerticalPaddingValue)
    }

    private func messageView(for message: ConversationMessage) -> some View {
        let isExpanded = model.isMessageExpanded(message: message)

        return VStack(spacing: 0) {
            Button {
                withAnimation {
                    model.toggleMessageExpand(message: message)
                }
            } label: {
                VStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(model.conversation?.participants.first { $0.id == message.authorID }?.name ?? "")
                                .font(.regular16)
                                .foregroundStyle(Color.textDarkest)
                                .lineLimit(1)
                            Spacer()
                            Text(message.createdAt?.dateTimeString ?? "")
                                .font(.regular14)
                                .foregroundStyle(Color.textDark)
                                .lineLimit(1)

                            withAnimation {
                                Image.arrowOpenDownLine
                                    .resizable()
                                    .frame(
                                        width: 15 * uiScale.iconScale,
                                        height: 15 * uiScale.iconScale
                                    )
                                    .rotationEffect(.degrees(isExpanded ? 180 : 0))
                                    .foregroundColor(.textDark)
                            }
                        }

                        withAnimation {
                            Text(message.body)
                                .font(.regular14)
                                .foregroundStyle(Color.textDark)
                                .multilineTextAlignment(.leading)
                                .lineLimit(isExpanded ? nil : 1)
                        }
                    }
                    if isExpanded && !message.attachments.isEmpty {
                        AttachmentsView(attachments: message.attachments, didSelectAttachment: { model.didSelectFile.accept(($1, $0))})
                            .padding(.top, defaultVerticalPaddingValue)
                    }
                }
                .padding(.vertical, 8)
                .padding(.horizontal, defaultHorizontalPaddingValue)
            }
        }
    }

    private var attachmentsView: some View {
        ConversationAttachmentsCardView(files: model.attachments) { file in
            model.didSelectFile.accept((controller, file))
        } removeHandler: { file in
            model.didRemoveFile.accept(file)
        }
    }
}

#if DEBUG

struct ComposeMessageView_Previews: PreviewProvider {
    static let env = PreviewEnvironment()

    static var previews: some View {
        ComposeMessageAssembly.makePreview(env: env)
    }
}

#endif
