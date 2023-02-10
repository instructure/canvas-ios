//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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
import SwiftUI

public class CourseListViewModel: ObservableObject {
    // MARK: - Outputs
    @Published public private(set) var sections: CourseListSections = CourseListSections()
    @Published public private(set) var state = StoreState.loading

    // MARK: - Inputs
    public let filter = CurrentValueSubject<String, Never>("")

    // MARK: - Private State
    private let interactor: CourseListInteractor
    private var subscriptions = Set<AnyCancellable>()

    public init(_ interactor: CourseListInteractor) {
        self.interactor = interactor

        interactor
            .state
            .assign(to: &$state)
        interactor
            .courseList
            .assign(to: &$sections)
        filter
            .map { interactor.setFilter($0) }
            .sink()
            .store(in: &subscriptions)
    }

    public func refresh(completion: @escaping () -> Void) {
        interactor
            .refresh()
            .sink { _ in
                completion()
            }
            .store(in: &subscriptions)
    }
}
