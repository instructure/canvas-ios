//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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

import Core
import Foundation

enum HCourseSyncInteractorAssembly {
    static func makeInteractor() -> HCourseSyncInteractor {
        let scheduler = DispatchQueue(label: "com.instructure.horizon-sync").eraseToAnyScheduler()
        let envResolver = CourseSyncEnvironmentResolverLive()
        let htmlParser = CourseSyncDownloaderAssembly.makeHTMLParser(
            for: .pages,
            envResolver: envResolver,
            scheduler: scheduler
        )
        let pageInteractor = HCourseSyncPagesInteractorLive(htmlParser: htmlParser)
        let filesInteractor = HCourseSyncFilesInteractorLive()
        let userId = AppEnvironment.shared.currentSession?.userID
        let session = AppEnvironment.shared.userDefaults ?? .fallback
        let assignmentsInteractor = HCourseSyncAssignmentsInteractorLive(
            htmlParser: CourseSyncDownloaderAssembly.makeHTMLParser(
                for: .assignments,
                envResolver: envResolver,
                scheduler: scheduler
            ),
            filesInteractor: filesInteractor,
            userId: userId.defaultToEmpty
        )
        return HCourseSyncInteractorLive(
            interactorFiles: filesInteractor,
            pagesInteractor: pageInteractor,
            sessionManager: HOfflineSyncSessionManagerLive(
                session: session,
                filesInteractor: filesInteractor,
                pagesInteractor: pageInteractor
            ), assignmentsInteractor: assignmentsInteractor
        )
    }
}
