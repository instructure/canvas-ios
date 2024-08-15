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

    init(model: MessageDetailsViewModel) {
        self.model = model
    }

    public var body: some View {
        RefreshableScrollView {
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
        refreshAction: { onComplete in
            model.refreshDidTrigger.send {
                onComplete()
            }
        }
        .background(Color.backgroundLightest)
        .navigationTitle(model.title)
        .navigationBarStyle(.color(Brand.shared.navBackground))
        .navigationBarItems(trailing: moreButton)
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

    private var moreButton: some View {
        Button(action: {
            model.conversationMoreTapped(viewController: controller)
        }, label: {
            Image
                .moreLine
                .foregroundColor(Color(Brand.shared.navTextColor))
        })
        .identifier("MessageDetails.more")
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

                MessageView(model: message,
                            replyDidTap: { model.replyTapped(message: message.conversationMessage, viewController: controller) },
                            moreDidTap: { model.messageMoreTapped(message: message.conversationMessage, viewController: controller) })
                .padding(16)

            }
        }
    }
}

#if DEBUG

struct MessageDetailsView_Previews: PreviewProvider {
    static let env = PreviewEnvironment()
    static let context = env.globalDatabase.viewContext

    static var previews: some View {
        MessageDetailsAssembly.makePreview(env: env, subject: "Message Title", messages: .make(count: 5, body: InstUI.PreviewData.loremIpsumLong, in: context))
    }
}

#endif
