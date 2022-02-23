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

import SwiftUI

extension Tab: TabViewable {}

public class CourseDetailsCellViewModel: ObservableObject {

    private let tab: Tab
    private let course: Course
    private let attendanceToolID: String?
    public private(set) var courseColor: UIColor?

    public init(tab: Tab, course: Course, attendanceToolID: String?) {
        self.tab = tab
        self.course = course
        self.courseColor = course.color
        self.attendanceToolID = attendanceToolID
    }

    public func selected(router: Router, viewController: WeakViewController) {
        if let attendanceToolID = attendanceToolID, isAttendanceTool {
            router.route(to: "/courses/\(course.id)/attendance/" + attendanceToolID, from: viewController)
        } else {
            if tab.type == .external, let url = tab.url {
                launchLTITool(url: url, viewController: viewController)
            } else {
                if let url = tab.htmlURL {
                    router.route(to: url, from: viewController)
                }
            }
        }
    }

    public var route: URL? {
        tab.htmlURL
    }

    public var iconImage: UIImage {
        if isAttendanceTool {
            return .attendance
        }
        return tab.icon
    }

    public var label: String {
        tab.label
    }

    public var id: String {
        tab.id
    }

    public var isHome: Bool {
        tab.label == "Home"
    }

    private var isAttendanceTool: Bool {
        tab.id == "context_external_tool_" + (attendanceToolID ?? "")
    }

    private func launchLTITool(url: URL, viewController: WeakViewController) {
        LTITools.launch(
            context: nil,
            id: nil,
            url: url,
            launchType: nil,
            assignmentID: nil,
            from: viewController.value
        )
    }
}

extension CourseDetailsCellViewModel: Equatable {

    public static func == (lhs: CourseDetailsCellViewModel, rhs: CourseDetailsCellViewModel) -> Bool {
        lhs.tab.id == rhs.tab.id
    }
}
