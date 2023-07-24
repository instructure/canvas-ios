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
import CoreData

public class Permissions: NSManagedObject {
    @NSManaged public var context: String

    // ALL PERMISSIONS MUST HAVE DEFAULT VALUE NO IN THE XCDATAMODEL FILE

    // Account level
    @NSManaged public var becomeUser: Bool
    @NSManaged public var importSis: Bool
    @NSManaged public var manageAccountMemberships: Bool
    @NSManaged public var manageAccountSettings: Bool
    @NSManaged public var manageAlerts: Bool
    @NSManaged public var manageCatalog: Bool
    @NSManaged public var manageCourses: Bool
    @NSManaged public var manageDeveloperKeys: Bool
    @NSManaged public var manageFeatureFlags: Bool
    @NSManaged public var manageGlobalOutcomes: Bool
    @NSManaged public var manageJobs: Bool
    @NSManaged public var manageMasterCourses: Bool
    @NSManaged public var manageRoleOverrides: Bool
    @NSManaged public var manageStorageQuotas: Bool
    @NSManaged public var manageSis: Bool
    @NSManaged public var manageSiteSettings: Bool
    @NSManaged public var manageUserLogins: Bool
    @NSManaged public var manageUserObservers: Bool
    @NSManaged public var readCourseContent: Bool
    @NSManaged public var readCourseList: Bool
    @NSManaged public var readMessages: Bool
    @NSManaged public var resetAnyMfa: Bool
    @NSManaged public var siteAdmin: Bool
    @NSManaged public var viewCourseChanges: Bool
    @NSManaged public var viewErrorReports: Bool
    @NSManaged public var viewGradeChanges: Bool
    @NSManaged public var viewJobs: Bool
    @NSManaged public var viewNotifications: Bool
    @NSManaged public var viewStatistics: Bool
    @NSManaged public var undeleteCourses: Bool

    // Account and Course level
    @NSManaged public var changeCourseState: Bool
    @NSManaged public var commentOnOthersSubmissions: Bool
    @NSManaged public var createCollaborations: Bool
    @NSManaged public var createConferences: Bool
    @NSManaged public var createForum: Bool
    @NSManaged public var generateObserverPairingCode: Bool
    @NSManaged public var importOutcomes: Bool
    @NSManaged public var ltiAddEdit: Bool
    @NSManaged public var manageAdminUsers: Bool
    @NSManaged public var manageAssignments: Bool
    @NSManaged public var manageCalendar: Bool
    @NSManaged public var manageContent: Bool
    @NSManaged public var manageCourseContentEdit: Bool
    @NSManaged public var manageFiles: Bool
    @NSManaged public var manageGrades: Bool
    @NSManaged public var manageGroups: Bool
    @NSManaged public var manageInteractionAlerts: Bool
    @NSManaged public var manageOutcomes: Bool
    @NSManaged public var manageSections: Bool
    @NSManaged public var manageStudents: Bool
    @NSManaged public var manageUserNotes: Bool
    @NSManaged public var manageRubrics: Bool
    @NSManaged public var manageWiki: Bool
    @NSManaged public var moderateForum: Bool
    @NSManaged public var postToForum: Bool
    @NSManaged public var readAnnouncements: Bool
    @NSManaged public var readEmailAddresses: Bool
    @NSManaged public var readForum: Bool
    @NSManaged public var readQuestionBanks: Bool
    @NSManaged public var readReports: Bool
    @NSManaged public var readRoster: Bool
    @NSManaged public var readSis: Bool
    @NSManaged public var selectFinalGrade: Bool
    @NSManaged public var sendMessages: Bool
    @NSManaged public var sendMessagesAll: Bool
    @NSManaged public var useStudentView: Bool
    @NSManaged public var viewAllGrades: Bool
    @NSManaged public var viewAuditTrail: Bool
    @NSManaged public var viewGroupPages: Bool
    @NSManaged public var viewUserLogins: Bool

    @discardableResult
    public static func save(_ item: APIPermissions, for context: Context, in client: NSManagedObjectContext) -> Permissions {
        let predicate = NSPredicate(format: "%K == %@", #keyPath(Permissions.context), context.canvasContextID)
        let model: Permissions = client.fetch(predicate).first ?? client.insert()
        model.context = context.canvasContextID
        model.becomeUser = item.become_user ?? model.becomeUser
        model.importSis = item.import_sis ?? model.importSis
        model.manageAccountMemberships = item.manage_account_memberships ?? model.manageAccountMemberships
        model.manageAccountSettings = item.manage_account_settings ?? model.manageAccountSettings
        model.manageAlerts = item.manage_alerts ?? model.manageAlerts
        model.manageCatalog = item.manage_catalog ?? model.manageCatalog
        model.manageCourses = item.manage_courses ?? model.manageCourses
        model.manageDeveloperKeys = item.manage_developer_keys ?? model.manageDeveloperKeys
        model.manageFeatureFlags = item.manage_feature_flags ?? model.manageFeatureFlags
        model.manageGlobalOutcomes = item.manage_global_outcomes ?? model.manageGlobalOutcomes
        model.manageJobs = item.manage_jobs ?? model.manageJobs
        model.manageMasterCourses = item.manage_master_courses ?? model.manageMasterCourses
        model.manageRoleOverrides = item.manage_role_overrides ?? model.manageRoleOverrides
        model.manageStorageQuotas = item.manage_storage_quotas ?? model.manageStorageQuotas
        model.manageSis = item.manage_sis ?? model.manageSis
        model.manageSiteSettings = item.manage_site_settings ?? model.manageSiteSettings
        model.manageUserLogins = item.manage_user_logins ?? model.manageUserLogins
        model.manageUserObservers = item.manage_user_observers ?? model.manageUserObservers
        model.readCourseContent = item.read_course_content ?? model.readCourseContent
        model.readCourseList = item.read_course_list ?? model.readCourseList
        model.readMessages = item.read_messages ?? model.readMessages
        model.resetAnyMfa = item.reset_any_mfa ?? model.resetAnyMfa
        model.siteAdmin = item.site_admin ?? model.siteAdmin
        model.viewCourseChanges = item.view_course_changes ?? model.viewCourseChanges
        model.viewErrorReports = item.view_error_reports ?? model.viewErrorReports
        model.viewGradeChanges = item.view_grade_changes ?? model.viewGradeChanges
        model.viewJobs = item.view_jobs ?? model.viewJobs
        model.viewNotifications = item.view_notifications ?? model.viewNotifications
        model.viewStatistics = item.view_statistics ?? model.viewStatistics
        model.undeleteCourses = item.undelete_courses ?? model.undeleteCourses
        model.changeCourseState = item.change_course_state ?? model.changeCourseState
        model.commentOnOthersSubmissions = item.comment_on_others_submissions ?? model.commentOnOthersSubmissions
        model.createCollaborations = item.create_collaborations ?? model.createCollaborations
        model.createConferences = item.create_conferences ?? model.createConferences
        model.createForum = item.create_forum ?? model.createForum
        model.generateObserverPairingCode = item.generate_observer_pairing_code ?? model.generateObserverPairingCode
        model.importOutcomes = item.import_outcomes ?? model.importOutcomes
        model.ltiAddEdit = item.lti_add_edit ?? model.ltiAddEdit
        model.manageAdminUsers = item.manage_admin_users ?? model.manageAdminUsers
        model.manageAssignments = item.manage_assignments ?? model.manageAssignments
        model.manageCalendar = item.manage_calendar ?? model.manageCalendar
        model.manageContent = item.manage_content ?? model.manageContent
        model.manageCourseContentEdit = item.manage_course_content_edit ?? model.manageCourseContentEdit
        model.manageFiles = item.manage_files ?? model.manageFiles
        model.manageGrades = item.manage_grades ?? model.manageGrades
        model.manageGroups = item.manage_groups ?? model.manageGroups
        model.manageInteractionAlerts = item.manage_interaction_alerts ?? model.manageInteractionAlerts
        model.manageOutcomes = item.manage_outcomes ?? model.manageOutcomes
        model.manageSections = item.manage_sections ?? model.manageSections
        model.manageStudents = item.manage_students ?? model.manageStudents
        model.manageUserNotes = item.manage_user_notes ?? model.manageUserNotes
        model.manageRubrics = item.manage_rubrics ?? model.manageRubrics
        model.manageWiki = item.manage_wiki ?? model.manageWiki
        model.moderateForum = item.moderate_forum ?? model.moderateForum
        model.postToForum = item.post_to_forum ?? model.postToForum
        model.readAnnouncements = item.read_announcements ?? model.readAnnouncements
        model.readEmailAddresses = item.read_email_addresses ?? model.readEmailAddresses
        model.readForum = item.read_forum ?? model.readForum
        model.readQuestionBanks = item.read_question_banks ?? model.readQuestionBanks
        model.readReports = item.read_reports ?? model.readReports
        model.readRoster = item.read_roster ?? model.readRoster
        model.readSis = item.read_sis ?? model.readSis
        model.selectFinalGrade = item.select_final_grade ?? model.selectFinalGrade
        model.sendMessages = item.send_messages ?? model.sendMessages
        model.sendMessagesAll = item.send_messages_all ?? model.sendMessagesAll
        model.useStudentView = item.use_student_view ?? model.useStudentView
        model.viewAllGrades = item.view_all_grades ?? model.viewAllGrades
        model.viewAuditTrail = item.view_audit_trail ?? model.viewAuditTrail
        model.viewGroupPages = item.view_group_pages ?? model.viewGroupPages
        model.viewUserLogins = item.view_user_logins ?? model.viewUserLogins

        return model
    }
}
