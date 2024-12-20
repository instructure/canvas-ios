//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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
    let manage_course_content_edit: Bool?
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
    let use_student_view: Bool?
    let view_all_grades: Bool?
    let view_audit_trail: Bool?
    let view_group_pages: Bool?
    let view_user_logins: Bool?
}

#if DEBUG
extension APIPermissions {
    public static func make(
        become_user: Bool? = nil,
        import_sis: Bool? = nil,
        manage_account_memberships: Bool? = nil,
        manage_account_settings: Bool? = nil,
        manage_alerts: Bool? = nil,
        manage_catalog: Bool? = nil,
        manage_courses: Bool? = nil,
        manage_developer_keys: Bool? = nil,
        manage_feature_flags: Bool? = nil,
        manage_global_outcomes: Bool? = nil,
        manage_jobs: Bool? = nil,
        manage_master_courses: Bool? = nil,
        manage_role_overrides: Bool? = nil,
        manage_storage_quotas: Bool? = nil,
        manage_sis: Bool? = nil,
        manage_site_settings: Bool? = nil,
        manage_user_logins: Bool? = nil,
        manage_user_observers: Bool? = nil,
        read_course_content: Bool? = nil,
        read_course_list: Bool? = nil,
        read_messages: Bool? = nil,
        reset_any_mfa: Bool? = nil,
        site_admin: Bool? = nil,
        view_course_changes: Bool? = nil,
        view_error_reports: Bool? = nil,
        view_grade_changes: Bool? = nil,
        view_jobs: Bool? = nil,
        view_notifications: Bool? = nil,
        view_statistics: Bool? = nil,
        undelete_courses: Bool? = nil,
        change_course_state: Bool? = nil,
        comment_on_others_submissions: Bool? = nil,
        create_collaborations: Bool? = nil,
        create_conferences: Bool? = nil,
        create_forum: Bool? = nil,
        generate_observer_pairing_code: Bool? = nil,
        import_outcomes: Bool? = nil,
        lti_add_edit: Bool? = nil,
        manage_admin_users: Bool? = nil,
        manage_assignments: Bool? = nil,
        manage_calendar: Bool? = nil,
        manage_content: Bool? = nil,
        manage_course_content_edit: Bool? = nil,
        manage_files: Bool? = nil,
        manage_grades: Bool? = nil,
        manage_groups: Bool? = nil,
        manage_interaction_alerts: Bool? = nil,
        manage_outcomes: Bool? = nil,
        manage_sections: Bool? = nil,
        manage_students: Bool? = nil,
        manage_user_notes: Bool? = nil,
        manage_rubrics: Bool? = nil,
        manage_wiki: Bool? = nil,
        moderate_forum: Bool? = nil,
        post_to_forum: Bool? = nil,
        read_announcements: Bool? = nil,
        read_email_addresses: Bool? = nil,
        read_forum: Bool? = nil,
        read_question_banks: Bool? = nil,
        read_reports: Bool? = nil,
        read_roster: Bool? = nil,
        read_sis: Bool? = nil,
        select_final_grade: Bool? = nil,
        send_messages: Bool? = nil,
        send_messages_all: Bool? = nil,
        use_student_view: Bool? = nil,
        view_all_grades: Bool? = nil,
        view_audit_trail: Bool? = nil,
        view_group_pages: Bool? = nil,
        view_user_logins: Bool? = nil
    ) -> APIPermissions {
        return APIPermissions(
            become_user: become_user,
            import_sis: import_sis,
            manage_account_memberships: manage_account_memberships,
            manage_account_settings: manage_account_settings,
            manage_alerts: manage_alerts,
            manage_catalog: manage_catalog,
            manage_courses: manage_courses,
            manage_developer_keys: manage_developer_keys,
            manage_feature_flags: manage_feature_flags,
            manage_global_outcomes: manage_global_outcomes,
            manage_jobs: manage_jobs,
            manage_master_courses: manage_master_courses,
            manage_role_overrides: manage_role_overrides,
            manage_storage_quotas: manage_storage_quotas,
            manage_sis: manage_sis,
            manage_site_settings: manage_site_settings,
            manage_user_logins: manage_user_logins,
            manage_user_observers: manage_user_observers,
            read_course_content: read_course_content,
            read_course_list: read_course_list,
            read_messages: read_messages,
            reset_any_mfa: reset_any_mfa,
            site_admin: site_admin,
            view_course_changes: view_course_changes,
            view_error_reports: view_error_reports,
            view_grade_changes: view_grade_changes,
            view_jobs: view_jobs,
            view_notifications: view_notifications,
            view_statistics: view_statistics,
            undelete_courses: undelete_courses,
            change_course_state: change_course_state,
            comment_on_others_submissions: comment_on_others_submissions,
            create_collaborations: create_collaborations,
            create_conferences: create_conferences,
            create_forum: create_forum,
            generate_observer_pairing_code: generate_observer_pairing_code,
            import_outcomes: import_outcomes,
            lti_add_edit: lti_add_edit,
            manage_admin_users: manage_admin_users,
            manage_assignments: manage_assignments,
            manage_calendar: manage_calendar,
            manage_content: manage_content,
            manage_course_content_edit: manage_course_content_edit,
            manage_files: manage_files,
            manage_grades: manage_grades,
            manage_groups: manage_groups,
            manage_interaction_alerts: manage_interaction_alerts,
            manage_outcomes: manage_outcomes,
            manage_sections: manage_sections,
            manage_students: manage_students,
            manage_user_notes: manage_user_notes,
            manage_rubrics: manage_rubrics,
            manage_wiki: manage_wiki,
            moderate_forum: moderate_forum,
            post_to_forum: post_to_forum,
            read_announcements: read_announcements,
            read_email_addresses: read_email_addresses,
            read_forum: read_forum,
            read_question_banks: read_question_banks,
            read_reports: read_reports,
            read_roster: read_roster,
            read_sis: read_sis,
            select_final_grade: select_final_grade,
            send_messages: send_messages,
            send_messages_all: send_messages_all,
            use_student_view: use_student_view,
            view_all_grades: view_all_grades,
            view_audit_trail: view_audit_trail,
            view_group_pages: view_group_pages,
            view_user_logins: view_user_logins
        )
    }
}
#endif

// https://canvas.instructure.com/doc/api/all_resources.html#method.accounts.permissions
// https://canvas.instructure.com/doc/api/all_resources.html#method.courses.permissions
// https://canvas.instructure.com/doc/api/all_resources.html#method.groups.permissions
public struct GetContextPermissionsRequest: APIRequestable {
    public typealias Response = APIPermissions

    let context: Context
    let permissions: [PermissionName]

    public init(context: Context, permissions: [PermissionName] = []) {
        self.context = context
        self.permissions = permissions
    }

    public var path: String {
        return "\(context.pathComponent)/permissions"
    }

    public var query: [APIQueryItem] {
        guard permissions.count > 0 else {
            return []
        }

        return [.array("permissions", permissions.map { $0.rawValue })]
    }
}
