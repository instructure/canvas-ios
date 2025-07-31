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
import Foundation

public protocol GradingStandardInteractor {
    var contextId: String { get }
    var contextType: String { get }
    var gradingStandardId: String { get }

    func getGradingScheme() -> AnyPublisher<GradingScheme, Error>
}

public final class GradingStandardInteractorLive: GradingStandardInteractor {
    public let contextId: String
    public let contextType: String
    public let gradingStandardId: String
    public let env: AppEnvironment

    public init(contextId: String, contextType: String, gradingStandardId: String, env: AppEnvironment) {
        self.contextId = contextId
        self.contextType = contextType
        self.gradingStandardId = gradingStandardId
        self.env = env
    }

    public func getGradingScheme() -> AnyPublisher<any GradingScheme, any Error> {
        let gradingStandardStore = ReactiveStore(
            useCase: GetGradingStandard(gradingStandardId: gradingStandardId, contextId: contextId, contextType: contextType),
            environment: env
        )
        return gradingStandardStore
            .getEntities()
            .map {
                guard let gradingStandard = $0.first,
                      let entries = try? JSONDecoder().decode([GradingSchemeEntry].self, from: gradingStandard.gradingScheme!) else {
                    fatalError()
                }
                if gradingStandard.pointsBased {
                    return PointsBasedGradingScheme(scaleFactor: gradingStandard.scalingFactor, entries: entries)
                } else {
                    return PercentageBasedGradingScheme(entries: entries)
                }
            }
            .eraseToAnyPublisher()
    }
}
