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
import Combine
import CombineSchedulers

class CourseSyncProgressInfoViewModel: ObservableObject {
    enum State: Equatable {
        // progress is always 1 here, this is just for convenience
        case finishedSuccessfully(message: String, progress: Float)
        case finishedWithError(title: String, subtitle: String)
        case downloadStarting(message: String)
        case downloadInProgress(message: String, progress: Float)
    }

    @Published private(set) var state: State = .downloadStarting(message: "")

    init(
        interactor: CourseSyncProgressInteractor,
        scheduler: AnySchedulerOf<DispatchQueue> = .main
    ) {
        interactor.observeDownloadProgress()
            .receive(on: scheduler)
            .map { progress in
                if progress.isFinished {
                    if progress.error != nil {
                        return .finishedWithError(title: String(localized: "Offline Content Sync Failed", bundle: .core),
                                                  subtitle: String(localized: "One or more items failed to sync. Please check your internet connection and retry syncing.", bundle: .core))
                    } else {
                        let format = String(localized: "Success! Downloaded %@ of %@", bundle: .core)
                        let message = String.localizedStringWithFormat(format,
                                                                       progress.bytesDownloaded.humanReadableFileSize,
                                                                       progress.bytesToDownload.humanReadableFileSize)
                        return .finishedSuccessfully(message: message, progress: 1)
                    }
                } else {
                    let format = String(localized: "Downloading %@ of %@", bundle: .core, comment: "Downloading 42 GB of 64 GB")
                    let message = String.localizedStringWithFormat(format,
                                                                   progress.bytesDownloaded.humanReadableFileSize,
                                                                   progress.bytesToDownload.humanReadableFileSize)
                    if progress.progress == 0 {
                        return .downloadStarting(message: message)
                    } else {
                        return .downloadInProgress(message: message, progress: progress.progress)
                    }
                }
            }
            .assign(to: &$state)
    }
}
