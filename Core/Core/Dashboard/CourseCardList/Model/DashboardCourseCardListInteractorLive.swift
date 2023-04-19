//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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

public class DashboardCourseCardListInteractorLive: DashboardCourseCardListInteractor {
    // MARK: - Outputs

    public let state = CurrentValueSubject<StoreState, Never>(.loading)
    public let courseCardList: CurrentValueSubject<[DashboardCard], Never> = .init([])

    // MARK: - Private State

    private let courseCardListStore: Store<GetDashboardCards>
    private let courseListStore: Store<GetDashboardCourses>

    private var subscriptions = Set<AnyCancellable>()

    public required init(env: AppEnvironment = .shared, showOnlyTeacherEnrollment: Bool) {
        courseCardListStore = env.subscribe(GetDashboardCards(showOnlyTeacherEnrollment: showOnlyTeacherEnrollment))
        courseListStore = env.subscribe(GetDashboardCourses())

        Publishers.CombineLatest(
            courseCardListStore.allObjects,
            courseListStore.allObjects
        )
        .map { $0.0 }
        .subscribe(courseCardList)
        .store(in: &subscriptions)

        StoreState.combineLatest(
            courseCardListStore.statePublisher,
            courseListStore.statePublisher
        )
        .subscribe(state)
        .store(in: &subscriptions)

        courseCardListStore.exhaust()
        courseListStore.exhaust()
    }

    // MARK: - Inputs

    public func refresh() -> Future<Void, Never> {
        Future { [weak self] promise in
            guard let self else {
                return promise(.success(()))
            }
            Publishers
                .CombineLatest4(
                    self.courseCardListStore.refreshWithFuture(force: true),
                    self.courseCardListStore.exhaustWithFuture(),
                    self.courseListStore.refreshWithFuture(force: true),
                    self.courseListStore.exhaustWithFuture()
                )
                .sink { _ in
                    promise(.success(()))
                }
                .store(in: &self.subscriptions)
        }
    }
}
