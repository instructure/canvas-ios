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
import CombineSchedulers
import Foundation

public protocol ExperienceSummaryInteractor {
    func getExperienceSummary() -> AnyPublisher<Experience, Error>
    func isExperienceSwitchAvailable() -> AnyPublisher<Bool, Never>
    func switchExperience(to experience: Experience) -> AnyPublisher<Void, Never>
}

public final class ExperienceSummaryInteractorLive: ExperienceSummaryInteractor {
    private let environment: AppEnvironment
    private let scheduler: AnySchedulerOf<DispatchQueue>

    public init(
        environment: AppEnvironment = AppEnvironment.shared,
        scheduler: AnySchedulerOf<DispatchQueue> = .main
    ) {
        self.environment = environment
        self.scheduler = scheduler
    }

    public func getExperienceSummary() -> AnyPublisher<Experience, Error> {
        if let experience = environment.userDefaults?.appExperience {
            return Just(experience)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }

        unowned let unownedSelf = self

        return ReactiveStore(useCase: GetExperienceSummaryUseCase())
            .getEntities(ignoreCache: true)
            .compactMap { $0.first }
            .map { $0.currentApp }
            .map {
                unownedSelf.environment.userDefaults?.appExperience = $0
                return $0
            }
            .eraseToAnyPublisher()
    }

    public func isExperienceSwitchAvailable() -> AnyPublisher<Bool, Never> {
        ReactiveStore(useCase: GetExperienceSummaryUseCase())
            .getEntities()
            .compactMap { $0.first?.availableApps }
            .map { $0.contains(.academic) && $0.contains(.careerLearner) }
            .replaceError(with: false)
            .eraseToAnyPublisher()
    }

    public func isExperienceSwitchAvailable() async -> Bool {
        await isExperienceSwitchAvailable()
            .values
            .first(where: { _ in true })!
    }

    public func switchExperience(to experience: Experience) -> AnyPublisher<Void, Never> {
        environment.userDefaults?.appExperience = experience

        return Just(())
            .delay(for: .seconds(1), scheduler: scheduler)
            .eraseToAnyPublisher()
    }
}
