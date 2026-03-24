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

final class WeeklySummaryWidgetInteractorLive: WeeklySummaryWidgetInteractor {

    private let env: AppEnvironment

    init(env: AppEnvironment = .shared) {
        self.env = env
    }

    func clearCache() -> AnyPublisher<Void, Never> {
        ReactiveStore(useCase: ClearWeeklySummaryWidgetCache(), environment: env)
            .forceRefresh()
    }

    func hasCachedSummary(weekStart: Date) -> AnyPublisher<Bool, Never> {
        let missingUseCase = GetMissingWeeklySummaryEntries()
        let weeklyUseCase = GetWeeklyDueAndGradesEntries(weekStart: weekStart, studentId: env.currentSession?.userID ?? "")

        return Publishers.CombineLatest(
            missingUseCase.hasCacheExpired(environment: env),
            weeklyUseCase.hasCacheExpired(environment: env),
        )
        .map { !($0 || $1) }
        .eraseToAnyPublisher()
    }

    func getSummary(weekStart: Date, ignoreCache: Bool) -> AnyPublisher<WeeklySummaryWidgetFilters, Error> {
        let missingStore = ReactiveStore(useCase: GetMissingWeeklySummaryEntries(), environment: env)
        let weeklyStore = ReactiveStore(
            useCase: GetWeeklyDueAndGradesEntries(weekStart: weekStart, studentId: env.currentSession?.userID ?? ""),
            environment: env
        )
        return Publishers.CombineLatest(
            missingStore.getEntities(ignoreCache: ignoreCache),
            weeklyStore.getEntities(ignoreCache: ignoreCache)
        )
        .receive(on: DispatchQueue.main)
        .map { missingEntries, weekEntries -> WeeklySummaryWidgetFilters in
            WeeklySummaryWidgetFilters(
                missing: missingEntries.map { WeeklySummaryWidgetAssignment(entry: $0) },
                due: weekEntries.filter { $0.category == .due }.map { WeeklySummaryWidgetAssignment(entry: $0) },
                newGrades: weekEntries.filter { $0.category == .newGrades }.map { WeeklySummaryWidgetAssignment(entry: $0) }
            )
        }
        .eraseToAnyPublisher()
    }
}
