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

import Foundation
import Combine
import CombineExt

class InboxCoursePickerInteractorLive: InboxCoursePickerInteractor {
    // MARK: - Outputs
    public var state = CurrentValueSubject<StoreState, Never>(.loading)
    public var favoriteCourses = CurrentValueSubject<[Course], Never>([])
    public var moreCourses = CurrentValueSubject<[Course], Never>([])
    public var groups = CurrentValueSubject<[Group], Never>([])

    // MARK: - Private
    private var subscriptions = Set<AnyCancellable>()
    private let courseListStore: Store<GetCourses>
    private let groupListStore: Store<GetGroups>

    public init(env: AppEnvironment) {
        self.courseListStore = env.subscribe(GetCourses())
        self.groupListStore = env.subscribe(GetGroups())

        StoreState.combineLatest(courseListStore.statePublisher, groupListStore.statePublisher)
            .subscribe(state)
            .store(in: &subscriptions)

        let courseObjects = courseListStore.allObjects
        
        // FIXME: this is not the correct way
        courseObjects
            .filterMany { $0.isFavorite }
            .subscribe(favoriteCourses)
            .store(in: &subscriptions)
        
        courseObjects
            .filterMany { !$0.isFavorite }
            .subscribe(moreCourses)
            .store(in: &subscriptions)
        courseListStore.exhaust()

        groupListStore
            .allObjects
            .subscribe(groups)
            .store(in: &subscriptions)
        groupListStore.exhaust()
    }

    // MARK: - Inputs
    public func refresh() -> AnyPublisher<[Void], Never> {
        courseListStore.refreshWithFuture(force: true).combineLatest(with: groupListStore.refreshWithFuture(force: true))
    }
}
