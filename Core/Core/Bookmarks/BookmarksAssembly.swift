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

public enum BookmarksAssembly {

    public static func makeBookmarksInteractor(api: API = AppEnvironment.shared.api) -> BookmarksInteractor {
        BookmarksInteractorLive(api: api)
    }

    public static func makeShortcutsInteractor(environment: AppEnvironment = AppEnvironment.shared) -> ShortcutsInteractor? {
        guard environment.app == .student else { return nil }
        return ShortcutsInteractorLive(environment: environment)
    }

    public static func makeBookmarksViewController() -> UIViewController {
        let viewModel = BookmarksViewModel(interactor: makeBookmarksInteractor())
        let view = BookmarksView(viewModel: viewModel)
        return CoreHostingController(view)
    }

    static func makeBookmarkButtonViewModel(bookmarkTitle: String,
                                            bookmarkRoute: String,
                                            snackBarViewModel: SnackBarViewModel? = nil) -> BookmarkButtonViewModel {
        let interactor = makeBookmarksInteractor()
        return BookmarkButtonViewModel(bookmarksInteractor: interactor,
                                       title: bookmarkTitle,
                                       route: bookmarkRoute,
                                       snackBarViewModel: snackBarViewModel)
    }

    public static func makeBookmarkButtonView(bookmarkTitle: String,
                                              bookmarkRoute: String,
                                              snackBarViewModel: SnackBarViewModel? = nil) -> some View {
        let viewModel = makeBookmarkButtonViewModel(bookmarkTitle: bookmarkTitle,
                                                    bookmarkRoute: bookmarkRoute,
                                                    snackBarViewModel: snackBarViewModel)
        return BookmarkButtonView(viewModel: viewModel)
    }
}
