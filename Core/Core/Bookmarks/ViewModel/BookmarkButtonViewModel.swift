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

class BookmarkButtonViewModel: ObservableObject {
    @Published public var isShowingConfirmationDialog = false
    public let confirmAddDialog = ConfirmationAlertViewModel(
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
    private let bookmarksInteractor: BookmarksInteractor
    private let title: String
    private let route: String
    private var createBookmarkSubscription: AnyCancellable?

    public init(bookmarksInteractor: BookmarksInteractor,
                title: String,
                route: String) {
        self.bookmarksInteractor = bookmarksInteractor
        self.title = title
        self.route = route
    }

    public func bookmarkButtonDidTap() {
        isShowingConfirmationDialog = true
        createBookmarkSubscription = confirmAddDialog
            .userConfirmation()
            .flatMap { [bookmarksInteractor, title, route] in
                bookmarksInteractor
                    .addBookmark(title: title, route: route)
            }
            .sink()
    }
}
