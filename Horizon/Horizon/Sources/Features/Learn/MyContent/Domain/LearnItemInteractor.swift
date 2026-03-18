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
import Combine
import Foundation

protocol LearnItemInteractor {
    func getItems(
        searchTerm: String?,
        itemTypes: [String]?,
        sortBy: String?,
        status: [LearnItemModel.Status]
    ) -> AnyPublisher<[LearnItemModel], Error>
}

final class LearnItemInteractorLive: LearnItemInteractor {
    // MARK: - Dependencies

    private let domainService: DomainServiceProtocol

    // MARK: - Init

    init(domainService: DomainServiceProtocol =  DomainService()) {
        self.domainService = domainService
    }

    func getItems(
        searchTerm: String?,
        itemTypes: [String]?,
        sortBy: String?,
        status: [LearnItemModel.Status]
    ) -> AnyPublisher<[LearnItemModel],Error> {
        domainService.api()
            .flatMap { api in
                api
                    .exhaust(
                        GetLearnItemsRequest(
                            searchTerm: searchTerm,
                            itemTypes: itemTypes,
                            sortBy: sortBy,
                            status: status.map { $0.rawValue }
                        )
                    )
            }
            .map(\.body)
            .map { items in
                items
                    .map { LearnItemModel(item: $0) }
                    .sorted { $0.position < $1.position }
            }
            .eraseToAnyPublisher()
    }
}
