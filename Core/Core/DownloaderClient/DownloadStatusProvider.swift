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
import mobile_offline_downloader_ios

final class DownloadStatusProvider: DownloadsProgressBarHidden {

    private let downloadsManager = OfflineDownloadsManager.shared
    private let storageManager = OfflineStorageManager.shared
    private let imageDownloader = ImageDownloader()

    private var object: OfflineDownloadTypeProtocol?
    private var course: Course?
    private var userInfo: String?
    private var cancellable: AnyCancellable?

    func update(
        object: OfflineDownloadTypeProtocol?,
        course: Course?,
        userInfo: String?
    ) {
        self.object = object
        self.course = course
        self.userInfo = userInfo
    }

    func status(
        for object: OfflineDownloadTypeProtocol,
        onState: @escaping ((Bool, DownloadButton.State, Double, String) -> Void)
    ) {
        downloadsManager.eventObject(for: object) { [weak self] result in
            guard let self = self else {
                return
            }
            result.success { event in
                self.statusChanged(
                    event: event,
                    onState: onState
                )
            }
            result.failure {  _ in
                onState(false, .idle, 0.0, "")
            }
        }

        cancellable = OfflineDownloadsManager.shared
            .publisher
            .sink { [weak self] event in
                switch event {
                case .statusChanged(object: let event):
                    self?.statusChanged(
                        event: event,
                        onState: onState
                    )
                case .progressChanged(object: let event):
                    self?.statusChanged(
                        event: event,
                        onState: onState
                    )
                }
            }
    }

    private func statusChanged(
        event: OfflineDownloadsManagerEventObject,
        onState: @escaping ((Bool, DownloadButton.State, Double, String) -> Void)

    ) {
        guard let object = self.object else {
            return
        }
        do {
            let eventObjectId = try event.object.toOfflineModel().id
            let objectId = try object.toOfflineModel().id
            guard eventObjectId == objectId else {
                return
            }
            switch event.status {
            case .initialized, .preparing:
                onState(event.isSupported, .waiting, event.progress, eventObjectId)
            case .active:
                onState(event.isSupported, .downloading, event.progress, eventObjectId)
            case .completed, .partiallyDownloaded:
                onState(event.isSupported, .downloaded, event.progress, eventObjectId)
            case .failed, .paused:
                onState(event.isSupported, .retry, event.progress, eventObjectId)
            default:
                onState(event.isSupported, .idle, event.progress, eventObjectId)
            }
        } catch {
            onState(event.isSupported, .idle, event.progress, "")
        }
    }

    func download(object: OfflineDownloadTypeProtocol) {
        do {
            guard let userInfo = self.userInfo else {
                return
            }
            try downloadsManager.start(
                object: object,
                userInfo: userInfo
            )
            addOrUpdateCourse()
            toggleDownloadingBarView(hidden: false)
        } catch {
            debugLog(error.localizedDescription)
        }
    }

    func delete(object: OfflineDownloadTypeProtocol) {
        do {
            try downloadsManager.delete(object: object)
        } catch {
            debugLog(error.localizedDescription)
        }
    }

    func pause(object: OfflineDownloadTypeProtocol) {
        do {
            try downloadsManager.pause(object: object)
        } catch {
            debugLog(error.localizedDescription)
        }
    }

    func resume(object: OfflineDownloadTypeProtocol) {
        do {
            try downloadsManager.resume(object: object)
        } catch {
            debugLog(error.localizedDescription)
        }
    }

    func canDownload(object: OfflineDownloadTypeProtocol) -> Bool {
        downloadsManager.canDownload(object: object)
    }

    private func addOrUpdateCourse() {
        guard let course = course else {
            return
        }

        let courseStorageDataModel = CourseStorageDataModel(
            course: course
        )
        if let imageDownloadURL = course.imageDownloadURL {
            imageDownloader.downloadImage(from: imageDownloadURL)
        }

        if course.courseColor == nil {
            course.courseColor = course.contextColor?.color.hexString
        }

        storageManager.save(courseStorageDataModel) { result in
            result.success {
                print("success")
            }
            result.failure { _ in
                print("failure")
            }
        }
    }
}
