//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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
import CoreData
import Foundation

final class GetHSkillsUseCase: APIUseCase {
    private let journey: DomainServiceProtocol
    public typealias Model = CDHSkill
    private var subscriptions = Set<AnyCancellable>()
    public var cacheKey: String? { "get-skills" }
    public var request: GetHSkillRequest {
        return GetHSkillRequest()
    }

    init(journey: DomainServiceProtocol = DomainService(.journey)) {
        self.journey = journey

    }

    public func write(
        response: GetHSkillResponse?,
        urlResponse _: URLResponse?,
        to client: NSManagedObjectContext
    ) {
        let skills = response?.data?.skills ?? []
        skills.forEach { skill in
            CDHSkill.save(skill, in: client)
        }
    }

    public func makeRequest(
        environment: AppEnvironment,
        completionHandler: @escaping (Response?, URLResponse?, Error?) -> Void
    ) {
        journey
            .api()
            .sinkFailureOrValue(receiveFailure: { error in
                completionHandler(nil, nil, error)
            }, receiveValue: { [weak self] api in
                guard let self = self else { return }
                api.makeRequest(self.request, callback: completionHandler)
            })
            .store(in: &subscriptions)
    }

    var scope: Scope {
        let titleSortDescriptor = NSSortDescriptor(key: #keyPath(CDHSkill.name), ascending: true)
        return Scope(predicate: .all, order: [titleSortDescriptor], sectionNameKeyPath: nil)
    }
}
