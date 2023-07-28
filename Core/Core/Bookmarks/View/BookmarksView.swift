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
        .background(Color.backgroundLightest)
        .navigationTitle(NSLocalizedString("Bookmarks", comment: ""),
                         subtitle: "")
        .navigationBarStyle(.global)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                editButton
            }
        }
        .snackBar(viewModel: viewModel.snackBarViewModel)
    }

    @ViewBuilder
    private var editButton: some View {
        if case .data = viewModel.state {
            EditButton()
                .foregroundColor(Color(Brand.shared.navTextColor))
        }
    }

    @ViewBuilder
    private var emptyPanda: some View {
        Divider()
        GeometryReader { geometry in
            RefreshableScrollView {
                InteractivePanda(scene: SpacePanda(),
                                 title: Text("No Bookmarks", bundle: .core),
                                 subtitle: Text("There are no bookmarks to display.", bundle: .core))
                .frame(maxWidth: .infinity)
                .frame(height: geometry.size.height)
            } refreshAction: { _ in
                // TODO: Refresh
            }
        }
    }

    @ViewBuilder
    private var loadingView: some View {
        ProgressView()
            .progressViewStyle(.indeterminateCircle())
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func bookmarkList(_ bookmarks: [BookmarkCellViewModel]) -> some View {
        List {
            ForEach(bookmarks) { bookmark in
                BookmarkCellView(bookmark: bookmark)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(SwiftUI.EmptyView())
            }
            .onDelete { deletedIndexes in
                guard let deletedIndex = deletedIndexes.first else { return }
                viewModel.bookmarkDidDelete(at: deletedIndex)
            }
            .onMove { fromIndexes, toIndex in
                guard let fromIndex = fromIndexes.first else { return }
                viewModel.bookmarkDidMove(fromIndex: fromIndex, toIndex: toIndex)
            }
        }
        .listStyle(.plain)
    }
}

#if DEBUG

@available(iOSApplicationExtension 16.0, *)
struct BookmarksView_Previews: PreviewProvider {
    static let preview = PreviewEnvironment()
    static var previews: some View {
        let interactors = [
            BookmarksInteractorPreview(mockState: .loading,
                                       context: preview.database.viewContext),
            BookmarksInteractorPreview(mockState: .empty,
                                       context: preview.database.viewContext),
            BookmarksInteractorPreview(mockState: .data,
                                       context: preview.database.viewContext),
        ]

        ForEach(0..<3) { index in
            NavigationStack {
                VStack(spacing: 0) {
                    Divider().background(Color.backgroundDark)
                    BookmarksView(viewModel: BookmarksViewModel(interactor: interactors[index]))
                }
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}

#endif
