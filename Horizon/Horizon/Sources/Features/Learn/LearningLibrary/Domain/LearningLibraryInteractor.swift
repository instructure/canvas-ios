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
    func getLearnLibraryItems(ignoreCache: Bool) -> AnyPublisher<[LearningLibraryCardModel], Error>
    func bookmark(id: String) -> AnyPublisher<LearningLibraryCardModel, Error>
    func enroll(id: String) -> AnyPublisher<LearningLibraryCardModel, Error>
}

final class LearningLibraryInteractorLive: LearningLibraryInteractor {
    // MARK: - Dependencies

    private let domainService: DomainService

    // MARK: - Init

    init(domainService: DomainService = .init()) {
        self.domainService = domainService
    }

    func getLearnLibraryCollections(ignoreCache: Bool) -> AnyPublisher<[LearningLibrarySectionModel], Error> {
        ReactiveStore(useCase: LearningLibraryCollectionUseCase(journey: domainService))
            .getEntities(ignoreCache: ignoreCache)
            .map { collections in
                let isSingleCollection = collections.count == 1
                let itemLimit = isSingleCollection ? 4 : 2
                return collections.map { collection in
                    let limitedItems = Array(collection.items.prefix(itemLimit))
                    return LearningLibrarySectionModel(
                        for: collection,
                        hasMoreItems: collection.items.count >= itemLimit,
                        items: limitedItems
                    )
                }
            }
            .eraseToAnyPublisher()
    }

    func getLearnLibraryItems(ignoreCache: Bool) -> AnyPublisher<[LearningLibraryCardModel], Error> {
        ReactiveStore(useCase: LearningLibraryItemUseCase(journey: domainService))
            .getEntities(ignoreCache: ignoreCache)
            .map { items in
                items.map { LearningLibraryCardModel(for: $0) }
            }
            .eraseToAnyPublisher()
    }

    func bookmark(id: String) -> AnyPublisher<LearningLibraryCardModel, Error> {
        ReactiveStore(useCase: LearningLibraryBookMarkUseCase(journey: domainService, id: id))
            .getEntities()
            .compactMap { $0.first }
            .map { LearningLibraryCardModel(for: $0) }
            .eraseToAnyPublisher()
    }

    func enroll(id: String) -> AnyPublisher<LearningLibraryCardModel, Error> {
        ReactiveStore(useCase: LearningLibraryEnrollUseCase(journey: domainService, id: id))
            .getEntities()
            .compactMap { $0.first }
            .map { LearningLibraryCardModel(for: $0) }
            .eraseToAnyPublisher()
    }
}
