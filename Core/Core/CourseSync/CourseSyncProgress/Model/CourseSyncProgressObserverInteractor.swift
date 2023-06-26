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

protocol CourseSyncProgressObserverInteractor {
    func observeFileProgress() -> AnyPublisher<ReactiveStore<LocalUseCase<CourseSyncFileProgress>>.State, Never>
    func observeEntryProgress() -> AnyPublisher<ReactiveStore<LocalUseCase<CourseSyncEntryProgress>>.State, Never>
    /// Combines file + entry progresses. Range is `0...1`.
    func observeCombinedProgress() -> AnyPublisher<Float, Never>
}

final class CourseSyncProgressObserverInteractorLive: CourseSyncProgressObserverInteractor {
    private let context: NSManagedObjectContext

    public init(context: NSManagedObjectContext = AppEnvironment.shared.database.viewContext) {
        self.context = context
    }

    func observeFileProgress() -> AnyPublisher<ReactiveStore<LocalUseCase<CourseSyncFileProgress>>.State, Never> {
        let useCase = LocalUseCase<CourseSyncFileProgress>(scope: Scope.all)
        return ReactiveStore(
            context: context,
            useCase: useCase
        )
        .observeEntities()
        .eraseToAnyPublisher()
    }

    func observeEntryProgress() -> AnyPublisher<ReactiveStore<LocalUseCase<CourseSyncEntryProgress>>.State, Never> {
        let useCase = LocalUseCase<CourseSyncEntryProgress>(scope: Scope.all)
        return ReactiveStore(
            context: context,
            useCase: useCase
        )
        .observeEntities()
        .eraseToAnyPublisher()
    }

    func observeCombinedProgress() -> AnyPublisher<Float, Never> {
        let fileProgress = observeFileProgress()
            .map {
                if let progress = $0.firstItem {
                    return (toDownload: progress.bytesToDownload,
                            downloaded: progress.bytesDownloaded)
                } else {
                    return (toDownload: 0,
                            downloaded: 0)
                }
            }
        let entryProgress = observeEntryProgress()
            .map { $0.allItems?.downloadSizes ?? (toDownload: 0, downloaded: 0) }

        return Publishers
            .CombineLatest(fileProgress, entryProgress)
            .map { fileProgress, entryProgress in
                let totalToDownload = fileProgress.toDownload + entryProgress.toDownload
                let totalDownloaded = fileProgress.downloaded + entryProgress.downloaded
                if totalToDownload > 0 {
                    return Float(totalDownloaded) / Float(totalToDownload)
                } else {
                    return 0
                }
            }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
}

extension Array where Element == CourseSyncEntryProgress {

    var downloadSizes: (toDownload: Int, downloaded: Int) {
        let estimatedEntrySize = 100_000
        return self
            .removeCourseEntries()
            .removeFileEntries()
            .reduce(into: (toDownload: 0, downloaded: 0)) { partialResult, entry in
                partialResult.toDownload += estimatedEntrySize

                switch entry.state {
                case .downloaded, .error:
                    partialResult.downloaded += estimatedEntrySize
                default: break
                }
            }
    }

    /// Course entries on their own are not syncable entries (only their tabs) and can be ignored
    private func removeCourseEntries() -> Self {
        var result = self
        result.removeAll { entry in
            if case .course = entry.selection {
                return true
            } else {
                return false
            }
        }
        return result
    }

    /// File progresses are tracked separately so we don't need to calculate with them here.
    private func removeFileEntries() -> Self {
        var result = self
        result.removeAll { entry in
            if case .file = entry.selection {
                return true
            } else {
                return false
            }
        }
        return result
    }
}
