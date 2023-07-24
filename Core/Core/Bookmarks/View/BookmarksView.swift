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

public struct BookmarksView: View {
    @ObservedObject private var viewModel: BookmarksViewModel

    public init(viewModel: BookmarksViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack(spacing: 0) {
            switch viewModel.state {
            case .empty:
                emptyPanda
            case .loading:
                loadingView
            case .data(let bookmarks):
                bookmarkList(bookmarks)
            }
        }
        .navigationTitle(NSLocalizedString("Bookmarks", comment: ""),
                         subtitle: "")
        .onAppear { viewModel.viewDidAppear() }
    }

    @ViewBuilder
    private var emptyPanda: some View {
        Divider()
        GeometryReader { geometry in
            List {
                EmptyPanda(.NoEvents,
                           title: Text("No Bookmarks", bundle: .core),
                           message: Text("There are no bookmarks to display.", bundle: .core))
                    .listRowSeparator(.hidden)
                    .frame(maxWidth: .infinity)
                    .frame(height: geometry.size.height)
            }
            .listStyle(.plain)
        }
    }

    @ViewBuilder
    private var loadingView: some View {
        Divider()
        Spacer()
        ProgressView()
            .progressViewStyle(.indeterminateCircle())
        Spacer()
    }

    private func bookmarkList(_ bookmarks: [BookmarkCellViewModel]) -> some View {
        List {
            ForEach(bookmarks, id: \.url) { bookmark in
                BookmarkCellView(bookmark: bookmark)
            }
        }
        .listStyle(.plain)
    }
}

struct BookmarksView_Previews: PreviewProvider {
    static var previews: some View {
        BookmarksView(viewModel: BookmarksViewModel(state: .empty))
    }
}
