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
import CoreData
import Foundation

public protocol CourseSyncProgressWriterInteractor {
    func saveFileProgress(entries: [CourseSyncEntry], error: String?)
    func cleanUpPreviousFileProgress(entries: [CourseSyncEntry])
    func saveEntryProgress(id: String, selection: CourseEntrySelection, state: CourseSyncEntry.State)
}

public final class CourseSyncProgressWriterInteractorLive: CourseSyncProgressWriterInteractor {
    private let context: NSManagedObjectContext

    public init(context: NSManagedObjectContext = AppEnvironment.shared.database.viewContext) {
        self.context = context
    }

    public func saveFileProgress(entries: [CourseSyncEntry], error: String?) {
        let bytesDownloaded = entries.totalDownloadedSize
        let bytesToDownloaded = entries.totalSelectedSize

        context.performAndWait {
            let progress: CourseSyncFileProgress = context.fetch(scope: .all).first ?? context.insert()
            progress.bytesDownloaded = bytesDownloaded
            progress.bytesToDownload = bytesToDownloaded
            progress.error = error
            try? context.save()
        }
    }

    public func cleanUpPreviousFileProgress(entries: [CourseSyncEntry]) {
        saveFileProgress(entries: entries, error: nil)
    }

    public func saveEntryProgress(id: String, selection: CourseEntrySelection, state: CourseSyncEntry.State) {
        context.performAndWait {
            let entryProgress: CourseSyncEntryProgress = context.fetch(
                scope: .where(
                    #keyPath(CourseSyncEntryProgress.id),
                    equals: id,
                    sortDescriptors: []
                )
            ).first ?? context.insert()

            entryProgress.id = id
            entryProgress.selection = selection
            entryProgress.state = state
            try? context.save()
        }
    }
}
