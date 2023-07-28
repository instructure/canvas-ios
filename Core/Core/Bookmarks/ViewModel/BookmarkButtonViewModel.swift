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

import Combine
import CombineExt

class BookmarkButtonViewModel: ObservableObject {
    @Published public var isShowingConfirmationDialog = false
    @Published public var isBookmarked = false
    public private(set) var confirmDialog: ConfirmationAlertViewModel
    private let confirmAddDialog = ConfirmationAlertViewModel(
        title: NSLocalizedString("Add Bookmark?", comment: ""),
        message: NSLocalizedString(
            """
            After you have added a bookmark you can access it from the bookmarks menu or \
            by long pressing on the application's icon on your device's home screen. Only \
            the top four bookmarks are accessible this way.
            """, comment: ""),
        cancelButtonTitle: NSLocalizedString("Cancel", comment: ""),
        confirmButtonTitle: NSLocalizedString("OK", comment: ""),
        isDestructive: false
    )
    private let confirmDeleteDialog = ConfirmationAlertViewModel(
        title: NSLocalizedString("Delete Bookmark?", comment: ""),
        message: NSLocalizedString(
            """
            This screen is already bookmarked. Do you want to delete the bookmark for this screen?
            """, comment: ""),
        cancelButtonTitle: NSLocalizedString("Cancel", comment: ""),
        confirmButtonTitle: NSLocalizedString("Delete", comment: ""),
        isDestructive: true
    )
    private let bookmarksInteractor: BookmarksInteractor
    private let route: String
    private let snackBarViewModel: SnackBarViewModel?
    private var existingBookmarkId: String?
    private let bookmarkDeleted = PassthroughRelay<Void>()
    private let bookmarkAdded = PassthroughRelay<BookmarksInteractor.BookmarkID>()
    private var subscriptions = Set<AnyCancellable>()

    public init(bookmarksInteractor: BookmarksInteractor,
                route: String,
                snackBarViewModel: SnackBarViewModel? = nil) {
        self.bookmarksInteractor = bookmarksInteractor
        self.route = route
        self.snackBarViewModel = snackBarViewModel
        self.confirmDialog = confirmAddDialog

        loadExistingBookmark()

        showSnackbarOnBookmarkDelete()
        resetStoredBookmarkIdOnBookmarkDelete()
        updateBookmarkedStateOnBookmarkDelete()

        showSnackbarOnNewBookmark()
        saveBookmarkIdOnNewBookmark()
        updateBookmarkedStateOnNewBookmark()
    }

    public func bookmarkButtonDidTap(title: String, contextName: String?) {
        if isBookmarked {
            guard let existingBookmarkId else { return }
            confirmDialog = confirmDeleteDialog
            confirmDeleteDialog
                .userConfirmation()
                .flatMap { [bookmarksInteractor] in
                    bookmarksInteractor
                        .deleteBookmark(id: existingBookmarkId)
                        .ignoreFailure()
                }
                .sink { [bookmarkDeleted] _ in
                    bookmarkDeleted.accept(())
                }
                .store(in: &subscriptions)
        } else {
            confirmDialog = confirmAddDialog
            confirmAddDialog
                .userConfirmation()
                .flatMap { [bookmarksInteractor, route] in
                    bookmarksInteractor
                        .addBookmark(title: title, route: route, contextName: contextName)
                        .ignoreFailure()
                }
                .sink { [bookmarkAdded] bookmarkId in
                    bookmarkAdded.accept(bookmarkId)
                }
                .store(in: &subscriptions)
        }

        isShowingConfirmationDialog = true
    }

    private func loadExistingBookmark() {
        let bookmarkPublisher = bookmarksInteractor
            .getBookmark(for: route)
            .map { $0?.id }
            .makeConnectable()

        saveBookmarkIdOnBookmarkLoad(bookmarkPublisher)
        updateBookmarkedStateOnBookmarkLoad(bookmarkPublisher)

        bookmarkPublisher
            .connect()
            .store(in: &subscriptions)
    }

    private func saveBookmarkIdOnBookmarkLoad(_ bookmarkLoad: some Publisher<BookmarksInteractor.BookmarkID?, Never>) {
        bookmarkLoad
            .assign(to: \.existingBookmarkId, on: self, ownership: .weak)
            .store(in: &subscriptions)
    }

    private func updateBookmarkedStateOnBookmarkLoad(_ bookmarkLoad: some Publisher<BookmarksInteractor.BookmarkID?, Never>) {
        bookmarkLoad
            .map { $0 == nil ? false : true }
            .assign(to: &$isBookmarked)
    }

    private func showSnackbarOnBookmarkDelete() {
        bookmarkDeleted
            .sink { [snackBarViewModel] _ in
                snackBarViewModel?.showSnack(NSLocalizedString("Bookmark deleted", comment: ""))
            }
            .store(in: &subscriptions)
    }

    private func resetStoredBookmarkIdOnBookmarkDelete() {
        bookmarkDeleted
            .mapToValue(nil)
            .assign(to: \.existingBookmarkId, on: self, ownership: .weak)
            .store(in: &subscriptions)
    }

    private func updateBookmarkedStateOnBookmarkDelete() {
        bookmarkDeleted
            .mapToValue(false)
            .assign(to: &$isBookmarked)
    }

    private func showSnackbarOnNewBookmark() {
        bookmarkAdded
            .sink { [snackBarViewModel] _ in
                snackBarViewModel?.showSnack(NSLocalizedString("Bookmark added", comment: ""))
            }
            .store(in: &subscriptions)
    }

    private func saveBookmarkIdOnNewBookmark() {
        bookmarkAdded
            .mapToOptional()
            .assign(to: \.existingBookmarkId, on: self, ownership: .weak)
            .store(in: &subscriptions)
    }

    private func updateBookmarkedStateOnNewBookmark() {
        bookmarkAdded
            .mapToValue(true)
            .assign(to: &$isBookmarked)
    }
}
