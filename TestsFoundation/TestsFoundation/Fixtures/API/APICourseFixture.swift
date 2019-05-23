//
// Copyright (C) 2018-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Foundation
@testable import Core

extension APICourse {
    public static func make(
        id: ID = "1",
        name: String? = "Course One",
        course_code: String? = nil,
        workflow_state: CourseWorkflowState? = nil,
        account_id: String? = nil,
        start_at: Date? = nil,
        end_at: Date? = nil,
        locale: String? = nil,
        enrollments: [APIEnrollment]? = [ .make(
            enrollment_state: .active,
            user_id: "12",
            role: "StudentEnrollment",
            role_id: "3"
        ), ],
        default_view: CourseDefaultView? = nil,
        syllabus_body: String? = nil,
        term: Term? = nil,
        permissions: Permissions? = nil,
        access_restricted_by_date: Bool? = nil,
        image_download_url: URL? = nil,
        is_favorite: Bool? = nil,
        sections: [APISection]? = nil
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
            access_restricted_by_date: access_restricted_by_date,
            image_download_url: image_download_url,
            is_favorite: is_favorite,
            sections: sections
        )
    }
}

extension APICourse: APIContext {
    public var contextType: ContextType { return .course }
}
