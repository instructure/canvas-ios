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

public class DashboardCourseCardListViewModel: ObservableObject {
    // MARK: - Dependencies

    private let interactor: DashboardCourseCardListInteractor

    // MARK: - Outputs

    @Published public private(set) var shouldShowSettingsButton = false
    @Published public private(set) var courseCardList = [DashboardCard]()
    @Published public private(set) var state = StoreState.loading

    // MARK: - Private properties

    private var subscriptions = Set<AnyCancellable>()

    // MARK: - Init

    public init(_ interactor: DashboardCourseCardListInteractor) {
        self.interactor = interactor

        NotificationCenter.default.publisher(for: .favoritesDidChange)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.refresh() }
            .store(in: &subscriptions)

        interactor.state
            .assign(to: &$state)

        interactor.courseCardList
            .assign(to: &$courseCardList)

        interactor.courseCardList
            .map { !$0.isEmpty }
            .assign(to: &$shouldShowSettingsButton)
    }

    public func refresh(onComplete: (() -> Void)? = nil) {
        interactor
            .refresh()
            .sink { _ in
                onComplete?()
            }
            .store(in: &subscriptions)
    }
}
