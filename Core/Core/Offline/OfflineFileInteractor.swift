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

public protocol OfflineFileInteractor {
    func filePath(sessionID: String, fileID: String, fileName: String) -> String
    func isItemAvailableOffline(courseID: String?, fileID: String?) -> Bool
    var isOffline: Bool { get }
}

public final class OfflineFileInteractorLive: OfflineFileInteractor {

    // MARK: - Dependencies

    private let offlineModeInteractor: OfflineModeInteractor

    public init(offlineModeInteractor: OfflineModeInteractor = OfflineModeInteractorLive.shared) {
        self.offlineModeInteractor = offlineModeInteractor
    }

    public func filePath(sessionID: String, fileID: String, fileName: String) -> String {
        "\(sessionID)/Offline/Files/\(fileID)/\(fileName)"
    }

    public func isItemAvailableOffline(courseID: String?, fileID: String?) -> Bool {
        guard offlineModeInteractor.isOfflineModeEnabled() else { return true }
        guard let selections = AppEnvironment.shared.userDefaults?.offlineSyncSelections,
              let courseID = courseID,
              let fileID = fileID?.replacingOccurrences(of: "file-", with: "") else { return true }
        if fileID.contains("folder") { return true }
        let syncSelections = ["courses/\(courseID)", "courses/\(courseID)/tabs/files", "courses/\(courseID)/files/\(fileID)"]
        return selections.contains(where: syncSelections.contains)
    }

    public var isOffline: Bool {
        offlineModeInteractor.isOfflineModeEnabled()
    }
}
