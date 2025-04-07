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
import mobile_offline_downloader_ios
import Combine
import UserNotifications

final class DownloadNotifier: Reachabilitable {

    @Injected(\.reachability) var reachability: ReachabilityProvider

    private var downloadsManager: OfflineDownloadsManager = .shared
    var cancellables: Set<AnyCancellable> = Set<AnyCancellable>()

    var canShowBanner: Bool = true
    var isConnected: Bool = true

    init() {
        addObservers()
    }

    private func addObservers() {
        downloadsManager.queuePublisher
            .sink { [weak self] event in
                guard let self = self else { return }
                switch event {
                case .completed(let success):
                    self.completion(success)
                default:
                    break
                }
            }
            .store(in: &cancellables)

        connection { [weak self] isConnected in
            self?.isConnected = isConnected
        }
    }

    private func completion(_ success: Bool) {
        if !success {
            notificationRequest(
                body: "An error occured while downloading"
            )
            return
        }

        guard self.canShowBanner, self.isConnected else {
            return
        }
        notificationRequest(
            body: "Modules have been saved and are available offline."
        )
    }

    private func notificationRequest(body: String) {
        DispatchQueue.main.async {
            let content = UNMutableNotificationContent()
            content.title = "Download Finished"
            content.body = body
            content.sound = UNNotificationSound.default

            let request = UNNotificationRequest(
                identifier: Foundation.UUID().uuidString,
                content: content,
                trigger: nil
            )
            _ = UNUserNotificationCenter.current().add(request)
        }
    }
}
