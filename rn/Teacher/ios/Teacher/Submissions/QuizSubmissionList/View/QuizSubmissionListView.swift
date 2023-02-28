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
import Core

struct QuizSubmissionListView: View {
    @ObservedObject private var model: QuizSubmissionListViewModel

    init(model: QuizSubmissionListViewModel) {
        self.model = model
    }

    public var body: some View {
        VStack(spacing: 0) {
            Color.borderMedium
                .frame(height: 0.5)
            if model.state == .loading {
                loadingIndicator
            } else {
                List {
                    switch model.state {
                    case .data:
                        submissionList
                    case .empty:
                        EmptyPanda(.Teacher,
                            title: Text("No Submissions", bundle: .core),
                            message: Text("It seems there aren't any valid submissions to grade.", bundle: .core))
                    case .error:
                        Text("There was an error loading submissions. Pull to refresh to try again.")
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
                .animation(.default, value: model.submissions)
                }
            }
            .background(Color.backgroundLightest)
        //.navigationBarItems(leading: menuButton)
    }

    private var loadingIndicator: some View {
        ProgressView()
            .progressViewStyle(.indeterminateCircle())
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .accentColor(Color(Brand.shared.primary))
            .listRowInsets(EdgeInsets())
            .listRowSeparator(.hidden)
    }

    var submissionList: some View {
        ForEach(model.submissions) { submission in
            VStack(spacing: 0) {
                QuizSubmissionListItemView(model: submission)
                Color.borderMedium
                    .frame(height: 0.5)
                    .overlay(Color.backgroundLightest.frame(width: 64), alignment: .leading)
            }
            .listRowInsets(EdgeInsets())
            .listRowSeparator(.hidden)
        }
    }
}
