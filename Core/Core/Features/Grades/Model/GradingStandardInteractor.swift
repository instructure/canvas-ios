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
    private let courseId: String
    private let gradingStandardId: String?
    private let env: AppEnvironment

    public init(courseId: String, gradingStandardId: String? = nil, env: AppEnvironment? = nil) {
        self.courseId = courseId
        self.gradingStandardId = gradingStandardId
        self.env = env ?? AppEnvironment.shared
    }

    public var gradingScheme: AnyPublisher<GradingScheme?, Never> {
        if gradingStandardId != nil {
            getGradingScheme()
        } else {
            getCourseGradingScheme()
        }
    }

    private func getGradingScheme() -> AnyPublisher<GradingScheme?, Never> {
        Publishers.CombineLatest(
            getAccountLevelGradingScheme(),
            getCourseLevelGradingScheme()
        )
        .map { $0 ?? $1 }
        .eraseToAnyPublisher()
    }

    private func getAccountLevelGradingScheme() -> AnyPublisher<GradingScheme?, Never> {
        guard let gradingStandardId else {
            return Just(nil).eraseToAnyPublisher()
        }

        let gradingStandardStore = ReactiveStore(
            useCase: GetGradingStandard(id: gradingStandardId),
            environment: env
        )

        return gradingStandardStore
            .getEntities()
            .map {
                guard let gradingStandard = $0.first else {
                    return nil
                }
                if gradingStandard.isPointsBased {
                    return PointsBasedGradingScheme(
                        entries: gradingStandard.gradingSchemeEntries,
                        scaleFactor: gradingStandard.scalingFactor
                    )
                } else {
                    return PercentageBasedGradingScheme(
                        entries: gradingStandard.gradingSchemeEntries
                    )
                }
            }
            .replaceError(with: nil)
            .eraseToAnyPublisher()
    }

    private func getCourseLevelGradingScheme() -> AnyPublisher<GradingScheme?, Never> {
        guard let gradingStandardId else {
            return Just(nil).eraseToAnyPublisher()
        }

        let gradingStandardStore = ReactiveStore(
            useCase: GetGradingStandard(id: gradingStandardId, courseId: courseId),
            environment: env
        )

        return gradingStandardStore
            .getEntities()
            .map {
                guard let gradingStandard = $0.first else {
                    return nil
                }
                if gradingStandard.isPointsBased {
                    return PointsBasedGradingScheme(
                        entries: gradingStandard.gradingSchemeEntries,
                        scaleFactor: gradingStandard.scalingFactor
                    )
                } else {
                    return PercentageBasedGradingScheme(
                        entries: gradingStandard.gradingSchemeEntries
                    )
                }
            }
            .replaceError(with: nil)
            .eraseToAnyPublisher()
    }

    private func getCourseGradingScheme() -> AnyPublisher<GradingScheme?, Never> {
        let courseStore = ReactiveStore(
            useCase: GetCourseWithGradingScheme(courseId: courseId),
            environment: env
        )

        return courseStore
            .getEntities()
            .compactMap(\.first)
            .map(\.gradingScheme)
            .ignoreFailure()
            .eraseToAnyPublisher()
    }
}

// Mock

public final class GradingStandardInteractorMock: GradingStandardInteractor {
    public var gradingScheme: AnyPublisher<GradingScheme?, Never> {
        Just(nil)
            .eraseToAnyPublisher()
    }
}
