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
    @Published private(set) var topBarViewModel = TopBarViewModel(items: [
        TopBarItemViewModel(icon: .k5homeroom, label: Text("Homeroom", bundle: .core)),
        TopBarItemViewModel(icon: .k5schedule, label: Text("Schedule", bundle: .core)),
        TopBarItemViewModel(icon: .k5grades, label: Text("Grades", bundle: .core)),
//        TopBarItemViewModel(icon: .k5resources, label: Text("Resources", bundle: .core)),
    ])

    let viewModels = (
        homeroom: K5HomeroomViewModel(),
        schedule: K5ScheduleViewModel(),
        grades: K5GradesViewModel(),
        resources: K5ResourcesViewModel()
    )

    private var topBarChangeListener: AnyCancellable?

    init() {
        // Propagate changes of the underlying view model to this observable class because there's no native support for nested ObservableObjects
        topBarChangeListener = topBarViewModel.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
        }
    }

    func profileButtonPressed(router: Router, viewController: WeakViewController) {
        router.route(to: "/profile", from: viewController, options: .modal())
    }
}
