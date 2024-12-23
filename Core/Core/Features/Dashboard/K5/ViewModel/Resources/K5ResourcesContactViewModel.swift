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

public struct K5ResourcesContactViewModel {
    public let image: URL?
    public let name: String
    public let role: String
    public let userId: String
    public let courseContextID: String
    public let courseName: String

    public init(image: URL?, name: String, role: String, userId: String, courseContextID: String, courseName: String) {
        self.image = image
        self.name = name
        self.role = role
        self.userId = userId
        self.courseContextID = courseContextID
        self.courseName = courseName
    }

    /**
     - parameters:
        - user: The teacher's user profile.
        - courses: The list of homeroom courses where the teacher is enrolled as a teacher or a TA.
     */
    public init(_ user: APIUser, courses: [Course]) {
        let firstActiveEnrollment = user.enrollments?.first { $0.enrollment_state == .active }
        let firstActiveRole = firstActiveEnrollment?.role
        let role = firstActiveRole == Role.teacher.rawValue ? String(localized: "Teacher", bundle: .core) : String(localized: "Teacher's Assistant", bundle: .core)
        let courseCode: String = {
            if let courseId = firstActiveEnrollment?.course_id {
                return "course_\(courseId)"
            } else {
                return ""
            }
        }()
        let courseName = courses.first { course in course.canvasContextID == courseCode }?.name ?? ""
        self.init(image: user.avatar_url?.rawValue, name: user.name, role: role, userId: user.id.rawValue, courseContextID: courseCode, courseName: courseName)
    }

    public func contactTapped(router: Router, viewController: WeakViewController) {
        guard let context = Context(canvasContextID: courseContextID) else { return }
        let composeMessageOptions = ComposeMessageOptions(
            disabledFields: .init(contextDisabled: true, recipientsDisabled: true),
            fieldsContents: .init(
                selectedContext: .init(name: courseName, context: context),
                selectedRecipients: [Recipient(id: userId, name: name, avatarURL: image?.absoluteURL)])
        )

        router.route(
            to: URLComponents.parse("/conversations/compose", queryItems: composeMessageOptions.queryItems),
            from: viewController.value,
            options: .modal(embedInNav: true)
        )
    }
}

extension K5ResourcesContactViewModel: Comparable {
    public static func < (lhs: K5ResourcesContactViewModel, rhs: K5ResourcesContactViewModel) -> Bool {
        lhs.name < rhs.name
    }
}

extension K5ResourcesContactViewModel: Equatable {
    public static func == (lhs: K5ResourcesContactViewModel, rhs: K5ResourcesContactViewModel) -> Bool {
        lhs.name == rhs.name
    }
}

extension K5ResourcesContactViewModel: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
}
extension K5ResourcesContactViewModel: Identifiable {
    public var id: String { userId + courseContextID }
}
