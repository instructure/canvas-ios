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
    private let isInternalURL: Bool
    private let route: URL?

    public init(tab: Tab, course: Course, selectedCallback: @escaping () -> Void) {
        let route: URL? = {
            switch tab.name {
            case .pages:
                return URL(string: "/courses/\(course.id)/pages")
            case .collaborations, .conferences, .outcomes:
                return tab.fullURL
            default:
                return tab.htmlURL
            }
        }()
        let isInternalURL: Bool = {
            guard let route = route else {
                return true
            }

            return AppEnvironment.shared.router.isRegisteredRoute(route)
        }()

        self.isInternalURL = isInternalURL
        self.route = route
        super.init(
            courseColor: course.color,
            iconImage: tab.icon,
            label: tab.label,
            subtitle: nil,
            accessoryIconType: isInternalURL ? .disclosure : .externalLink,
            tabID: tab.id,
            selectedCallback: selectedCallback
        )
    }

    public override func selected(router: Router, viewController: WeakViewController) {
        if isInternalURL {
            // We don't want cells opening safari to get a permanent highlight so we report selection only on in-app opened menus
            super.selected(router: router, viewController: viewController)
        }

        if let url = route {
            router.route(to: url, from: viewController)
        }
    }
}
