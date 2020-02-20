//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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

import Foundation
@testable import Core

extension APICourse {
    public static func make(
        id: ID = "1",
        name: String? = "Course One",
        course_code: String? = "C1",
        workflow_state: CourseWorkflowState? = nil,
        account_id: String? = nil,
        start_at: Date? = nil,
        end_at: Date? = nil,
        locale: String? = nil,
        enrollments: [APIEnrollment]? = [ .make(
            id: nil,
            enrollment_state: .active,
            user_id: "12",
            role: "StudentEnrollment",
            role_id: "3"
        ), ],
        default_view: CourseDefaultView? = nil,
        syllabus_body: String? = nil,
        term: Term? = nil,
        permissions: Permissions? = nil,
        hide_final_grades: Bool? = false,
        access_restricted_by_date: Bool? = nil,
        image_download_url: String? = nil,
        is_favorite: Bool? = nil
    ) -> APICourse {
        return APICourse(
            id: id,
            name: name,
            course_code: course_code,
            workflow_state: workflow_state,
            account_id: account_id,
            start_at: start_at,
            end_at: end_at,
            locale: locale,
            enrollments: enrollments,
            default_view: default_view,
            syllabus_body: syllabus_body,
            term: term,
            permissions: permissions,
            hide_final_grades: hide_final_grades,
            access_restricted_by_date: access_restricted_by_date,
            image_download_url: image_download_url,
            is_favorite: is_favorite
        )
    }
}

extension APICourse: APIContext {
    public var contextType: ContextType { return .course }
}
