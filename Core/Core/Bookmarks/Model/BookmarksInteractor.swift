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

public protocol BookmarksInteractor {
    func getBookmarks() -> AnyPublisher<[BookmarkItem], Error>
    func addBookmark(title: String, route: String) -> AnyPublisher<Void, Error>
    func deleteBookmark(id: String) -> AnyPublisher<Void, Error>
}

struct BookmarksInteractorLive: BookmarksInteractor {
    private let api: API

    public init(api: API) {
        self.api = api
    }

    public func getBookmarks() -> AnyPublisher<[BookmarkItem], Error> {
        ReactiveStore(useCase: GetBookmarks())
            .getEntities()
            .eraseToAnyPublisher()
    }

    public func addBookmark(title: String, route: String) -> AnyPublisher<Void, Error> {
        let bookmark = APIBookmark(name: title, url: route)
        let request = CreateBookmarkRequest(body: bookmark)

        return api.makeRequest(request)
            .flatMap { _ in self.getBookmarks() }
            .mapToVoid()
            .eraseToAnyPublisher()
    }

    public func deleteBookmark(id: String) -> AnyPublisher<Void, Error> {
        let request = DeleteBookmarkRequest(id: id)
        return api.makeRequest(request)
            .mapToVoid()
            .eraseToAnyPublisher()
    }
}
