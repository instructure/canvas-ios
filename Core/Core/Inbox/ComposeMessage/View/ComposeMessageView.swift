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

public struct ComposeMessageView: View {
    @ObservedObject private var model: ComposeMessageViewModel
    @Environment(\.viewController) private var controller

    @ScaledMetric private var uiScale: CGFloat = 1

    @FocusState private var subjectTextFieldFocus: Bool
    @FocusState private var messageTextFieldFocus: Bool
    @State private var showExtraSendButton = false
    @State private var headerHeight = CGFloat.zero
    private var proxyScrollViewKey = "scrollview"

    init(model: ComposeMessageViewModel) {
        self.model = model
    }

    public var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 0) {
                    scrollViewProxyView
                    headerView
                        .background(
                            GeometryReader { proxy in
                                Color.clear
                                    .onAppear {
                                        headerHeight = proxy.size.height
                                    }
                            }
                        )
                    separator
                    VStack(spacing: 0) {
                        propertiesView
                    }
                    separator
                    VStack(spacing: 0) {
                        bodyView
                            .frame(minHeight: geometry.size.height / 2)
                        attachmentsView
                        if !model.includedMessages.isEmpty {
                            includedMessages
                        }
                    }
                    .frame(minHeight: geometry.size.height)
                    separator

                }
                .background(Color.backgroundLightest)
                .navigationBarItems(leading: cancelButton, trailing: extraSendButton)
                .navigationBarStyle(.modal)
            }
            .coordinateSpace(name: proxyScrollViewKey)
            .onPreferenceChange(ViewSizeKey.self) { offset in
                if (offset < -headerHeight) {
                    showExtraSendButton = true
                } else {
                    showExtraSendButton = false
                }
            }
        }
    }

    @ViewBuilder
    private var extraSendButton: some View {
        if showExtraSendButton {
            withAnimation {
                sendButton
            }
        } else {
            withAnimation {
                Color.clear
            }
        }
    }

    private var scrollViewProxyView: some View {
        GeometryReader { geometry in
            Color.clear
                .preference(key: ViewSizeKey.self, value: geometry.frame(in: .named(proxyScrollViewKey)).minY)
        }
        .frame(width: 0, height: 0)
    }

    private var separator: some View {
        Color.borderMedium
            .frame(height: 0.5)
            .padding(.horizontal, 8)
    }

    private var cancelButton: some View {
        Button {
            model.cancelButtonDidTap.accept(controller)
        } label: {
            Text("Cancel", bundle: .core)
                .font(.regular16)
                .foregroundColor(.accentColor)
        }
    }

    private var sendButton: some View {
        Button {
            model.sendButtonDidTap.accept(controller)
        } label: {
            sendButtonImage
        }
        .accessibility(label: Text("Send", bundle: .core))
        .disabled(!model.sendButtonActive)
        .frame(maxHeight: .infinity, alignment: .top)

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
        }
        .accessibility(label: Text("Add recipient", bundle: .core))
    }

    private var headerView: some View {
        HStack(alignment: .center) {
            Text(model.subject.isEmpty ? model.title : model.subject)
                .multilineTextAlignment(.leading)
                .font(.semibold22)
                .foregroundColor(.textDarkest)
            Spacer()
            sendButton
        }
        .padding(.horizontal, 16).padding(.vertical, 12)
        .frame(minHeight: 52)
    }

    private var propertiesView: some View {
        VStack(spacing: 0) {
            courseView
            separator
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
                if let context = model.selectedContext {
                    Text(context.name)
                        .font(.regular16, lineHeight: .condensed)
                        .multilineTextAlignment(.leading)
                        .foregroundColor(.textDarkest)
                }
                Spacer()
                if !model.isContextDisabled { DisclosureIndicator() }
            }
        }
        .disabled(model.isContextDisabled)
        .opacity(model.isContextDisabled ? 0.6 : 1)
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .accessibilityLabel(courseSelectorAccessibilityLabel)
    }

    private var toView: some View {
        Button {
            model.addRecipientButtonDidTap(viewController: controller)
        } label: {
            HStack {
                Text("To", bundle: .core)
                    .font(.regular16, lineHeight: .condensed)
                    .foregroundColor(.textDark)
                    .padding(.vertical, 12)
                    .accessibilitySortPriority(2)
                if !model.recipients.isEmpty {
                    recipientsView
                        .accessibilitySortPriority(0)
                }
                Spacer()
                addRecipientButton
                    .padding(.vertical, 12)
                    .accessibilitySortPriority(1)
            }
            .accessibilityElement(children: .contain)
        }
        .disabled(model.isRecipientsDisabled)
        .opacity(model.isRecipientsDisabled ? 0.6 : 1)
        .padding(.horizontal, 16)
        .accessibilityElement(children: .contain)
    }

    private var recipientsView: some View {
        WrappingHStack(models: model.recipients) { recipient in
            RecipientPillView(recipient: recipient, removeDidTap: { recipient in
                model.recipientDidRemove.accept(recipient)
            })
        }
    }

    private var subjectView: some View {
        HStack {
            Text("Subject", bundle: .core)
                .font(.regular16, lineHeight: .condensed)
                .foregroundColor(.textDark)
                .onTapGesture {
                    self.subjectTextFieldFocus = true
                }
                .accessibilityHidden(true)
            TextField("", text: $model.subject)
                .multilineTextAlignment(.leading)
                .font(.regular16, lineHeight: .condensed)
                .foregroundColor(.textDarkest)
                .textInputAutocapitalization(.sentences)
                .focused($subjectTextFieldFocus)
                .accessibility(label: Text("Subject", bundle: .core))
        }
        .disabled(model.isSubjectDisabled)
        .opacity(model.isSubjectDisabled ? 0.6 : 1)
        .padding(.horizontal, 16).padding(.vertical, 12)
    }

    private var individualView: some View {
        Toggle(isOn: $model.sendIndividual) {
            Text("Send individual message to each recipient", bundle: .core)
                .font(.regular16, lineHeight: .condensed)
                .foregroundColor(.textDarkest)
        }
        .tint(.accentColor)
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    private var bodyView: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Message", bundle: .core)
                    .font(.regular16, lineHeight: .condensed)
                    .foregroundColor(.textDark)
                    .onTapGesture {
                        self.messageTextFieldFocus = true
                    }
                    .accessibilityHidden(true)
                Spacer()
                Button {
                    model.attachmentbuttonDidTap(viewController: controller)
                } label: {
                    Image.paperclipLine
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(.textDarkest)
                        .frame(width: 24, height: 24)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                }
                .accessibility(label: Text("Add attachment", bundle: .core))
            }
            .padding(.leading, 16)
            TextEditor(text: $model.bodyText)
                .iOS16HideListScrollContentBackground()
                .font(.regular16, lineHeight: .condensed)
                .textInputAutocapitalization(.sentences)
                .focused($messageTextFieldFocus)
                .foregroundColor(.textDarkest)
                .padding(.horizontal, 12)
                .frame(minHeight: 60)
                .accessibility(label: Text("Message", bundle: .core))
        }
        .disabled(model.isMessageDisabled)
        .opacity(model.isMessageDisabled ? 0.6 : 1)
    }

    private var includedMessages: some View {
        VStack(alignment: .leading) {
            Text("Included messages", bundle: .core)
                .font(.bold16)
            separator
            ForEach(model.includedMessages, id: \.id) { conversationMessage in
                messageView(for: conversationMessage)
                separator
            }
        }
        .padding(.horizontal, 12)
    }

    @ViewBuilder
    private func messageView(for message: ConversationMessage) -> some View {
        if model.isMessageExpanded(message: message) {
            expandedMessageView(for: message)
        } else {
            collapsedMessageView(for: message)
        }
    }

    private func expandedMessageView(for message: ConversationMessage) -> some View {
        let author = model.conversation?.participants.first { $0.id == message.authorID }
        return VStack(alignment: .leading) {
            Button {
                withAnimation {
                    model.toggleMessageExpand(message: message)
                }
            } label: {
                HStack {
                    Avatar(name: author?.name, url: author?.avatarURL, size: 36, isAccessible: false)
                    VStack(alignment: .leading) {
                        Text(author?.name ?? "")
                            .foregroundStyle(Color.textDarkest)
                        Text(message.createdAt?.dateTimeString ?? "")
                            .foregroundStyle(Color.textDark)
                    }
                    Spacer()
                }
            }
            .padding(.bottom, 12)

            Text(message.body)
                .foregroundStyle(Color.textDark)

            if !message.attachments.isEmpty {
                AttachmentCardsView(attachments: message.attachments, mediaComment: message.mediaComment)
                    .frame(height: 104)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 12)
    }

    private func collapsedMessageView(for message: ConversationMessage) -> some View {
        return Button {
                withAnimation {
                    model.toggleMessageExpand(message: message)
                }
            } label: {
                VStack(alignment: .leading) {
                    HStack {
                        Text(model.conversation?.participants.first { $0.id == message.authorID }?.name ?? "")
                            .foregroundStyle(Color.textDarkest)
                            .lineLimit(1)
                        Spacer()
                        Text(message.createdAt?.dateTimeString ?? "")
                            .foregroundStyle(Color.textDark)
                            .lineLimit(1)
                    }
                    Text(message.body)
                        .foregroundStyle(Color.textDark)
                        .lineLimit(1)
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 12)
        }
    }

    private var attachmentsView: some View {
        ForEach(model.attachments, id: \.self) { file in
            ConversationAttachmentCardView(file: file) {
                model.removeAttachment(file: file)
            }
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
