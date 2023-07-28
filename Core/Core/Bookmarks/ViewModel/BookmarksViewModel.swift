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
import Combine
import CombineExt
import CombineSchedulers

public class BookmarksViewModel: ObservableObject {
    public enum ViewModelState<T: Equatable>: Equatable {
        case loading
        case empty
        case data(T)
    }

    @Published public private(set) var state: ViewModelState<[BookmarkCellViewModel]> = .loading
    public let snackBarViewModel = SnackBarViewModel()
    private let interactor: BookmarksInteractor
    private let mainScheduler: AnySchedulerOf<DispatchQueue>

    public init(interactor: BookmarksInteractor, mainScheduler: AnySchedulerOf<DispatchQueue> = .main) {
        self.interactor = interactor
        self.mainScheduler = mainScheduler

        interactor
            .getBookmarks()
            .mapArray {
                BookmarkCellViewModel(id: $0.id, name: $0.name, contextName: $0.contextName, url: $0.url)
            }
            .map { (bookmarks: [BookmarkCellViewModel]) -> ViewModelState<[BookmarkCellViewModel]> in
                if bookmarks.isEmpty {
                    return .empty
                } else {
                    return .data(bookmarks)
                }
            }
            .replaceError(with: .empty)
            .assign(to: &$state)
    }

    public func bookmarkDidDelete(at index: Int) {
        guard case .data(var bookmarks) = state  else { return }
        let idToDelete = bookmarks[index].id

        var subscription: AnyCancellable?
        subscription = interactor
            .deleteBookmark(id: idToDelete)
            .map {
                bookmarks.removeAll { bookmarkViewModel in
                    bookmarkViewModel.id == idToDelete
                }
                return bookmarks
            }
            .map { $0.isEmpty ? ViewModelState.empty : ViewModelState.data($0) }
            .receive(on: mainScheduler)
            .handleEvents(receiveOutput: { [snackBarViewModel] _ in
                snackBarViewModel.showSnack(NSLocalizedString("Bookmark deleted", comment: ""))
            })
            .sink { _ in
                subscription?.cancel()
                subscription = nil
            } receiveValue: { [weak self] in
                self?.state = $0
            }
    }

    public func bookmarkDidMove(fromIndex: Int, toIndex: Int) {
        interactor
            .moveBookmark(fromIndex: fromIndex,
                          toIndex: toIndex)
            .mapArray { BookmarkCellViewModel(id: $0.id, name: $0.name, contextName: $0.contextName, url: $0.url) }
            .map { .data($0) }
            .ignoreFailure()
            .assign(to: &$state)
    }
}
