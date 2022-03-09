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

    public let a11yIdentifier: String
    public private(set) var courseColor: UIColor?
    public private(set) var iconImage: UIImage
    public private(set) var label: String
    public private(set) var subtitle: String?
    public private(set) var specialIndicatorIcon: UIImage?

    @Environment(\.appEnvironment) private var env
    private let studentViewID = "student_view"
    private let tab: Tab?
    private let tabID: String
    private let type: TabType
    private let course: Course
    private let attendanceToolID: String?
    private let isAttendanceTool: Bool
    private var studentViewStudentRequest: APITask?

    public init(tab: Tab, course: Course, attendanceToolID: String?) {
        self.tab = tab
        self.tabID = tab.id
        self.type = tab.type
        self.course = course
        self.isAttendanceTool = tab.id == "context_external_tool_" + (attendanceToolID ?? "")
        self.attendanceToolID = attendanceToolID
        self.courseColor = course.color
        self.iconImage = isAttendanceTool ? .attendance : tab.icon
        self.label = tab.label
        self.subtitle = nil
        self.specialIndicatorIcon = nil
        self.a11yIdentifier = "courses-details.\(tab.id)-cell"
    }

    public static func studentView(course: Course) -> CourseDetailsCellViewModel {
        return CourseDetailsCellViewModel(course: course)
    }

    // Init for studentView
    private init(course: Course) {
        self.tab = nil
        self.tabID = studentViewID
        self.type = .internal
        self.course = course
        self.isAttendanceTool = false
        self.attendanceToolID = nil
        self.courseColor = course.color
        self.iconImage = .userLine
        self.label = NSLocalizedString("Student View", comment: "")
        self.subtitle = NSLocalizedString("Opens in Canvas Student", comment: "")
        self.specialIndicatorIcon = .externalLinkLine
        self.a11yIdentifier = "courses-details.\(studentViewID)-cell"
    }

    public func selected(router: Router, viewController: WeakViewController) {
        if isAttendanceTool, let attendanceToolID = attendanceToolID {
            router.route(to: "/courses/\(course.id)/attendance/" + attendanceToolID, from: viewController)
        } else if type == .external, let url = tab?.url {
            launchLTITool(url: url, viewController: viewController)
        } else if tabID == studentViewID {
            launchStudentView()
        } else {
            var route: URL?
            switch tab?.name {
            case .pages:
                route = URL(string: "/courses/\(course.id)/pages")
            case .collaborations, .conferences, .outcomes:
                route = tab?.fullURL
            case .syllabus:
                route = URL(string: "/courses/\(course.id)/syllabus")
            default:
                route = tab?.htmlURL
            }
            if let url = route {
                router.route(to: url, from: viewController)
            }
        }
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

    private func launchStudentView() {
        guard studentViewStudentRequest == nil else { return }
        let request = GetStudentViewStudent(courseID: course.id)
        studentViewStudentRequest = AppEnvironment.shared.api.makeRequest(request) { [weak self] user, _, _ in
            self?.handleStudentViewStudentResponse(user)
        }
    }

    private func handleStudentViewStudentResponse(_ user: APIUser?) {
        studentViewStudentRequest = nil
        guard let user = user else {
            // TODO Show error
            return
        }
        let studentID = user.id.rawValue
        performUIUpdate { [weak self] in
            if let loginDelegate = self?.env.loginDelegate {
                loginDelegate.actAsStudentViewStudent(studentViewStudentID: studentID)
            }
        }
    }
}

extension CourseDetailsCellViewModel: Equatable, Identifiable {

    public static func == (lhs: CourseDetailsCellViewModel, rhs: CourseDetailsCellViewModel) -> Bool {
        lhs.tabID == rhs.tabID
    }
}
