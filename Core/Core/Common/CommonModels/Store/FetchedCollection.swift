//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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

public class FetchedCollection<Request: APIRequestable, Element: Decodable> {

    public var hasNext: Bool { next != nil }

    private var transform: (Request.Response) -> [Element]
    private var collected: [Element] = []
    private var next: GetNextRequest<Request.Response>?

    private var subscriptions = Set<AnyCancellable>()
    private let env = AppEnvironment.shared

    public init(
        ofRequest request: Request.Type = Request.self,
        transform: @escaping (Request.Response) -> [Element]
    ) {
        self.transform = transform
    }

    public func fetch(_ request: Request) -> AnyPublisher<[Element], Never> {
        self.next = nil
        self.collected = []

        return env
            .api
            .makeRequest(request)
            .map({ [weak self] response in
                guard let self else { return [] }

                if let urlResponse = response.urlResponse {
                    next = request.getNext(from: urlResponse)
                }

                let newList = transform(response.body)
                collected = newList

                return newList
            })
            .replaceError(with: [] as [Element])
            .eraseToAnyPublisher()
    }

    public func fetchNext() -> AnyPublisher<[Element], Never> {
        guard let request = next else {
            return Just(collected).eraseToAnyPublisher()
        }

        return env
            .api
            .makeRequest(request)
            .map({ [weak self] response in
                guard let self else { return [] }
                if let urlResponse = response.urlResponse {
                    next = request.getNext(from: urlResponse)
                }
                return transform(response.body)
            })
            .replaceError(with: [] as [Element])
            .map { [weak self] newElements in
                guard let self else { return newElements }
                let newList = collected + newElements
                collected = newList
                return newList
            }
            .eraseToAnyPublisher()
    }
}
