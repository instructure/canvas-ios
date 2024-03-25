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

        let loginSession = env.currentSession!

        let pageDownloadInteractor = HTMLDownloadInteractorLive(loginSession: loginSession, sectionName: "Pages", scheduler: scheduler)
        let pageHtmlParser = HTMLParser(loginSession: loginSession, downloadInteractor: pageDownloadInteractor, prefix: OfflineFolderPrefix.page.rawValue)

        let assignmentDownloadInteractor = HTMLDownloadInteractorLive(loginSession: loginSession, sectionName: "Assignments", scheduler: scheduler)
        let assignmentHtmlParser = HTMLParser(loginSession: loginSession, downloadInteractor: assignmentDownloadInteractor, prefix: OfflineFolderPrefix.assignment.rawValue)

        let quizDownloadInteractor = HTMLDownloadInteractorLive(loginSession: loginSession, sectionName: "Quizzes", scheduler: scheduler)
        let quizHtmlParser = HTMLParser(loginSession: loginSession, downloadInteractor: quizDownloadInteractor, prefix: OfflineFolderPrefix.quiz.rawValue)

        let announcementDownloadInteractor = HTMLDownloadInteractorLive(loginSession: loginSession, sectionName: "Announements", scheduler: scheduler)
        let announcementHtmlParser = HTMLParser(loginSession: loginSession, downloadInteractor: announcementDownloadInteractor, prefix: OfflineFolderPrefix.announcement.rawValue)

        let discussionDownloadInteractor = HTMLDownloadInteractorLive(loginSession: loginSession, sectionName: "Discussions", scheduler: scheduler)
        let discussionHtmlParser = HTMLParser(loginSession: loginSession, downloadInteractor: discussionDownloadInteractor, prefix: OfflineFolderPrefix.discussion.rawValue)

        let calendarEventDownloadInteractor = HTMLDownloadInteractorLive(loginSession: loginSession, sectionName: "CalendarEvents", scheduler: scheduler)
        let calendarEventHtmlParser = HTMLParser(loginSession: loginSession, downloadInteractor: calendarEventDownloadInteractor, prefix: OfflineFolderPrefix.calendarEvent.rawValue)

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
                                        modulesInteractor: CourseSyncModulesInteractorLive(),
                                        progressWriterInteractor: CourseSyncProgressWriterInteractorLive(),
                                        notificationInteractor: CourseSyncNotificationInteractor(notificationManager: .shared,
                                                                                                     progressInteractor: progressInteractor),
                                        courseListInteractor: AllCoursesAssembly.makeCourseListInteractor(),
                                        backgroundActivity: backgroundActivity,
                                        scheduler: scheduler)
    }
}
