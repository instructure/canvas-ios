//
// Copyright (C) 2018-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import Foundation

// https://canvas.instructure.com/doc/api/courses.html#Course
public struct APICourse: Codable, Equatable {
    let id: String
    // let sis_course_id: String?
    // let uuid: String?
    // let integration_id: String?
    // let sis_import_id: String?
    let name: String?
    let course_code: String?
    let workflow_state: CourseWorkflowState?
    let account_id: String?
    // let root_account_id: String?
    // let enrollment_term_id: String?
    // let grading_standard_id: String?
    let start_at: Date?
    let end_at: Date?
    let locale: String?
    let enrollments: [APIEnrollment]?
    // let total_students: Int? // include[]=total_students
    // let calendar: ?
    let default_view: CourseDefaultView?
    // let syllabus_body: String? // include[]=syllabus_body
    // let needs_grading_count: Int? // include[]=needs_grading_count
    let term: Term? // include[]=term
    // let course_progress: ?
    // let apply_assignment_group_weights: Bool?
    let permissions: Permissions?
    // let is_public: Bool?
    // let is_public_to_auth_users: Bool?
    // let public_syllabus: Bool?
    // let public_syllabus_to_auth: Bool?
    // let public_description: String?
    // let storage_quota_mb: Double?
    // let storage_quota_used_mb: Double? // include[]=storage_quota_used_mb
    // let hide_final_grades: Bool?
    // let license: String?
    // let allow_student_assignment_edits: Bool?
    // let allow_wiki_comments: Bool?
    // let allow_student_forum_attachments: Bool?
    // let open_enrollment: Bool?
    // let self_enrollment: Bool?
    // let restrict_enrollments_to_course_dates: Bool?
    // let course_format: String?
    let access_restricted_by_date: Bool?
    // let time_zone: TimeZone?
    // let blueprint: Bool?
    // let blueprint_restrictions: ?
    // let blueprint_restrictions_by_object_type: ?
    let image_download_url: URL? // include[]=course_image
    let is_favorite: Bool? // include[]=favorites
    let sections: [APISection]? // include[]=sections

    // https://canvas.instructure.com/doc/api/courses.html#Term
    struct Term: Codable, Equatable {
        let id: String
        let name: String
        let start_at: Date?
        let end_at: Date?
    }

    struct Permissions: Codable, Equatable {
        let create_announcement: Bool
        let create_discussion_topic: Bool
    }
}
