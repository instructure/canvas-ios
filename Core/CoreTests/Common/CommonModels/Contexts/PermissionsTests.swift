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

import XCTest
@testable import Core

class PermissionsTests: CoreTestCase {
    func testPropertiesFalseByDefault() {
        let model: Permissions = databaseClient.insert()
        XCTAssertFalse(model.becomeUser)
        XCTAssertFalse(model.importSis)
        XCTAssertFalse(model.manageAccountMemberships)
        XCTAssertFalse(model.manageAccountSettings)
        XCTAssertFalse(model.manageAlerts)
        XCTAssertFalse(model.manageCatalog)
        XCTAssertFalse(model.manageCourses)
        XCTAssertFalse(model.manageDeveloperKeys)
        XCTAssertFalse(model.manageFeatureFlags)
        XCTAssertFalse(model.manageGlobalOutcomes)
        XCTAssertFalse(model.manageJobs)
        XCTAssertFalse(model.manageMasterCourses)
        XCTAssertFalse(model.manageRoleOverrides)
        XCTAssertFalse(model.manageStorageQuotas)
        XCTAssertFalse(model.manageSis)
        XCTAssertFalse(model.manageSiteSettings)
        XCTAssertFalse(model.manageUserLogins)
        XCTAssertFalse(model.manageUserObservers)
        XCTAssertFalse(model.readCourseContent)
        XCTAssertFalse(model.readCourseList)
        XCTAssertFalse(model.readMessages)
        XCTAssertFalse(model.resetAnyMfa)
        XCTAssertFalse(model.siteAdmin)
        XCTAssertFalse(model.viewCourseChanges)
        XCTAssertFalse(model.viewErrorReports)
        XCTAssertFalse(model.viewGradeChanges)
        XCTAssertFalse(model.viewJobs)
        XCTAssertFalse(model.viewNotifications)
        XCTAssertFalse(model.viewStatistics)
        XCTAssertFalse(model.undeleteCourses)
        XCTAssertFalse(model.changeCourseState)
        XCTAssertFalse(model.commentOnOthersSubmissions)
        XCTAssertFalse(model.createCollaborations)
        XCTAssertFalse(model.createConferences)
        XCTAssertFalse(model.createForum)
        XCTAssertFalse(model.generateObserverPairingCode)
        XCTAssertFalse(model.importOutcomes)
        XCTAssertFalse(model.ltiAddEdit)
        XCTAssertFalse(model.manageAdminUsers)
        XCTAssertFalse(model.manageAssignments)
        XCTAssertFalse(model.manageCalendar)
        XCTAssertFalse(model.manageContent)
        XCTAssertFalse(model.manageCourseContentEdit)
        XCTAssertFalse(model.manageFiles)
        XCTAssertFalse(model.manageGrades)
        XCTAssertFalse(model.manageGroups)
        XCTAssertFalse(model.manageInteractionAlerts)
        XCTAssertFalse(model.manageOutcomes)
        XCTAssertFalse(model.manageSections)
        XCTAssertFalse(model.manageStudents)
        XCTAssertFalse(model.manageUserNotes)
        XCTAssertFalse(model.manageRubrics)
        XCTAssertFalse(model.manageWiki)
        XCTAssertFalse(model.moderateForum)
        XCTAssertFalse(model.postToForum)
        XCTAssertFalse(model.readAnnouncements)
        XCTAssertFalse(model.readEmailAddresses)
        XCTAssertFalse(model.readForum)
        XCTAssertFalse(model.readQuestionBanks)
        XCTAssertFalse(model.readReports)
        XCTAssertFalse(model.readRoster)
        XCTAssertFalse(model.readSis)
        XCTAssertFalse(model.selectFinalGrade)
        XCTAssertFalse(model.sendMessages)
        XCTAssertFalse(model.sendMessagesAll)
        XCTAssertFalse(model.useStudentView)
        XCTAssertFalse(model.viewAllGrades)
        XCTAssertFalse(model.viewAuditTrail)
        XCTAssertFalse(model.viewGroupPages)
        XCTAssertFalse(model.viewUserLogins)
    }

    func testSave() {
        let apiPermissions = APIPermissions.make(
            become_user: true, import_sis: true, manage_account_memberships: true, manage_account_settings: true, manage_alerts: true,
            manage_catalog: true, manage_courses: true, manage_developer_keys: true, manage_feature_flags: true, manage_global_outcomes: true,
            manage_jobs: true, manage_master_courses: true, manage_role_overrides: true, manage_storage_quotas: true, manage_sis: true,
            manage_site_settings: true, manage_user_logins: true, manage_user_observers: true, read_course_content: true,
            read_course_list: true, read_messages: true, reset_any_mfa: true, site_admin: true, view_course_changes: true,
            view_error_reports: true, view_grade_changes: true, view_jobs: true, view_notifications: true, view_statistics: true,
            undelete_courses: true, change_course_state: true, comment_on_others_submissions: true, create_collaborations: true,
            create_conferences: true, create_forum: true, generate_observer_pairing_code: true, import_outcomes: true, lti_add_edit: true,
            manage_admin_users: true, manage_assignments: true, manage_calendar: true, manage_content: true, manage_course_content_edit: true, manage_files: true,
            manage_grades: true, manage_groups: true, manage_interaction_alerts: true, manage_outcomes: true, manage_sections: true,
            manage_students: true, manage_user_notes: true, manage_rubrics: true, manage_wiki: true, moderate_forum: true,
            post_to_forum: true, read_announcements: true, read_email_addresses: true, read_forum: true, read_question_banks: true,
            read_reports: true, read_roster: true, read_sis: true, select_final_grade: true, send_messages: true, send_messages_all: true,
            use_student_view: true, view_all_grades: true, view_audit_trail: true, view_group_pages: true, view_user_logins: true
        )
        let context = Context(.account, id: "self")

        Permissions.save(apiPermissions, for: context, in: databaseClient)
        XCTAssertNoThrow(try databaseClient.save())

        let permissions: Permissions = databaseClient.fetch().first!
        XCTAssertEqual(permissions.context, "account_self")

        XCTAssertTrue(permissions.becomeUser)
        XCTAssertTrue(permissions.importSis)
        XCTAssertTrue(permissions.manageAccountMemberships)
        XCTAssertTrue(permissions.manageAccountSettings)
        XCTAssertTrue(permissions.manageAlerts)
        XCTAssertTrue(permissions.manageCatalog)
        XCTAssertTrue(permissions.manageCourses)
        XCTAssertTrue(permissions.manageDeveloperKeys)
        XCTAssertTrue(permissions.manageFeatureFlags)
        XCTAssertTrue(permissions.manageGlobalOutcomes)
        XCTAssertTrue(permissions.manageJobs)
        XCTAssertTrue(permissions.manageMasterCourses)
        XCTAssertTrue(permissions.manageRoleOverrides)
        XCTAssertTrue(permissions.manageStorageQuotas)
        XCTAssertTrue(permissions.manageSis)
        XCTAssertTrue(permissions.manageSiteSettings)
        XCTAssertTrue(permissions.manageUserLogins)
        XCTAssertTrue(permissions.manageUserObservers)
        XCTAssertTrue(permissions.readCourseContent)
        XCTAssertTrue(permissions.readCourseList)
        XCTAssertTrue(permissions.readMessages)
        XCTAssertTrue(permissions.resetAnyMfa)
        XCTAssertTrue(permissions.siteAdmin)
        XCTAssertTrue(permissions.viewCourseChanges)
        XCTAssertTrue(permissions.viewErrorReports)
        XCTAssertTrue(permissions.viewGradeChanges)
        XCTAssertTrue(permissions.viewJobs)
        XCTAssertTrue(permissions.viewNotifications)
        XCTAssertTrue(permissions.viewStatistics)
        XCTAssertTrue(permissions.undeleteCourses)
        XCTAssertTrue(permissions.changeCourseState)
        XCTAssertTrue(permissions.commentOnOthersSubmissions)
        XCTAssertTrue(permissions.createCollaborations)
        XCTAssertTrue(permissions.createConferences)
        XCTAssertTrue(permissions.createForum)
        XCTAssertTrue(permissions.generateObserverPairingCode)
        XCTAssertTrue(permissions.importOutcomes)
        XCTAssertTrue(permissions.ltiAddEdit)
        XCTAssertTrue(permissions.manageAdminUsers)
        XCTAssertTrue(permissions.manageAssignments)
        XCTAssertTrue(permissions.manageCalendar)
        XCTAssertTrue(permissions.manageContent)
        XCTAssertTrue(permissions.manageCourseContentEdit)
        XCTAssertTrue(permissions.manageFiles)
        XCTAssertTrue(permissions.manageGrades)
        XCTAssertTrue(permissions.manageGroups)
        XCTAssertTrue(permissions.manageInteractionAlerts)
        XCTAssertTrue(permissions.manageOutcomes)
        XCTAssertTrue(permissions.manageSections)
        XCTAssertTrue(permissions.manageStudents)
        XCTAssertTrue(permissions.manageUserNotes)
        XCTAssertTrue(permissions.manageRubrics)
        XCTAssertTrue(permissions.manageWiki)
        XCTAssertTrue(permissions.moderateForum)
        XCTAssertTrue(permissions.postToForum)
        XCTAssertTrue(permissions.readAnnouncements)
        XCTAssertTrue(permissions.readEmailAddresses)
        XCTAssertTrue(permissions.readForum)
        XCTAssertTrue(permissions.readQuestionBanks)
        XCTAssertTrue(permissions.readReports)
        XCTAssertTrue(permissions.readRoster)
        XCTAssertTrue(permissions.readSis)
        XCTAssertTrue(permissions.selectFinalGrade)
        XCTAssertTrue(permissions.sendMessages)
        XCTAssertTrue(permissions.sendMessagesAll)
        XCTAssertTrue(permissions.useStudentView)
        XCTAssertTrue(permissions.viewAllGrades)
        XCTAssertTrue(permissions.viewAuditTrail)
        XCTAssertTrue(permissions.viewGroupPages)
        XCTAssertTrue(permissions.viewUserLogins)
    }

    func testDoesntChangePropertiesUnlessInTheResponse() {
        let apiPermissions = APIPermissions.make(become_user: true)

        let permissions = Permissions.make(from: .make(manage_sis: true))

        Permissions.save(apiPermissions, for: Context(.account, id: "1"), in: databaseClient)
        XCTAssertNoThrow(try databaseClient.save())

        databaseClient.refresh()
        XCTAssertTrue(permissions.manageSis)
        XCTAssertTrue(permissions.becomeUser)
    }
}
