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
    func saveDownloadProgress(entries: [CourseSyncEntry])
    func saveDownloadResult(isFinished: Bool, error: String?)
    func cleanUpPreviousDownloadProgress()
    func setInitialLoadingState(entries: [CourseSyncEntry])
    func saveStateProgress(id: String, selection: CourseEntrySelection, state: CourseSyncEntry.State)
}

public final class CourseSyncProgressWriterInteractorLive: CourseSyncProgressWriterInteractor {
    private let context: NSManagedObjectContext

    public init(container: NSPersistentContainer = AppEnvironment.shared.database) {
        context = container.newBackgroundContext()
        context.automaticallyMergesChangesFromParent = true
    }

    public func saveDownloadProgress(entries: [CourseSyncEntry]) {
        let bytesDownloaded = entries.totalDownloadedSize
        let bytesToDownloaded = entries.totalSelectedSize

        context.performAndWait {
            let progress: CourseSyncDownloadProgress = context.fetch(scope: .all).first ?? context.insert()
            progress.bytesDownloaded = bytesDownloaded
            progress.bytesToDownload = bytesToDownloaded
            try? context.save()
        }
    }

    public func saveDownloadResult(isFinished: Bool, error: String?) {
        context.performAndWait {
            let progress: CourseSyncDownloadProgress = context.fetch(scope: .all).first ?? context.insert()
            progress.isFinished = isFinished
            progress.error = error
            try? context.save()
        }
    }

    public func cleanUpPreviousDownloadProgress() {
        context.performAndWait {
            context.delete(context.fetch(scope: .all) as [CourseSyncStateProgress])
            context.delete(context.fetch(scope: .all) as [CourseSyncDownloadProgress])
            try? context.save()
        }
    }

    public func setInitialLoadingState(entries: [CourseSyncEntry]) {
        for entry in entries {
            saveStateProgress(id: entry.id, selection: .course(entry.id), state: .loading(nil))

            for tab in entry.tabs {
                saveStateProgress(id: tab.id, selection: .tab(entry.id, tab.id), state: .loading(nil))
            }

            for file in entry.files {
                saveStateProgress(id: file.id, selection: .file(entry.id, file.id), state: .loading(nil))
            }
        }
    }

    public func saveStateProgress(id: String, selection: CourseEntrySelection, state: CourseSyncEntry.State) {
        context.performAndWait {
            let progress: CourseSyncStateProgress = context.fetch(
                scope: .where(
                    #keyPath(CourseSyncStateProgress.id),
                    equals: id,
                    sortDescriptors: []
                )
            ).first ?? context.insert()

            progress.id = id
            progress.selection = selection
            progress.state = state
            try? context.save()
        }
    }
}
