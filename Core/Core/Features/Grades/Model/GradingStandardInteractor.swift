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
    var gradingScheme: AnyPublisher<GradingScheme?, Never> { get }
}

public final class GradingStandardInteractorLive: GradingStandardInteractor {
    private let context: Context
    private let gradingStandardId: String?
    private let env: AppEnvironment

    public init(context: Context, gradingStandardId: String? = nil, env: AppEnvironment) {
        self.context = context
        self.gradingStandardId = gradingStandardId
        self.env = env
    }

    public var gradingScheme: AnyPublisher<GradingScheme?, Never> {
        guard let gradingStandardId else {
            return Just(nil)
                .eraseToAnyPublisher()
        }

        let gradingStandardStore = ReactiveStore(
            useCase: GetGradingStandard(id: gradingStandardId, context: context),
            environment: env
        )

        return gradingStandardStore
            .getEntities()
            .compactMap { $0.first }
            .map { gradingStandard in
                if gradingStandard.isPointsBased {
                    return PointsBasedGradingScheme(scaleFactor: gradingStandard.scalingFactor, entries: gradingStandard.gradingSchemeEntries)
                } else {
                    return PercentageBasedGradingScheme(entries: gradingStandard.gradingSchemeEntries)
                }
            }
            .ignoreFailure()
            .eraseToAnyPublisher()
    }
}
