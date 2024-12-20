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
import Foundation

public class AssignmentDueDatesInteractorLive: AssignmentDueDatesInteractor {
    // MARK: - Outputs
    public var state = CurrentValueSubject<StoreState, Never>(.loading)
    public var dueDates = CurrentValueSubject<[AssignmentDate], Never>([])

    // MARK: - Private
    private var subscriptions = Set<AnyCancellable>()
    private let assignmentStore: Store<GetAssignment>

    public init(env: AppEnvironment,
                courseID: String,
                assignmentID: String) {
        self.assignmentStore = env.subscribe(GetAssignment(courseID: courseID, assignmentID: assignmentID))

        assignmentStore.statePublisher
            .subscribe(state)
            .store(in: &subscriptions)

        assignmentStore.allObjects
            .map {
                if let dates = $0.first?.allDates {
                    return dates.sorted(by: { lhs, rhs in
                        switch (lhs.dueAt, rhs.dueAt) {
                        case let(ld?, rd?): return ld < rd
                        case (nil, _): return false
                        case (_?, nil): return true
                        }
                    })
                } else {
                    return []
                }
            }
            .subscribe(dueDates)
            .store(in: &subscriptions)

        assignmentStore.refresh()
    }
}
