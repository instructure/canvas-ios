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
import Core
import Foundation

protocol LearningLibraryInteractor {
    func getLearnLibraryCollections(ignoreCache: Bool) -> AnyPublisher<[LearningLibrarySectionModel], Error>
    func getBookmarkedItems(ignoreCache: Bool) -> AnyPublisher<[LearningLibraryCardModel], Error>
    func bookmark(id: String, courseID: String) -> AnyPublisher<LearningLibraryCardModel?, Error>
    func enroll(id: String, courseID: String) -> AnyPublisher<LearningLibraryCardModel, Error>
    func getCollectionItems(id: String, ignoreCache: Bool) -> AnyPublisher<[LearningLibraryCardModel], Error>
    func getRecommendations(ignoreCache: Bool) -> AnyPublisher<[LearningLibraryCardModel], Error>
    func searchCollectionItem(
        bookmarkedOnly: Bool,
        completedOnly: Bool,
        types: [String]?,
        searchTerm: String?
    ) -> AnyPublisher<[LearningLibraryCardModel], Error>
    func searchWithFilters(
        searchText: String?,
        objectType: LearningLibraryObjectType?,
        libraryFilter: LearningLibraryFilter
    ) -> AnyPublisher<[LearningLibraryCardModel], Error>
}

final class LearningLibraryInteractorLive: LearningLibraryInteractor {
    // MARK: - Dependencies

    private let domainService: DomainServiceProtocol

    // MARK: - Init

    init(domainService: DomainServiceProtocol =  DomainService()) {
        self.domainService = domainService
    }

    func getLearnLibraryCollections(ignoreCache: Bool) -> AnyPublisher<[LearningLibrarySectionModel], Error> {
        ReactiveStore(useCase: LearningLibraryCollectionUseCase(journey: domainService))
            .getEntities(ignoreCache: ignoreCache)
            .map { collections in
                let isSingleCollection = collections.count == 1
                let itemLimit = isSingleCollection ? 4 : 2
                return collections.map { collection in
                    let sortedItems = collection.items.sorted {
                        ($0.name) < ($1.name)
                    }
                    let limitedItems = Array(sortedItems.prefix(itemLimit))
                    return LearningLibrarySectionModel(
                        for: collection,
                        hasMoreItems: Int(collection.totalItemCount).defaultToZero > itemLimit,
                        items: limitedItems
                    )
                }
            }
            .eraseToAnyPublisher()
    }

    func getBookmarkedItems(ignoreCache: Bool) -> AnyPublisher<[LearningLibraryCardModel], Error> {
        ReactiveStore(useCase: GetCollectionItemBookmarkedUseCase(journey: domainService))
            .getEntities(ignoreCache: ignoreCache)
            .map { items in
                items.map { LearningLibraryCardModel(for: $0) }
                    .removingDuplicates(by: \.courseID)
            }
            .eraseToAnyPublisher()
    }

    func searchCollectionItem(
        bookmarkedOnly: Bool,
        completedOnly: Bool,
        types: [String]?,
        searchTerm: String?
    ) -> AnyPublisher<[LearningLibraryCardModel], Error> {
        let request = GetHLearningLibraryItemRequest(
            bookmarkedOnly: bookmarkedOnly,
            completedOnly: completedOnly,
            searchTerm: searchTerm,
            types: types
        )
        return domainService.api()
            .flatMap { api in
                api.exhaust(request)
            }
            .map(\.body)
            .map { items in
                items.map { LearningLibraryCardModel(for: $0) }
                    .removingDuplicates(by: \.courseID)
            }
            .eraseToAnyPublisher()
    }

    func getCollectionItems(id: String, ignoreCache: Bool) -> AnyPublisher<[LearningLibraryCardModel], Error> {
        ReactiveStore(useCase: LearningLibraryCollectionItemUseCase(id: id, journey: domainService))
            .getEntities(ignoreCache: ignoreCache)
            .map { items in
                items.map { LearningLibraryCardModel(for: $0) }
            }
            .eraseToAnyPublisher()
    }

    func bookmark(id: String, courseID: String) -> AnyPublisher<LearningLibraryCardModel?, Error> {
        ReactiveStore(useCase: LearningLibraryBookMarkUseCase(journey: domainService, id: id, courseID: courseID))
            .getEntities()
            .map { entities in
                entities.first.map { LearningLibraryCardModel(for: $0) }
            }
            .eraseToAnyPublisher()
    }

    func enroll(id: String, courseID: String) -> AnyPublisher<LearningLibraryCardModel, Error> {
        ReactiveStore(useCase: LearningLibraryEnrollUseCase(journey: domainService, id: id, courseID: courseID))
            .getEntities(ignoreCache: true)
            .compactMap { $0.first }
            .map { LearningLibraryCardModel(for: $0) }
            .eraseToAnyPublisher()
    }

    func searchWithFilters(
        searchText: String?,
        objectType: LearningLibraryObjectType?,
        libraryFilter: LearningLibraryFilter
    ) -> AnyPublisher<[LearningLibraryCardModel], Error> {
        let bookmarkedOnly = libraryFilter == .bookmarked
        let completedOnly = libraryFilter == .completed

        let types: [String]?
        if let objectType = objectType {
            types = [objectType.rawValue]
        } else {
            types = nil
        }

        let trimmedSearchText = searchText?.trimmingCharacters(in: .whitespacesAndNewlines)
        let searchTerm = trimmedSearchText?.isEmpty == false ? trimmedSearchText : nil

        return searchCollectionItem(
            bookmarkedOnly: bookmarkedOnly,
            completedOnly: completedOnly,
            types: types,
            searchTerm: searchTerm
        )
    }

    func getRecommendations(ignoreCache: Bool) -> AnyPublisher<[LearningLibraryCardModel], Error> {
        ReactiveStore(useCase: LearningLibraryRecommendationUseCase(journey: domainService))
            .getEntities(ignoreCache: ignoreCache)
            .map { items in
                items.map { LearningLibraryCardModel(for: $0) }
            }
            .eraseToAnyPublisher()
    }
}

extension Sequence {
    func removingDuplicates<T: Hashable>(by keyPath: KeyPath<Element, T>) -> [Element] {
        var seen = Set<T>()
        return filter { seen.insert($0[keyPath: keyPath]).inserted }
    }
}
