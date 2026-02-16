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

import Core
import CoreData
import Combine

final class LearningLibraryItemUseCase: APIUseCase {
    public typealias Model = CDHLearningLibraryCollectionItem

    // MARK: - Properties

    private var subscriptions = Set<AnyCancellable>()
    public var cacheKey: String? { "Learning-Library-Items" }
    public var request: GetHLearningLibraryItemRequest { GetHLearningLibraryItemRequest() }
    var scope: Scope { .all }

    // MARK: - Dependencies

    private let journey: DomainServiceProtocol

    // MARK: - Init

    init(journey: DomainServiceProtocol = DomainService()) {
        self.journey = journey
    }

    func write(
        response: [LearningLibraryItemsResponse]?,
        urlResponse: URLResponse?,
        to client: NSManagedObjectContext
    ) {
        let items = response ?? []
        items.forEach {
            CDHLearningLibraryCollectionItem.save($0, in: client)
        }
    }

    public func makeRequest(
        environment: AppEnvironment,
        completionHandler: @escaping ([LearningLibraryItemsResponse]?, URLResponse?, Error?) -> Void
    ) {
        journey
            .api()
            .sinkFailureOrValue(receiveFailure: { error in
                completionHandler(nil, nil, error)
            }, receiveValue: { [weak self] api in
                guard let self = self else { return }
                api.exhaust(self.request, callback: completionHandler)
            })
            .store(in: &subscriptions)
    }
}
