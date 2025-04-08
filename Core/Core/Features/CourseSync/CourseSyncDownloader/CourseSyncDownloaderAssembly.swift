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

    public static func makeInteractor(environmentResolver: CourseSyncEnvironmentResolver? = nil) -> CourseSyncInteractor {
        let envResolver = environmentResolver ?? DefaultCourseSyncEnvironmentResolver()
        let scheduler = DispatchQueue(
            label: "com.instructure.icanvas.core.course-sync-download"
        ).eraseToAnyScheduler()

        let pageHtmlParser = makeHTMLParser(for: .pages, envResolver: envResolver, scheduler: scheduler)
        let assignmentHtmlParser = makeHTMLParser(for: .assignments, envResolver: envResolver, scheduler: scheduler)
        let quizHtmlParser = makeHTMLParser(for: .quizzes, envResolver: envResolver, scheduler: scheduler)
        let announcementHtmlParser = makeHTMLParser(for: .announcements, envResolver: envResolver, scheduler: scheduler)
        let calendarEventHtmlParser = makeHTMLParser(for: .calendarEvents, envResolver: envResolver, scheduler: scheduler)
        let discussionHtmlParser = makeHTMLParser(for: .discussions, envResolver: envResolver, scheduler: scheduler)

        let contentInteractors: [CourseSyncContentInteractor] = [
            CourseSyncPagesInteractorLive(htmlParser: pageHtmlParser),
            CourseSyncPeopleInteractorLive(envResolver: envResolver),
            CourseSyncAssignmentsInteractorLive(htmlParser: assignmentHtmlParser),
            CourseSyncGradesInteractorLive(envResolver: envResolver),
            CourseSyncSyllabusInteractorLive(
                assignmentEventHtmlParser: assignmentHtmlParser,
                calendarEventHtmlParser: calendarEventHtmlParser,
                envResolver: envResolver
            ),
            CourseSyncConferencesInteractorLive(envResolver: envResolver),
            CourseSyncAnnouncementsInteractorLive(htmlParser: announcementHtmlParser),
            CourseSyncQuizzesInteractorLive(htmlParser: quizHtmlParser),
            CourseSyncDiscussionsInteractorLive(htmlParser: discussionHtmlParser)
        ]
        let progressInteractor = CourseSyncProgressObserverInteractorLive()
        let backgroundActivity = BackgroundActivity(processManager: ProcessInfo.processInfo, activityName: "Offline Sync")

        return CourseSyncInteractorLive(
            brandThemeInteractor: BrandThemeDownloaderInteractor(),
            contentInteractors: contentInteractors,
            filesInteractor: CourseSyncFilesInteractorLive(),
            modulesInteractor: CourseSyncModulesInteractorLive(
                pageHtmlParser: pageHtmlParser,
                quizHtmlParser: quizHtmlParser,
                envResolver: envResolver
            ),
            progressWriterInteractor: CourseSyncProgressWriterInteractorLive(),
            notificationInteractor: CourseSyncNotificationInteractor(
                progressInteractor: progressInteractor
            ),
            courseListInteractor: AllCoursesAssembly.makeCourseListInteractor(),
            studioMediaInteractor: makeStudioDownloader(
                scheduler: scheduler,
                envResolver: envResolver
            ),
            backgroundActivity: backgroundActivity,
            scheduler: scheduler,
            envResolver: envResolver
        )
    }

    private static func makeHTMLParser(
        for section: OfflineFolderPrefix,
        envResolver: CourseSyncEnvironmentResolver,
        scheduler: AnySchedulerOf<DispatchQueue>
    ) -> HTMLParser {

        let interactor = HTMLDownloadInteractorLive(
            sectionName: section.rawValue,
            envResolver: envResolver,
            scheduler: scheduler
        )

        return HTMLParserLive(
            downloadInteractor: interactor
        )
    }

    private static func makeStudioDownloader(
        scheduler: AnySchedulerOf<DispatchQueue>,
        envResolver: CourseSyncEnvironmentResolver
    ) -> CourseSyncStudioMediaInteractor {
        let studioDownloadInteractor = StudioVideoDownloadInteractorLive(
            captionsInteractor: StudioCaptionsInteractorLive(),
            videoCacheInteractor: StudioVideoCacheInteractorLive(),
            posterInteractor: StudioVideoPosterInteractorLive()
        )
        return CourseSyncStudioMediaInteractorLive(
            authInteractor: StudioAPIAuthInteractorLive(),
            iFrameReplaceInteractor: StudioIFrameReplaceInteractorLive(),
            iFrameDiscoveryInteractor: StudioIFrameDiscoveryInteractorLive(
                studioHtmlParser: StudioHTMLParserInteractorLive(),
                envResolver: envResolver
            ),
            cleanupInteractor: StudioVideoCleanupInteractorLive(),
            metadataDownloadInteractor: StudioMetadataDownloadInteractorLive(),
            downloadInteractor: studioDownloadInteractor,
            scheduler: scheduler,
            envResolver: envResolver
        )
    }
}
