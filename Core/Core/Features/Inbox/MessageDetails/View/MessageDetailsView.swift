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

public struct MessageDetailsView: View {
    @ObservedObject private var model: MessageDetailsViewModel
    @Environment(\.viewController) private var controller
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    init(model: MessageDetailsViewModel) {
        self.model = model
    }

    public var body: some View {
        ScrollView {
            switch model.state {
            case .loading:
                loadingIndicator
            case .data:
                detailsView
            case .empty, .error:
                VStack(alignment: .center, spacing: 0) {
                    Text("There was an error loading the message. Pull to refresh to try again.", bundle: .core)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 12)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 24)
            }
        }
        .refreshable(action: model.refreshDidTrigger.send)
        .toolbar {
            if #available(iOS 26, *) {
                moreButton
            } else {
                legacyMoreButton
            }
        }
        .navigationTitle(model.title, style: .global)
        .background(Color.backgroundLightest)
        .snackBar(viewModel: model.snackBarViewModel)
    }

    private var loadingIndicator: some View {
        ProgressView()
            .progressViewStyle(.indeterminateCircle())
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .accentColor(Color(Brand.shared.primary))
            .listRowInsets(EdgeInsets())
            .listRowSeparator(.hidden)
            .padding(.all, 12)
    }

    private var detailsView: some View {
        VStack(spacing: 0) {
            headerView
            messageList
        }
        .confirmationAlert(
            isPresented: $model.isShowingCancelDialog,
            presenting: model.confirmAlert
        )
    }

    private var headerView: some View {
        HStack {
            Text(model.subject)
                .font(.semibold22)
                .accessibilityIdentifier("MessageDetails.subject")
            Spacer()
            starButton
        }
        .frame(height: 81)
        .padding(.horizontal, 16)
    }

    @available(iOS, introduced: 26, message: "Legacy version exists")
    private var moreButton: some View {
        Menu {
            if model.isReplyButtonVisible {
                Button(.init("Reply", bundle: .core), image: .replyLine) {
                    model.replyTapped(message: nil, viewController: controller)
                }
                .accessibilityIdentifier("MessageDetails.reply")

                if !model.isStudentAccessRestricted {
                    Button(.init("Reply All", bundle: .core), image: .replyAllLine) {
                        model.replyAllTapped(message: nil, viewController: controller)
                    }
                    .accessibilityIdentifier("MessageDetails.replyAll")
                }
            }


            Button(.init("Forward", bundle: .core), image: .forwardLine) {
                model.forwardTapped(viewController: controller)
            }
            .accessibilityIdentifier("MessageDetails.forward")

            if model.conversations.first?.workflowState == .read {
                Button(.init("Mark as Unread", bundle: .core), image: .nextUnreadLine) {
                    model.updateState.send(.unread)
                }
                .accessibilityIdentifier("MessageDetails.markAsUnread")
            } else {
                Button(.init("Mark as Read", bundle: .core), image: .emailLine) {
                    model.updateState.send(.read)
                }
                .accessibilityIdentifier("MessageDetails.markAsRead")
            }

            if model.conversations.first?.workflowState != .archived, model.allowArchive {
                Button(.init("Archive", bundle: .core), image: .archiveLine) {
                    model.updateState.send(.archived)
                }
                .accessibilityIdentifier("MessageDetails.archive")
            }

            if model.conversations.first?.workflowState == .archived, model.allowArchive {
                Button(.init("Unarchive", bundle: .core), image: .unarchiveLine) {
                    model.updateState.send(.read)
                }
                .accessibilityIdentifier("MessageDetails.unarchive")
            }

            if !model.isStudentAccessRestricted {
                Button(.init("Delete Conversation", bundle: .core), image: .trashLine) {
                    if let conversationId = model.conversations.first?.id {
                        model.deleteConversationDidTap.send((conversationId, controller))
                    }
                }
                .accessibilityIdentifier("MessageDetails.delete")
            }
        } label: {
            Image.moreSolid
        }
        .accessibilityIdentifier("MessageDetails.more")
        .accessibility(label: Text("More options", bundle: .core))
    }

    @available(iOS, deprecated: 26, message: "Non-legacy version exists")
    private var legacyMoreButton: some View {
        Button(action: {
            model.conversationMoreTapped(viewController: controller)
        }, label: {
            Image
                .moreLine
                .foregroundColor(Color(Brand.shared.navTextColor))
        })
        .accessibilityIdentifier("MessageDetails.more")
        .accessibility(label: Text("More options", bundle: .core))
    }

    private var starButton: some View {
        if model.starred {
            Button {
                model.starDidTap.send(!model.starred)
            } label: {
                return Image.starSolid
                    .size(30)
                    .foregroundColor(.textDark)
                    .padding(.leading, 6)
                    .accessibilityLabel(String(localized: "Mark as Unstarred", bundle: .core))
                    .accessibilityIdentifier("MessageDetails.unstar")
            }
        } else {
            Button {
                model.starDidTap.send(!model.starred)
            } label: {
                return Image.starLine
                    .size(30)
                    .foregroundColor(.textDark)
                    .padding(.leading, 6)
                    .accessibilityLabel(String(localized: "Mark as Starred", bundle: .core))
                    .accessibilityIdentifier("MessageDetails.star")
            }
        }
    }

    private var messageList: some View {
        ForEach(model.messages) { message in
            VStack(spacing: 0) {
                Color.borderMedium
                    .frame(height: 0.5)

                if #available(iOS 26, *) {
                    MessageView(model: message,
                                isReplyButtonVisible: model.isReplyButtonVisible,
                                isStudentAccessRestricted: model.isStudentAccessRestricted,
                                replyDidTap: { model.messageReplyTapped(message: message.conversationMessage, viewController: controller) },
                                replyAllDidTap: { model.messageReplyAllTapped(message: message.conversationMessage, viewController: controller) },
                                forwardDidTap: { model.forwardTapped(message: message.conversationMessage, viewController: controller)},
                                deleteDidTap: { model.deleteMessageTapped(message: message.conversationMessage, viewController: controller) }
                    )
                    .padding(16)
                } else {
                    LegacyMessageView(model: message,
                                isReplyButtonVisible: model.isReplyButtonVisible,
                                replyDidTap: { model.replyTapped(message: message.conversationMessage, viewController: controller) },
                                moreDidTap: { model.messageMoreTapped(message: message.conversationMessage, viewController: controller) })
                    .padding(16)
                }
            }
        }
    }
}

#if DEBUG

struct MessageDetailsView_Previews: PreviewProvider {
    static let env = PreviewEnvironment()
    static let context = env.globalDatabase.viewContext

    static var previews: some View {
        NavigationStack {
            MessageDetailsAssembly.makePreview(env: env, subject: "Message Title", messages: .make(count: 5, body: InstUI.PreviewData.loremIpsumLong, in: context))
        }
    }
}

#endif
