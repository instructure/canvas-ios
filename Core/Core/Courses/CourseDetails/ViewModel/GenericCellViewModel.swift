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

extension Tab: TabViewable {}

class GenericCellViewModel: CourseDetailsCellViewModel {
    private let route: URL?

    public init(tab: Tab, course: Course) {
        self.route = {
            switch tab.name {
            case .pages:
                return URL(string: "/courses/\(course.id)/pages")
            case .collaborations, .conferences, .outcomes:
                return tab.fullURL
            case .syllabus:
                return URL(string: "/courses/\(course.id)/syllabus")
            default:
                return tab.htmlURL
            }
        }()

        super.init(courseColor: course.color,
                   iconImage: tab.icon,
                   label: tab.label,
                   subtitle: nil,
                   accessoryIconType: .disclosure,
                   tabID: tab.id)
    }

    public override func selected(router: Router, viewController: WeakViewController) {
        if let url = route {
            router.route(to: url, from: viewController)
        }
    }
}
