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

    typealias DownloadStatusProviderResult = (
        event: OfflineDownloadsManagerEventObject?,
        eventObjectId: String,
        state: DownloadButton.State
    )

    private let downloadsManager = OfflineDownloadsManager.shared
    private let storageManager = OfflineStorageManager.shared
    private let imageDownloader = ImageDownloader()

    private var object: OfflineDownloadTypeProtocol?
    private var course: Course?
    private var userInfo: String?
    private var cancellable: AnyCancellable?

    var isServerError: Bool = false

    func update(
        object: OfflineDownloadTypeProtocol?,
        course: Course?,
        userInfo: String?
    ) {
        self.object = object
        self.course = course
        self.userInfo = userInfo
        self.isServerError = false
    }

    func status(
        for object: OfflineDownloadTypeProtocol,
        onState: @escaping ((DownloadStatusProviderResult) -> Void)
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
                onState((nil, "", .idle))
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
        onState: @escaping ((DownloadStatusProviderResult) -> Void)

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
            self.isServerError = event.isServerError
            switch event.status {
            case .initialized, .preparing:
                onState((event, eventObjectId, .waiting))
            case .active:
                onState((event, eventObjectId, .downloading))
            case .completed, .partiallyDownloaded:
                onState((event, eventObjectId, .downloaded))
            case .failed, .paused:
                onState((event, eventObjectId, .retry))
            default:
                onState((event, eventObjectId, .idle))
            }
        } catch {
            onState((event, "", .idle))
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
