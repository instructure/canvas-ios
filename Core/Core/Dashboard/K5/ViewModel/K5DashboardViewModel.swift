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

enum LocalNavigationType: String {
    case homeroom
    case schedule
    case grades
    case resources
}

struct LocalNavigationItem: Identifiable {
    var id: String { type.rawValue }

    let type: LocalNavigationType
    let icon: Image
    let label: Text
}

public class K5DashboardViewModel: ObservableObject {
    let navigationItems: [LocalNavigationItem] = [
        LocalNavigationItem(type: .homeroom, icon: .coursesLine, label: Text("Homeroom", bundle: .core)),
        LocalNavigationItem(type: .schedule, icon: .calendarMonthLine, label: Text("Schedule", bundle: .core)),
        LocalNavigationItem(type: .grades, icon: .gradebookLine, label: Text("Grades", bundle: .core)),
        LocalNavigationItem(type: .resources, icon: .folderLine, label: Text("Resources", bundle: .core)),
    ]
    @Published var currentNavigationItem: LocalNavigationItem

    init() {
        currentNavigationItem = navigationItems.first!
    }
}
