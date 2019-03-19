//
// Copyright (C) 2019-present Instructure, Inc.
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

public struct APIPermissions: Codable, Equatable {
    // Account level
    let become_user: Bool?
    let import_sis: Bool?
    let manage_account_memberships: Bool?
    let manage_account_settings: Bool?
    let manage_alerts: Bool?
    let manage_catalog: Bool?
    let manage_courses: Bool?
    let manage_developer_keys: Bool?
    let manage_feature_flags: Bool?
    let manage_global_outcomes: Bool?
    let manage_jobs: Bool?
    let manage_master_courses: Bool?
    let manage_role_overrides: Bool?
    let manage_storage_quotas: Bool?
    let manage_sis: Bool?
    let manage_site_settings: Bool?
    let manage_user_logins: Bool?
    let manage_user_observers: Bool?
    let read_course_content: Bool?
    let read_course_list: Bool?
    let read_messages: Bool?
    let reset_any_mfa: Bool?
    let site_admin: Bool?
    let view_course_changes: Bool?
    let view_error_reports: Bool?
    let view_grade_changes: Bool?
    let view_jobs: Bool?
    let view_notifications: Bool?
    let view_statistics: Bool?
    let undelete_courses: Bool?

    // Account and Course level
    let change_course_state: Bool?
    let comment_on_others_submissions: Bool?
    let create_collaborations: Bool?
    let create_conferences: Bool?
    let create_forum: Bool?
    let generate_observer_pairing_code: Bool?
    let import_outcomes: Bool?
    let lti_add_edit: Bool?
    let manage_admin_users: Bool?
    let manage_assignments: Bool?
    let manage_calendar: Bool?
    let manage_content: Bool?
    let manage_files: Bool?
    let manage_grades: Bool?
    let manage_groups: Bool?
    let manage_interaction_alerts: Bool?
    let manage_outcomes: Bool?
    let manage_sections: Bool?
    let manage_students: Bool?
    let manage_user_notes: Bool?
    let manage_rubrics: Bool?
    let manage_wiki: Bool?
    let moderate_forum: Bool?
    let post_to_forum: Bool?
    let read_announcements: Bool?
    let read_email_addresses: Bool?
    let read_forum: Bool?
    let read_question_banks: Bool?
    let read_reports: Bool?
    let read_roster: Bool?
    let read_sis: Bool?
    let select_final_grade: Bool?
    let send_messages: Bool?
    let send_messages_all: Bool?
    let view_all_grades: Bool?
    let view_audit_trail: Bool?
    let view_group_pages: Bool?
    let view_user_logins: Bool?
}
