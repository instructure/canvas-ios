//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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

public protocol CourseSyncEnvironmentResolver {
    var userId: String { get }
    func targetEnvironment(for courseID: CourseSyncID) -> AppEnvironment
    func offlineDirectory(for courseID: CourseSyncID) -> URL
    func offlineStudioDirectory(for courseID: CourseSyncID) -> URL
    func folderURL(forSection sectionName: String, ofCourse courseId: CourseSyncID) -> URL
    func folderDocumentsPath(forSection sectionName: String, ofCourse courseId: CourseSyncID) -> String
}

public extension CourseSyncEnvironmentResolver {

    func loginSession(for courseID: CourseSyncID) -> LoginSession? {
        targetEnvironment(for: courseID).currentSession
    }

    func sessionId(for courseID: CourseSyncID) -> String {
        loginSession(for: courseID)?.uniqueID ?? ""
    }

    func offlineDirectory(for courseID: CourseSyncID) -> URL {
        URL
            .Paths
            .Offline
            .rootURL(sessionID: sessionId(for: courseID))
    }

    func offlineStudioDirectory(for courseID: CourseSyncID) -> URL {
        offlineDirectory(for: courseID).appendingPathComponent("studio", isDirectory: true)
    }

    func folderURL(forSection sectionName: String, ofCourse courseId: CourseSyncID) -> URL {
        URL.Paths.Offline.courseSectionFolderURL(
            sessionId: sessionId(for: courseId),
            courseId: courseId.value,
            sectionName: sectionName
        )
    }

    func folderDocumentsPath(forSection sectionName: String, ofCourse courseId: CourseSyncID) -> String {
        URL.Paths.Offline.courseSectionFolder(
            sessionId: sessionId(for: courseId),
            courseId: courseId.value,
            sectionName: sectionName
        )
    }
}

class CourseSyncEnvironmentResolverLive: CourseSyncEnvironmentResolver {

    var userId: String {
        AppEnvironment.shared.currentSession?.userID ?? "self"
    }

    func targetEnvironment(for courseID: CourseSyncID) -> AppEnvironment {
        .resolved(for: courseID.apiBaseURL)
    }
}
