//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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

public struct InboxView: View {
    @ObservedObject private var model: InboxViewModel
    @Environment(\.viewController) private var controller

    public init(model: InboxViewModel) {
        self.model = model
    }

    public var body: some View {
        VStack(spacing: 0) {
            InboxFilterBarView(model: model)
            Color.borderMedium
                .frame(height: 0.5)
            if case .loading = model.state {
                loadingIndicator
            } else {
                GeometryReader { geometry in
                    List {
                        switch model.state {
                        case .data:
                            messagesList
                                .listRowBackground(SwiftUI.EmptyView())
                            nextPageLoadingIndicator(geometry: geometry)
                                .onAppear {
                                    model.contentDidScrollToBottom.send()
                                }
                        case .empty:
                            panda(geometry: geometry, data: model.emptyState)
                        case .error:
                            panda(geometry: geometry, data: model.errorState)
                        case .loading:
                            SwiftUI.EmptyView()
                        }
                    }
                    .refreshable {
                        await withCheckedContinuation { continuation in
                            model.refreshDidTrigger.send {
                                continuation.resume()
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                    .animation(.default, value: model.messages)
                }
            }
        }
        .background(Color.backgroundLightest)
        .navigationBarItems(leading: menuButton)
    }

    private var messagesList: some View {
        ForEach(model.messages) { message in
            VStack(spacing: 0) {
                InboxMessageView(model: message, cellDidTap: { messageID in
                    model.messageDidTap.send((messageID: messageID, controller: controller))
                })
                Color.borderMedium
                    .frame(height: 0.5)
                    .overlay(Color.backgroundLightest.frame(width: 64), alignment: .leading)
            }
            .listRowInsets(EdgeInsets())
            .listRowSeparator(.hidden)
            .swipeActions(edge: .trailing) {
                archiveButton(message: message)
            }
            .swipeActions(edge: .leading) {
                readStatusToggleButton(message: message)
            }
        }
    }

    @ViewBuilder
    private func archiveButton(message: InboxMessageListItemViewModel) -> some View {
        if message.isArchiveActionAvailable {
            Button {
                model.updateState.send((messageId: message.id, state: .archived))
            }
            label: {
                Label {
                    Text("Archive", bundle: .core)
                } icon: {
                    Image.archiveLine
                        .foregroundColor(.textLightest)
                }
                .labelStyle(.iconOnly)
            }
            .tint(.ash)
        } else {
            SwiftUI.EmptyView()
        }
    }

    @ViewBuilder
    private func readStatusToggleButton(message: InboxMessageListItemViewModel) -> some View {
        let isMarkAsReadAction = message.isMarkAsReadActionAvailable

        Button {
            model.updateState.send((messageId: message.id,
                                    state: isMarkAsReadAction ? .read : .unread))
        }
        label: {
            Label {
                isMarkAsReadAction
                ? Text("Mark as read", bundle: .core)
                : Text("Mark as unread", bundle: .core)
            } icon: {
                (isMarkAsReadAction ? Image.markReadLine : Image.emailLine)
                    .foregroundColor(.textLightest)
            }
            .labelStyle(.iconOnly)
        }
        .tint(.electric)
    }

    private var loadingIndicator: some View {
        ProgressView()
            .progressViewStyle(.indeterminateCircle())
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .accentColor(Color(Brand.shared.primary))
            .listRowInsets(EdgeInsets())
            .listRowSeparator(.hidden)
    }

    private func panda(geometry: GeometryProxy,
                       data: (scene: PandaScene,
                              title: String,
                              text: String))
    -> some View {
        InteractivePanda(scene: data.scene,
                         title: Text(data.title),
                         subtitle: Text(data.text))
            .frame(width: geometry.size.width,
                   height: geometry.size.height,
                   alignment: .center)
            .background(Color.backgroundLightest)
            .listRowInsets(EdgeInsets())
            .listRowSeparator(.hidden)
    }

    private var menuButton: some View {
        Button {
            model.menuDidTap.send(controller)
        } label: {
            Image.hamburgerSolid
                .foregroundColor(Color(Brand.shared.navTextColor.ensureContrast(against: Brand.shared.navBackground)))
        }
        .frame(width: 44, height: 44).padding(.leading, -6)
        .identifier("inbox.profileButton")
        .accessibility(label: Text("Profile Menu", bundle: .core))
    }

    @ViewBuilder
    private func nextPageLoadingIndicator(geometry: GeometryProxy) -> some View {
        if model.hasNextPage {
            ProgressView()
                .progressViewStyle(.indeterminateCircle(size: 20, lineWidth: 2))
                .listRowInsets(EdgeInsets())
                .frame(height: 44)
                .frame(maxWidth: .infinity)
                .accentColor(Color(Brand.shared.primary))
                .listRowSeparator(.hidden)
                .background(Color.backgroundLightest)
        }
    }
}

#if DEBUG

struct InboxView_Previews: PreviewProvider {
    static let env = PreviewEnvironment()
    static let context = env.globalDatabase.viewContext

    static var previews: some View {
        InboxAssembly.makePreview(environment: env,
                                  messages: .make(count: 5, in: context))

        InboxAssembly.makePreview(environment: env,
                                  messages: [])
            .previewDisplayName("Empty State")
    }
}

#endif
