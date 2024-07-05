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
import CombineSchedulers

public enum CourseSyncDownloaderAssembly {

    public static func makeInteractor(env: AppEnvironment = .shared) -> CourseSyncInteractor {
        let scheduler = DispatchQueue(
            label: "com.instructure.icanvas.core.course-sync-download"
        ).eraseToAnyScheduler()

        let loginSession = env.currentSession

        let pageHtmlParser = makeHTMLParser(for: .pages, loginSession: loginSession, scheduler: scheduler)
        let assignmentHtmlParser = makeHTMLParser(for: .assignments, loginSession: loginSession, scheduler: scheduler)
        let quizHtmlParser = makeHTMLParser(for: .quizzes, loginSession: loginSession, scheduler: scheduler)
        let announcementHtmlParser = makeHTMLParser(for: .announcements, loginSession: loginSession, scheduler: scheduler)
        let calendarEventHtmlParser = makeHTMLParser(for: .calendarEvents, loginSession: loginSession, scheduler: scheduler)
        let discussionHtmlParser = makeHTMLParser(for: .discussions, loginSession: loginSession, scheduler: scheduler)

        let offlineFolder = URL.Directories.documents.appendingPathComponent(
            URL.Paths.Offline.root(sessionID: loginSession?.uniqueID ?? "")
        )
        let studioMediaInteractor = CourseSyncStudioMediaInteractorLive(
            offlineDirectory: offlineFolder,
            studioAuthInteractor: StudioAPIAuthInteractor(),
            studioIFrameReplaceInteractor: StudioIFrameReplaceInteractor(),
            studioIFrameDiscoveryInteractor: StudioIFrameDiscoveryInteractor(studioHtmlParser: StudioHTMLParserInteractor()),
            scheduler: scheduler
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
            CourseSyncDiscussionsInteractorLive(discussionHtmlParser: discussionHtmlParser),
        ]
        let progressInteractor = CourseSyncProgressObserverInteractorLive()
        let backgroundActivity = BackgroundActivity(processManager: ProcessInfo.processInfo, activityName: "Offline Sync")

        return CourseSyncInteractorLive(brandThemeInteractor: BrandThemeDownloaderInteractor(),
                                        contentInteractors: contentInteractors,
                                        filesInteractor: CourseSyncFilesInteractorLive(),
                                        modulesInteractor: CourseSyncModulesInteractorLive(pageHtmlParser: pageHtmlParser, quizHtmlParser: quizHtmlParser),
                                        progressWriterInteractor: CourseSyncProgressWriterInteractorLive(),
                                        notificationInteractor: CourseSyncNotificationInteractor(progressInteractor: progressInteractor),
                                        courseListInteractor: AllCoursesAssembly.makeCourseListInteractor(),
                                        studioMediaInteractor: studioMediaInteractor,
                                        backgroundActivity: backgroundActivity,
                                        scheduler: scheduler,
                                        env: env)
    }

    private static func makeHTMLParser(
        for section: OfflineFolderPrefix,
        loginSession: LoginSession?,
        scheduler: AnySchedulerOf<DispatchQueue>
    ) -> HTMLParser {
        let sessionId = loginSession?.uniqueID ?? ""

        let interactor = HTMLDownloadInteractorLive(
            loginSession: loginSession,
            sectionName: section.rawValue,
            scheduler: scheduler
        )

        return HTMLParserLive(
            sessionId: sessionId,
            downloadInteractor: interactor
        )
    }
}
