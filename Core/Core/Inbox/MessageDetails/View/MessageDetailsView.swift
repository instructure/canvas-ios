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
        VStack(alignment: .leading, spacing: 0) {
            if model.state == .loading {
                loadingIndicator
            } else {
                List {
                    switch model.state {
                    case .data:
                        detailsView
                            .listRowBackground(SwiftUI.EmptyView())
                    case .empty, .error:
                        Text("There was an error loading the message. Pull to refresh to try again.")
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
        .background(Color.backgroundLightest)
        .navigationTitle(model.title)
        .navigationBarItems(trailing: moreButton)
    }

    private var loadingIndicator: some View {
        ProgressView()
            .progressViewStyle(.indeterminateCircle())
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .accentColor(Color(Brand.shared.primary))
            .listRowInsets(EdgeInsets())
            .listRowSeparator(.hidden)
    }

    private var detailsView: some View {
        VStack(spacing: 16) {
            headerView
            Color.borderMedium
                .frame(height: 0.5)
            messageList
        }
    }

    private var headerView: some View {
        HStack {
            Text(model.subject)
                .font(.semibold22)
            Spacer()
            starButton
        }
    }

    private var moreButton: some View {
        Button(action: {

        }, label: {
            Image
                .moreLine
                .foregroundColor(Color(Brand.shared.navTextColor))
        })
        .identifier("MessageDetails.profileButton")
        .accessibility(label: Text("More options", bundle: .core))
    }

    private var starButton: some View {
        Button(action: {
            model.starDidTap.send()
        }, label: {
            let star = model.starred ? Image.starSolid : Image.starLine
            star
                .size(30)
                .foregroundColor(.textDark)
                .padding(.leading, 6)
                .accessibilityHidden(true)
        })

    }

    private var messageList: some View {
        ForEach(model.messages) { message in
            VStack(spacing: 0) {
                MessageView(model: message)
                Color.borderMedium
                    .frame(height: 0.5)
            }
            .listRowInsets(EdgeInsets())
            .listRowSeparator(.hidden)
            .listRowBackground(SwiftUI.EmptyView())
        }
    }
}

#if DEBUG

struct MessageDetailsView_Previews: PreviewProvider {
    static let env = PreviewEnvironment()
    static let context = env.globalDatabase.viewContext

    static var previews: some View {
        let body = """
        Lorem Ipsum is simply dummy text of the printing and typesetting industry.
        Lorem Ipsum has been the industry's standard dummy text ever since the 1500s,
        when an unknown printer took a galley of type and scrambled it to make a type specimen book.
        """
        MessageDetailsAssembly.makePreview(env: env, subject: "Message Title", messages: .make(count: 5, body: body, in: context))
    }
}

#endif
