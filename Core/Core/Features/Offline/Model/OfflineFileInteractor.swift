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

import Combine
import Foundation

public protocol OfflineFileInteractor {
    func filePath(sessionID: String, courseId: String, fileID: String, fileName: String) -> String
    func isItemAvailableOffline(courseID: String?, fileID: String?) -> Bool
    func filePath(source: OfflineFileSource?) -> String?
    func isItemAvailableOffline(source: OfflineFileSource?) -> Bool
    var isOffline: Bool { get }
}

public final class OfflineFileInteractorLive: OfflineFileInteractor {
    private let offlineModeInteractor: OfflineModeInteractor

    public init(offlineModeInteractor: OfflineModeInteractor = OfflineModeAssembly.make()) {
        self.offlineModeInteractor = offlineModeInteractor
    }

    // MARK: Public functions

    public func filePath(source: OfflineFileSource?) -> String? {
        switch source {
        case .privateFile(let sessionID, let courseID, let sectionName, let resourceID, let fileID):
            return filePath(sessionID: sessionID, courseId: courseID, section: sectionName, resourceId: resourceID, fileID: fileID)
        case .publicFile(let sessionID, let courseID, let fileID, let fileName):
            return filePath(sessionID: sessionID, courseId: courseID, fileID: fileID, fileName: fileName)
        case .none:
            return nil
        }
    }

    public func isItemAvailableOffline(source: OfflineFileSource?) -> Bool {
        switch source {
        case .privateFile(let sessionID, let courseID, let sectionName, let resourceID, let fileID):
            return isItemAvailableOffline(sessionID: sessionID, courseId: courseID, section: sectionName, resourceId: resourceID, fileID: fileID)
        case .publicFile(_, let courseID, let fileID, _):
            return isItemAvailableOffline(courseID: courseID, fileID: fileID)
        case .none:
            return false
        }
    }

    public func filePath(sessionID: String, courseId: String, fileID: String, fileName: String) -> String {
        // Offline synced files are organized by the courseId in a folder.
        URL.Paths.Offline.courseFolder(
            sessionID: sessionID,
            courseId: courseId
        ) + "/file-\(fileID)/\(fileName)"
    }

    public func isItemAvailableOffline(courseID: String?, fileID: String?) -> Bool {
        guard offlineModeInteractor.isOfflineModeEnabled() else { return false }
        guard let selections = AppEnvironment.shared.userDefaults?.offlineSyncSelections,
              let courseID = courseID,
              let fileID = fileID?.replacingOccurrences(of: "file-", with: "") else { return false }
        if fileID.contains("folder") { return true }
        let syncSelections = ["courses/\(courseID)", "courses/\(courseID)/tabs/files", "courses/\(courseID)/files/\(fileID)"]
        return selections.contains(where: syncSelections.contains)
    }

    public var isOffline: Bool {
        offlineModeInteractor.isOfflineModeEnabled()
    }

    // MARK: - Private helpers

    private func filePath(sessionID: String?, courseId: String?, section: String?, resourceId: String?, fileID: String?) -> String? {
        guard let sessionID, let courseId, let section, let resourceId, let fileID else { return nil }
        let folderURL = URL.Paths.Offline.courseSectionResourceFolderURL(sessionId: sessionID, courseId: courseId, sectionName: section, resourceId: resourceId)
            .appendingPathComponent("file-\(fileID)")

        guard let fileName = (try? FileManager.default.contentsOfDirectory(atPath: folderURL.path))?.first else { return nil }
        let absoluteURL = "\(folderURL.path)/\(fileName)"
        let relativeURL = absoluteURL.replacingOccurrences(of: URL.Directories.documents.path, with: "")
        return relativeURL
    }

    private func isItemAvailableOffline(sessionID: String?, courseId: String?, section: String?, resourceId: String?, fileID: String?) -> Bool {
        guard offlineModeInteractor.isOfflineModeEnabled() else { return false }
        guard let sessionID, let courseId, let section, let resourceId, let fileID else { return false }
        let folderURL = URL.Paths.Offline.courseSectionResourceFolderURL(sessionId: sessionID, courseId: courseId, sectionName: section, resourceId: resourceId)
            .appendingPathComponent("file-\(fileID)")

        return ((try? FileManager.default.contentsOfDirectory(atPath: folderURL.path))?.first != nil)
    }
}
