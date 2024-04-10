//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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

public enum CourseSyncDownloaderAssembly {

    public static func makeInteractor(env: AppEnvironment = .shared) -> CourseSyncInteractor {
        let scheduler = DispatchQueue(
            label: "com.instructure.icanvas.core.course-sync-download"
        ).eraseToAnyScheduler()

        let sessionId = env.currentSession?.uniqueID ?? ""
        let loginSession = env.currentSession

        let pageDownloadInteractor = HTMLDownloadInteractorLive(
            loginSession: loginSession,
            sectionName: OfflineContainerPrefix.Pages.rawValue,
            scheduler: scheduler
        )
        let pageHtmlParser = HTMLParserLive(
            sessionId: sessionId,
            downloadInteractor: pageDownloadInteractor,
            prefix: OfflineFolderPrefix.page.rawValue
        )

        let assignmentDownloadInteractor = HTMLDownloadInteractorLive(
            loginSession: loginSession,
            sectionName: OfflineContainerPrefix.Assignments.rawValue,
            scheduler: scheduler
        )
        let assignmentHtmlParser = HTMLParserLive(
            sessionId: sessionId,
            downloadInteractor: assignmentDownloadInteractor,
            prefix: OfflineFolderPrefix.assignment.rawValue
        )

        let quizDownloadInteractor = HTMLDownloadInteractorLive(
            loginSession: loginSession,
            sectionName: OfflineContainerPrefix.Quizzes.rawValue,
            scheduler: scheduler
        )
        let quizHtmlParser = HTMLParserLive(
            sessionId: sessionId,
            downloadInteractor: quizDownloadInteractor,
            prefix: OfflineFolderPrefix.quiz.rawValue
        )

        let announcementDownloadInteractor = HTMLDownloadInteractorLive(
            loginSession: loginSession,
            sectionName: OfflineContainerPrefix.Announcements.rawValue,
            scheduler: scheduler
        )
        let announcementHtmlParser = HTMLParserLive(
            sessionId: sessionId,
            downloadInteractor: announcementDownloadInteractor,
            prefix: OfflineFolderPrefix.announcement.rawValue
        )

        let discussionDownloadInteractor = HTMLDownloadInteractorLive(
            loginSession: loginSession,
            sectionName: OfflineContainerPrefix.Discussions.rawValue,
            scheduler: scheduler
        )
        let discussionHtmlParser = HTMLParserLive(
            sessionId: sessionId,
            downloadInteractor: discussionDownloadInteractor,
            prefix: OfflineFolderPrefix.discussion.rawValue
        )

        let calendarEventDownloadInteractor = HTMLDownloadInteractorLive(
            loginSession: loginSession,
            sectionName: OfflineContainerPrefix.CalendarEvents.rawValue,
            scheduler: scheduler
        )
        let calendarEventHtmlParser = HTMLParserLive(
            sessionId: sessionId,
            downloadInteractor: calendarEventDownloadInteractor,
            prefix: OfflineFolderPrefix.calendarEvent.rawValue
        )

        let contentInteractors: [CourseSyncContentInteractor] = [
            CourseSyncPagesInteractorLive(htmlParser: pageHtmlParser),
            CourseSyncPeopleInteractorLive(),
            CourseSyncAssignmentsInteractorLive(htmlParser: assignmentHtmlParser),
            CourseSyncGradesInteractorLive(userId: AppEnvironment.shared.currentSession?.userID ?? "self"),
            CourseSyncSyllabusInteractorLive(assignmentEventHtmlParser: assignmentHtmlParser, calendarEventHtmlParser: calendarEventHtmlParser),
            CourseSyncConferencesInteractorLive(),
            CourseSyncAnnouncementsInteractorLive(htmlParser: announcementHtmlParser),
            CourseSyncQuizzesInteractorLive(htmlParser: quizHtmlParser),
            CourseSyncDiscussionsInteractorLive(htmlParser: discussionHtmlParser),
        ]
        let progressInteractor = CourseSyncProgressObserverInteractorLive()
        let backgroundActivity = BackgroundActivity(processManager: ProcessInfo.processInfo, activityName: "Offline Sync")

        return CourseSyncInteractorLive(contentInteractors: contentInteractors,
                                        filesInteractor: CourseSyncFilesInteractorLive(),
                                        modulesInteractor: CourseSyncModulesInteractorLive(pageHtmlParser: pageHtmlParser, quizHtmlParser: quizHtmlParser),
                                        progressWriterInteractor: CourseSyncProgressWriterInteractorLive(),
                                        notificationInteractor: CourseSyncNotificationInteractor(notificationManager: .shared,
                                                                                                     progressInteractor: progressInteractor),
                                        courseListInteractor: AllCoursesAssembly.makeCourseListInteractor(),
                                        backgroundActivity: backgroundActivity,
                                        scheduler: scheduler,
                                        env: env)
    }
}
