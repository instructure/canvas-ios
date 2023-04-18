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

class AssignmentDueDatesViewModel: ObservableObject {
    // MARK: - Outputs
    @Published public private(set) var state: StoreState = .loading
    @Published public private(set) var dueDates: [AssignmentDueDateItemViewModel] = []
    public let title = NSLocalizedString("Due Dates", comment: "")

    // MARK: - Private
    private var subscriptions = Set<AnyCancellable>()
    private let interactor: AssignmentDueDatesInteractor

    public init(interactor: AssignmentDueDatesInteractor) {
        self.interactor = interactor

        interactor.state
            .assign(to: &$state)
        interactor.dueDates
            .map { dueDates in
                dueDates.map {
                    AssignmentDueDateItemViewModel(item: $0)
                }
            }
            .assign(to: &$dueDates)
    }
}
