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

struct MessageDetailsView: View {
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
                GeometryReader { geometry in
                    List {
                        switch model.state {
                        case .data:
                            messageList
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
        }
        .background(Color.backgroundLightest)
        .navigationTitle(model.title)
       // .navigationBarItems(trailing: messageUsersButton)
    }

    private var loadingIndicator: some View {
        ProgressView()
            .progressViewStyle(.indeterminateCircle())
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .accentColor(Color(Brand.shared.primary))
            .listRowInsets(EdgeInsets())
            .listRowSeparator(.hidden)
    }

    private var messageList: some View {
        ForEach(model.messages) { message in
            VStack(spacing: 0) {
                //QuizSubmissionListItemView(model: submission, cellDidTap: { model.submissionDidTap() })
                Text(message.body)
                Color.borderMedium
                    .frame(height: 0.5)
                    .overlay(Color.backgroundLightest.frame(width: 64), alignment: .leading)
            }
            .listRowInsets(EdgeInsets())
            .listRowSeparator(.hidden)
            .listRowBackground(SwiftUI.EmptyView())
        }
    }
}

#if DEBUG
/*
struct MessageDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        MessageDetailsView()
    }
}
*/

#endif
