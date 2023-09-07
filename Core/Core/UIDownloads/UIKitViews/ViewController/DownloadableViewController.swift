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

import UIKit
import SwiftUI
import Combine
import mobile_offline_downloader_ios

public class DownloadableViewController: UIViewController, ErrorViewController, DownloadsProgressBarHidden {

    deinit {
        print("☠️ Deinitialized -> \(String.init(describing: self))☠️")
        NotificationCenter.default.removeObserver(
            self,
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }

    // MARK: - Injected -

    @Injected(\.reachability) var reachability: ReachabilityProvider

    // MARK: - Properties -

    private let downloadsManager = OfflineDownloadsManager.shared
    private let storageManager = OfflineStorageManager.shared
    private var downloadableItem: DownloadableItem?

    private let imageDownloader = ImageDownloader()
    private let env = AppEnvironment.shared
    private var downloadsSubscriber: AnyCancellable?
    private var connectionSubscriber: AnyCancellable?

    private var willDisappearing: Bool = false

    public lazy var downloadButton: DownloadButton = {
        let downloadButton = DownloadButton()
        downloadButton.mainTintColor = .white
        downloadButton.currentState = .idle
        downloadButton.isHidden = true
        return downloadButton
    }()

    // MARK: - Lifecycle -

    public override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didBecomeActiveNotification),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configure()
    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        willDisappearing = true
    }

    // MARK: - Configuration -

    func set(downloadableItem: DownloadableItem) {
        if downloadableItem.objectId == self.downloadableItem?.objectId {
            return
        }
        self.downloadableItem = downloadableItem
        addObservers()
    }

    public func configure() {
        toggleDownloadingBarView(hidden: true)
        willDisappearing = false
        layout()
        actions()
    }

    public func actions() {
        downloadButton.onTap = { [weak self] state in
            guard let self = self else {
                return
            }
            OfflineLogsMananger().logEventForState(state, itemURL: self.downloadableItem?.userInfo ?? "")
            switch state {
            case .downloaded:
                self.delete()
            case .waiting, .downloading:
                self.pause()
            case .retry:
                do {
                    try self.downloadableItem.flatMap {
                        try self.downloadsManager.resume(object: $0.object)
                    }
                } catch {
                    showError(error)
                }
            case .idle:
                self.download()
            }
            self.toggleDownloadingBarView(hidden: true)
        }
    }

    // MARK: - Layout -

    public func layout() {
        attachDownloadButton()
    }

    public func attachDownloadButton() {
        if !reachability.isConnected {
            return
        }
        navigationItem.rightBarButtonItem = downloadBarButtonItem
    }

    // MARK: - Public Intents -

    public var downloadBarButtonItem: UIBarButtonItem {
        let rightBarButtonItem = UIBarButtonItem(customView: downloadButton)
        downloadButton.translatesAutoresizingMaskIntoConstraints = false
        downloadButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
        downloadButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        return rightBarButtonItem
    }

    // MARK: - Private Intents -

    private func download() {
        guard let downloadableItem = downloadableItem,
              let url = URL(string: downloadableItem.userInfo) else {
            return
        }
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        components?.scheme = downloadableItem.assetType
        do {
            try downloadsManager.start(
                object: downloadableItem.object,
                userInfo: components?.url?.absoluteString
            )
            addOrUpdateCourse()
            downloadButton.currentState = .waiting
        } catch {
            showError(error)
        }
    }

    private func addObservers() {
        guard let downloadableItem = downloadableItem,
              downloadsManager.canDownload(object: downloadableItem.object) else {
            downloadButton.isHidden = true
            return
        }

        downloadsSubscriber = downloadsManager
            .publisher
            .sink { [weak self] event in
                guard let self = self else {
                    return
                }
                if !self.willDisappearing {
                    self.toggleDownloadingBarView(hidden: true)
                }
                switch event {
                case .statusChanged(object: let event):
                    self.statusChanged(event)
                case .progressChanged(object: let event):
                    self.progressChanged(event)
                }
            }

        connectionSubscriber = reachability.newtorkReachabilityPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isConnected in
                self?.connection(isConnected)
            }

        downloadsManager.eventObject(for: downloadableItem.object) { [weak self] result in
            guard let self = self else {
                return
            }
            DispatchQueue.main.async {
                if !self.willDisappearing {
                    self.toggleDownloadingBarView(hidden: true)
                }
                result.success { event in
                    self.statusChanged(event)
                }
                result.failure { _ in
                    self.downloadButton.currentState = .idle
                }
                self.downloadButton.isHidden = false
            }
        }
    }

    @objc
    private func didBecomeActiveNotification() {
        if !downloadButton.isHidden, downloadButton.currentState == .waiting {
            downloadButton.waitingView.startSpinning()
        }
    }

    private func connection(_ isConnected: Bool) {
        guard let downloadableItem = downloadableItem else {
            return
        }

        if !downloadsManager.canDownload(object: downloadableItem.object) {
            downloadButton.isHidden = true
            return
        }
        downloadButton.isHidden = !isConnected
    }

    private func statusChanged(_ event: OfflineDownloadsManagerEventObject) {
        guard let object = downloadableItem?.object else {
            return
        }
        do {
            let eventObjectId = try event.object.toOfflineModel().id
            let objectId = try object.toOfflineModel().id
            guard eventObjectId == objectId else {
                return
            }

            downloadButton.isUserInteractionEnabled = event.isSupported
            if event.isSupported {
                downloadButton.defaultImageForStates()
            } else {
                downloadButton.currentState = .idle
                downloadButton.setImageForAllStates(
                    uiImage: UIImage(
                        systemName: "icloud.slash",
                        withConfiguration: UIImage.SymbolConfiguration(weight: .light)
                    ) ?? UIImage()
                )
            }

            if !event.isSupported {
                return
            }

            switch event.status {
            case .completed, .partiallyDownloaded:
                if downloadButton.currentState != .downloaded {
                    downloadButton.currentState = .downloaded
                }
            case .initialized, .preparing:
                if downloadButton.currentState != .waiting {
                    downloadButton.currentState = .waiting
                }
            case .active:
                if downloadButton.currentState != .downloading {
                    downloadButton.currentState = .downloading
                    downloadButton.progress = Float(event.progress)
                }
            case .removed:
                if downloadButton.currentState != .idle {
                    downloadButton.currentState = .idle
                }
            case .failed, .paused:
                if downloadButton.currentState != .retry {
                    downloadButton.currentState = .retry
                }
            default:
                downloadButton.currentState = .idle
            }
        } catch {
            showError(error)
        }
    }

    private func progressChanged(_ event: OfflineDownloadsManagerEventObject) {
        guard let object = downloadableItem?.object else {
            return
        }
        do {
            let eventObjectId = try event.object.toOfflineModel().id
            let objectId = try object.toOfflineModel().id
            guard eventObjectId == objectId else {
                return
            }
            if event.progress == 0.0 {
                return
            }
            downloadButton.progress = Float(event.progress)
        } catch {
            showError(error)
        }
    }

    private func addOrUpdateCourse() {
        guard let course = downloadableItem?.course else {
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

    private func pause() {
        guard let object = downloadableItem?.object else {
            return
        }
        do {
            try downloadsManager.pause(object: object)
        } catch {
            showError(error)
        }
    }

    private func delete() {
        guard let object = downloadableItem?.object else {
            return
        }
        do {
            try downloadsManager.delete(object: object)
        } catch {
            showError(error)
        }
    }
}
