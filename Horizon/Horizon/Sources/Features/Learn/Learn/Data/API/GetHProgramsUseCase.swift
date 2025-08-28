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

import CoreData
import Combine
import Core

final public class GetHProgramsUseCase: APIUseCase {

    private let journey = DomainService(.journey)
    public typealias Model = CDHProgram
    private var subscriptions = Set<AnyCancellable>()
    public var request: GetHProgramsRequest {
        return GetHProgramsRequest()
    }

    public var cacheKey: String? { "get-programs" }

    public func write(
        response: GetHProgramsResponse?,
        urlResponse _: URLResponse?,
        to client: NSManagedObjectContext
    ) {
        let programs = response?.data?.enrolledPrograms ?? []
        let sortedPrograms = normalizePrograms(programs)
        sortedPrograms.forEach { program in
            CDHProgram.save(program, in: client)
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

    private func normalizePrograms(_ programs: [GetHProgramsResponse.EnrolledProgram]) -> [GetHProgramsResponse.EnrolledProgram] {
        programs.map { program in
            var copy = program
            copy.requirements = sortRequirementsByDependency(copy.requirements ?? [])
            return copy
        }
    }

    private func sortRequirementsByDependency(_ requirements: [GetHProgramsResponse.Requirement]) -> [GetHProgramsResponse.Requirement] {
        guard let start = requirements.first(where: { $0.dependency == nil }) else {
            return requirements
        }
        var position = 1
        var sorted: [GetHProgramsResponse.Requirement] = [start]
        var current = start

        while let nextId = current.dependent?.id,
              var next = requirements.first(where: { $0.dependency?.id == nextId }) {
            next.position = position
            position += 1
            sorted.append(next)
            current = next
        }
        return sorted
    }
}
