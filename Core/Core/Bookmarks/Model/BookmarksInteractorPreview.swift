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
import CoreData

struct BookmarksInteractorPreview: BookmarksInteractor {
    public enum MockState: Equatable {
        case loading
        case data
        case empty
    }

    private let mockState: MockState
    private let items: [BookmarkItem]

    public init(mockState: MockState, context: NSManagedObjectContext) {
        self.mockState = mockState

        let item = context.insert() as BookmarkItem
        item.id = "0"
        item.name = "My bookmark"
        item.url = ""
        let item1 = context.insert() as BookmarkItem
        item1.id = "1"
        item1.name = "My bookmark 1"
        item1.url = ""

        self.items = [item, item1]
    }

    func getBookmarks() -> AnyPublisher<[BookmarkItem], Error> {
        switch mockState {
        case .loading:
            return Empty()
                .eraseToAnyPublisher()
        case .data:
            return Just(items)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        case .empty:
            return Just([])
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
    }

    func addBookmark(title: String, route: String) -> AnyPublisher<BookmarkID, Error> {
        Just("")
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func deleteBookmark(id: String) -> AnyPublisher<Void, Error> {
        Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func getBookmark(for route: String) -> AnyPublisher<BookmarkItem?, Never> {
        Just(nil)
            .eraseToAnyPublisher()
    }
}
