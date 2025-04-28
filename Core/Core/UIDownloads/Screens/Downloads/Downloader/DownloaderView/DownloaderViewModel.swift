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
import SwiftUI
import mobile_offline_downloader_ios

final class DownloaderViewModel: ObservableObject, Reachabilitable, DownloadsProgressBarHidden {

    // MARK: - Injection -

    @Injected(\.reachability) var reachability: ReachabilityProvider

    private var storageManager: OfflineStorageManager = .shared
    private var downloadsManager: OfflineDownloadsManager = .shared

    // MARK: - Properties -

    @Published var downloadingModules: [DownloadsModuleCellViewModel] = [] {
        didSet {
            isEmpty = downloadingModules.isEmpty
        }
    }
    @Published var error: String = ""
    @Published var deleting: Bool = false
    @Published var isConnected: Bool = true
    @Published var isActiveEntriesEmpty: Bool = false
    @Published var isEmpty: Bool = true

    var cancellables: Set<AnyCancellable> = Set<AnyCancellable>()

    private var activeEntries: [OfflineDownloaderEntry] {
        downloadsManager.activeEntries + downloadsManager.waitingEntries
    }

    private var pausedEntries: [OfflineDownloaderEntry] {
        downloadsManager.pausedEntries +
        downloadsManager.failedEntries +
        downloadsManager.serverErrors
    }

    init(downloadingModules: [DownloadsModuleCellViewModel]) {
        self.downloadingModules = downloadingModules
        configure()
    }

    // MARK: - Intents -

    func configure() {
        isConnected = reachability.isConnected
        addObservers()
        updateIsActiveEntriesEmpty()
    }

    func pauseResumeAll() {
        if isActiveEntriesEmpty {
            OfflineLogsMananger().logResumedAll()
            pausedEntries.forEach {
                downloadsManager.resume(entry: $0)
            }
        } else {
            OfflineLogsMananger().logPausedAll()
            activeEntries.forEach {
                downloadsManager.pause(entry: $0)
            }
        }
        toggleDownloadingBarView(hidden: true)
    }

    func deleteAll() {
        deleting = true
        OfflineLogsMananger().logDeleteAll()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            do {
                try self.downloadsManager.deleteDownloadingEntries()
                self.downloadingModules = []
            } catch {
                self.error = error.localizedDescription
            }
            self.deleting = false
        }
    }

    func delete(indexSet: IndexSet) {
        do {
            try indexSet.forEach { index in
                let model = downloadingModules[index]
                try downloadsManager.delete(entry: model.entry)
                downloadingModules.remove(at: index)
            }
        } catch {
            self.error = error.localizedDescription
        }
    }

    func resumeIfServerError(entry: OfflineDownloaderEntry) {
        downloadsManager.resume(entry: entry)
    }

    private func addObservers() {
        downloadsManager
            .publisher
            .sink { [weak self] event in
                guard let self = self else {
                    return
                }
                switch event {
                case .statusChanged(object: let event):
                    self.updateIsActiveEntriesEmpty()
                    self.statusChanged(event)
                case .progressChanged:
                    break
                }
            }
            .store(in: &cancellables)

        connection { [weak self] isConnected in
            self?.isConnected = isConnected
        }
    }

    private func statusChanged(_ event: OfflineDownloadsManagerEventObject) {
        if !event.isSupported {
            remove(event: event)
            return
        }

        switch event.status {
        case .completed, .removed, .partiallyDownloaded:
            remove(event: event)
        default:
            break
        }
    }

    private func remove(event: OfflineDownloadsManagerEventObject) {
        do {
            let object = event.object
            let model = try object.toOfflineModel()
            downloadingModules.removeAll(where: { $0.moduleId == model.id })
        } catch {
            self.error = error.localizedDescription
        }
    }

    private func pause(event: OfflineDownloadsManagerEventObject) {
        do {
            let object = event.object
            let model = try object.toOfflineModel()
            downloadingModules.removeAll(where: { $0.moduleId == model.id })
        } catch {
            self.error = error.localizedDescription
        }
    }

    private func updateIsActiveEntriesEmpty() {
        isActiveEntriesEmpty = activeEntries.isEmpty
    }
}
