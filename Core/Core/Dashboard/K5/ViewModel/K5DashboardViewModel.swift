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

import SwiftUI

public class K5DashboardViewModel: ObservableObject {
    let navigationItems: [K5DashboardNavigationViewModel] = [
        K5DashboardNavigationViewModel(type: .homeroom, icon: .coursesLine, label: Text("Homeroom", bundle: .core)),
        K5DashboardNavigationViewModel(type: .schedule, icon: .calendarMonthLine, label: Text("Schedule", bundle: .core)),
        K5DashboardNavigationViewModel(type: .grades, icon: .gradebookLine, label: Text("Grades", bundle: .core)),
        K5DashboardNavigationViewModel(type: .resources, icon: .folderLine, label: Text("Resources", bundle: .core)),
    ]
    @Published var currentNavigationItem: K5DashboardNavigationViewModel
    let viewModels = (
        homeroom: K5HomeroomViewModel(),
        schedule: K5ScheduleViewModel(),
        grades: K5GradesViewModel(),
        resources: K5ResourcesViewModel()
    )

    init() {
        currentNavigationItem = navigationItems.first!
    }

    func profileButtonPressed(router: Router, viewController: WeakViewController) {
        router.route(to: "/profile", from: viewController, options: .modal())
    }
}
