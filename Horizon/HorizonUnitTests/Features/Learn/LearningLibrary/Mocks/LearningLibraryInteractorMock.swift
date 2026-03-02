//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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
import Foundation
@testable import Horizon

final class LearningLibraryInteractorMock: LearningLibraryInteractor {
    private let collectionsResponse: [LearningLibrarySectionModel]
    private let bookmarkedItemsResponse: [LearningLibraryCardModel]
    private let searchResponse: [LearningLibraryCardModel]
    private let collectionItemsResponse: [LearningLibraryCardModel]
    private let bookmarkResponse: LearningLibraryCardModel?
    private let enrollResponse: LearningLibraryCardModel?
    private let hasError: Bool

    init(
        collections: [LearningLibrarySectionModel] = [],
        bookmarkedItems: [LearningLibraryCardModel] = [],
        searchResponse: [LearningLibraryCardModel] = [],
        collectionItems: [LearningLibraryCardModel] = [],
        bookmarkResponse: LearningLibraryCardModel? = nil,
        enrollResponse: LearningLibraryCardModel? = nil,
        hasError: Bool = false
    ) {
        self.collectionsResponse = collections
        self.bookmarkedItemsResponse = bookmarkedItems
        self.searchResponse = searchResponse
        self.collectionItemsResponse = collectionItems
        self.bookmarkResponse = bookmarkResponse
        self.enrollResponse = enrollResponse
        self.hasError = hasError
    }

    func getLearnLibraryCollections(ignoreCache: Bool) -> AnyPublisher<[LearningLibrarySectionModel], Error> {
        if hasError {
            return Fail(error: URLError(.badServerResponse)).eraseToAnyPublisher()
        } else {
            return Just(collectionsResponse)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
    }

    func getBookmarkedItems(ignoreCache: Bool) -> AnyPublisher<[LearningLibraryCardModel], Error> {
        if hasError {
            return Fail(error: URLError(.badServerResponse)).eraseToAnyPublisher()
        } else {
            return Just(bookmarkedItemsResponse)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
    }

    func bookmark(id: String, itemID: String) -> AnyPublisher<LearningLibraryCardModel, Error> {
        if hasError {
            return Fail(error: URLError(.badServerResponse)).eraseToAnyPublisher()
        } else if let response = bookmarkResponse {
            return Just(response)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        } else {
            return Fail(error: URLError(.badServerResponse)).eraseToAnyPublisher()
        }
    }

    func enroll(id: String, itemID: String) -> AnyPublisher<LearningLibraryCardModel, Error> {
        if hasError {
            return Fail(error: URLError(.badServerResponse)).eraseToAnyPublisher()
        } else if let response = enrollResponse {
            return Just(response)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        } else {
            return Fail(error: URLError(.badServerResponse)).eraseToAnyPublisher()
        }
    }

    func getCollectionItems(id: String, ignoreCache: Bool) -> AnyPublisher<[LearningLibraryCardModel], Error> {
        if hasError {
            return Fail(error: URLError(.badServerResponse)).eraseToAnyPublisher()
        } else {
            return Just(collectionItemsResponse)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
    }

    func searchCollectionItem(
        bookmarkedOnly: Bool,
        completedOnly: Bool,
        types: [String]?,
        searchTerm: String?
    ) -> AnyPublisher<[LearningLibraryCardModel], Error> {
        if hasError {
            return Fail(error: URLError(.badServerResponse)).eraseToAnyPublisher()
        } else {
            return Just(searchResponse)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
    }
}
