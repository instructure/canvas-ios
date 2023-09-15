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
    @Published private(set) var progress: String = "" // Downloading 42 GB of 64 GB
    @Published private(set) var progressPercentage: Float = 0
    @Published private(set) var syncFailure: Bool = false
    @Published private(set) var syncFailureTitle: String
    @Published private(set) var syncFailureSubtitle: String

    private var subscriptions = Set<AnyCancellable>()

    init(
        interactor: CourseSyncProgressInteractor,
        scheduler: AnySchedulerOf<DispatchQueue> = .main
    ) {
        syncFailureTitle = NSLocalizedString(
            "Offline Content Sync Failed",
            bundle: .core,
            comment: ""
        )
        syncFailureSubtitle = NSLocalizedString(
            "One or more files failed to sync. Check your internet connection and retry to submit.",
            bundle: .core,
            comment: ""
        )

        unowned let unownedSelf = self

        interactor.observeDownloadProgress()
            .receive(on: scheduler)
            .sink { progress in
                    let format = NSLocalizedString("Downloading %@ of %@", bundle: .core, comment: "Downloading 42 GB of 64 GB")
                    unownedSelf.progress = String.localizedStringWithFormat(
                        format,
                        progress.bytesDownloaded.humanReadableFileSize,
                        progress.bytesToDownload.humanReadableFileSize
                    )
                    unownedSelf.progressPercentage = progress.progress

                    if progress.isFinished, progress.error != nil {
                        unownedSelf.syncFailure = true
                    } else {
                        unownedSelf.syncFailure = false
                    }
            }
            .store(in: &subscriptions)
    }
}
