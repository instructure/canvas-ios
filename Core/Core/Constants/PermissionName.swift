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

public enum PermissionName: String {

    // Account level
    case becomeUser = "become_user"
    case importSis = "import_sis"
    case manageAccountMemberships = "manage_account_memberships"
    case manageAccountSettings = "manage_account_settings"
    case manageAlerts = "manage_alerts"
    case manageCatalog = "manage_catalog"
    case manageCourses = "manage_courses"
    case manageDeveloperKeys = "manage_developer_keys"
    case manageFeatureFlags = "manage_feature_flags"
    case manageGlobalOutcomes = "manage_global_outcomes"
    case manageJobs = "manage_jobs"
    case manageMasterCourses = "manage_master_courses"
    case manageRoleOverrides = "manage_role_overrides"
    case manageStorageQuotas = "manage_storage_quotas"
    case manageSis = "manage_sis"
    case manageSiteSettings = "manage_site_settings"
    case manageUserLogins = "manage_user_logins"
    case manageUserObservers = "manage_user_observers"
    case readCourseContent = "read_course_content"
    case readCourseList = "read_course_list"
    case readMessages = "read_messages"
    case resetAnyMfa = "reset_any_mfa"
    case siteAdmin = "site_admin"
    case viewCourseChanges = "view_course_changes"
    case viewErrorReports = "view_error_reports"
    case viewGradeChanges = "view_grade_changes"
    case viewJobs = "view_jobs"
    case viewNotifications = "view_notifications"
    case viewStatistics = "view_statistics"
    case undeleteCourses = "undelete_courses"

    // Account and Course level
    case changeCourseState = "change_course_state"
    case commentOnOthersSubmissions = "comment_on_others_submissions"
    case createCollaborations = "create_collaborations"
    case createConferences = "create_conferences"
    case createForum = "create_forum"
    case generateObserverPairingCode = "generate_observer_pairing_code"
    case importOutcomes = "import_outcomes"
    case ltiAddEdit = "lti_add_edit"
    case manageAdminUsers = "manage_admin_users"
    case manageAssignments = "manage_assignments"
    case manageCalendar = "manage_calendar"
    case manageContent = "manage_content"
    case manageCourseContentEdit = "manage_course_content_edit"
    case manageFiles = "manage_files"
    case manageGrades = "manage_grades"
    case manageGroups = "manage_groups"
    case manageInteractionAlerts = "manage_interaction_alerts"
    case manageOutcomes = "manage_outcomes"
    case manageSections = "manage_sections"
    case manageStudents = "manage_students"
    case manageUserNotes = "manage_user_notes"
    case manageRubrics = "manage_rubrics"
    case manageWiki = "manage_wiki"
    case moderateForum = "moderate_forum"
    case postToForum = "post_to_forum"
    case readAnnouncements = "read_announcements"
    case readEmailAddresses = "read_email_addresses"
    case readForum = "read_forum"
    case readQuestionBanks = "read_question_banks"
    case readReports = "read_reports"
    case readRoster = "read_roster"
    case readSis = "read_sis"
    case selectFinalGrade = "select_final_grade"
    case sendMessages = "send_messages"
    case sendMessagesAll = "send_messages_all"
    case useStudentView = "use_student_view"
    case viewAllGrades = "view_all_grades"
    case viewAuditTrail = "view_audit_trail"
    case viewGroupPages = "view_group_pages"
    case viewUserLogins = "view_user_logins"
}
