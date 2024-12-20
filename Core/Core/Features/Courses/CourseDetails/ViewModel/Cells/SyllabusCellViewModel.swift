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

class SyllabusCellViewModel: CourseDetailsCellViewModel {
    private let route: URL?

    public init(tab: Tab, course: Course, selectedCallback: @escaping () -> Void) {
        self.route = URL(string: "/courses/\(course.id)/syllabus")

        super.init(courseColor: course.color,
                   iconImage: tab.icon,
                   label: tab.label,
                   subtitle: nil,
                   accessoryIconType: .disclosure,
                   tabID: tab.id,
                   selectedCallback: selectedCallback)
    }

    public override func selected(router: Router, viewController: WeakViewController) {
        super.selected(router: router, viewController: viewController)

        if let url = route {
            router.route(to: url, from: viewController, options: .detail)
        }
    }
}
