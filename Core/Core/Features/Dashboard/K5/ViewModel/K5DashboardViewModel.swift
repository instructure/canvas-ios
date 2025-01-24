//
// This file is part of Canvas.
// Copyright (C) 2021-present  Instructure, Inc.
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

public class K5DashboardViewModel: ObservableObject {
    @Published private(set) var topBarViewModel: TopBarViewModel

    let viewModels = (
        homeroom: K5HomeroomViewModel(),
        schedule: K5ScheduleViewModel(),
        grades: K5GradesViewModel(),
        resources: K5ResourcesViewModel(),
        importantDates: K5ImportantDatesViewModel()
    )

    private var subscriptions = Set<AnyCancellable>()

    init() {
        var topBarModelItems = [
            TopBarItemViewModel(id: "", icon: .k5homeroom, label: Text("Homeroom", bundle: .core)),
            TopBarItemViewModel(id: "/schedule", icon: .k5schedule, label: Text("Schedule", bundle: .core)),
            TopBarItemViewModel(id: "/grades", icon: .k5grades, label: Text("Grades", bundle: .core)),
            TopBarItemViewModel(id: "/resources", icon: .k5resources, label: Text("Resources", bundle: .core))
        ]

        if UIDevice.current.userInterfaceIdiom != .pad {
            topBarModelItems.append(TopBarItemViewModel(id: "/important_dates", icon: .k5importantDates, label: Text("Important Dates", bundle: .core)))
        }

        topBarViewModel = TopBarViewModel(items: topBarModelItems)
        setupScreenViewLogging()

        // Propagate changes of the underlying view model to this observable class because there's no native support for nested ObservableObjects
        topBarViewModel
            .objectWillChange.sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &subscriptions)
    }

    func profileButtonPressed(router: Router, viewController: WeakViewController) {
        router.route(to: "/profile", from: viewController, options: .modal())
    }

    private func setupScreenViewLogging() {
        topBarViewModel.selectedItemIndexPublisher
            .removeDuplicates()
            .compactMap { [weak self] index in self?.topBarViewModel.items[index].id }
            .sink { RemoteLogger.shared.logBreadcrumb(route: "/homeroom\($0)") }
            .store(in: &subscriptions)
    }
}
