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
import Combine
import mobile_offline_downloader_ios

public class DownloadingBarView: UIView, Reachabilitable {

    @Injected(\.reachability) var reachability: ReachabilityProvider

    private var downloadsManager: OfflineDownloadsManager = .shared
    private let downloadNotifier = DownloadNotifier()

    public var onTap: (() -> Void)?
    public var downloadContentOpened: Bool = false
    public var tabSelected: Int = 0 {
        didSet {
            downloadNotifier.canShowBanner = tabSelected != 0
        }
    }

    var cancellables: [AnyCancellable] = []

    private let titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = .systemFont(ofSize: 12)
        titleLabel.text = "Downloading"
        return titleLabel
    }()

    private let subtitleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = .systemFont(ofSize: 17, weight: .medium)
        titleLabel.text = ""
        return titleLabel
    }()

    private let procentLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = .systemFont(ofSize: 9, weight: .medium)
        titleLabel.text = ""
        return titleLabel
    }()

    private let progressView = CustomCircleProgressView(frame: .zero)
    var mustBeHidden: Bool = false

    public convenience init() {
        self.init(frame: .zero)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(hidden),
            name: .DownloadingBarViewHidden,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(show),
            name: .DownloadingBarViewShow,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onDownloadContentOpened),
            name: .DownloadContentOpened,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onDownloadContentClosed),
            name: .DownloadContentClosed,
            object: nil
        )
    }

    @objc
    public func hidden() {
        mustBeHidden = true
        isHidden = true
    }

    @objc
    public func show() {
        if !reachability.isConnected {
            return
        }
        if downloadsManager.activeEntries.isEmpty || downloadContentOpened || tabSelected != 0 {
            return
        }
        mustBeHidden = false
        isHidden = false
    }

    @objc
    public func onDownloadContentOpened() {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return
        }
        downloadContentOpened = true
    }

    @objc
    public func onDownloadContentClosed() {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return
        }
        downloadContentOpened = false
        show()
    }

    public func attach(tabBar: UITabBar, in superview: UIView) {
        isHidden = true
        backgroundColor = .tertiarySystemGroupedBackground

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        addGestureRecognizer(tap)

        superview.addSubview(self)
        translatesAutoresizingMaskIntoConstraints = false
        leftAnchor.constraint(equalTo: superview.leftAnchor).isActive = true
        rightAnchor.constraint(equalTo: superview.rightAnchor).isActive = true
        bottomAnchor.constraint(equalTo: tabBar.topAnchor).isActive = true
        heightAnchor.constraint(equalToConstant: 50).isActive = true

        attachProgressView()
        attachLabels()
        observeDownloadsEvents()
    }

    public func attach(in superview: UIView) {
        isHidden = true
        backgroundColor = .tertiarySystemGroupedBackground

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        addGestureRecognizer(tap)

        superview.addSubview(self)
        translatesAutoresizingMaskIntoConstraints = false
        leftAnchor.constraint(equalTo: superview.leftAnchor).isActive = true
        rightAnchor.constraint(equalTo: superview.rightAnchor).isActive = true
        bottomAnchor.constraint(equalTo: superview.bottomAnchor).isActive = true
        heightAnchor.constraint(equalToConstant: 50).isActive = true

        attachProgressView()
        attachLabels()
        observeDownloadsEvents()
    }

    private func attachProgressView() {
        addSubview(progressView)
        addSubview(procentLabel)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        procentLabel.translatesAutoresizingMaskIntoConstraints = false

        progressView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        progressView.heightAnchor.constraint(equalToConstant: 35).isActive = true
        progressView.widthAnchor.constraint(equalToConstant: 35).isActive = true
        progressView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15).isActive = true

        procentLabel.centerXAnchor.constraint(equalTo: progressView.centerXAnchor).isActive = true
        procentLabel.centerYAnchor.constraint(equalTo: progressView.centerYAnchor).isActive = true

        progressView.progress = 0.01
        progressView.mainTintColor = Brand.shared.linkColor
    }

    private func attachLabels() {
        [titleLabel, subtitleLabel].forEach(addSubview)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.topAnchor.constraint(equalTo: progressView.topAnchor).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: progressView.trailingAnchor, constant: 10).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15).isActive = true

        subtitleLabel.bottomAnchor.constraint(equalTo: progressView.bottomAnchor).isActive = true
        subtitleLabel.leadingAnchor.constraint(equalTo: progressView.trailingAnchor, constant: 10).isActive = true
        subtitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15).isActive = true
    }

    @objc
    private func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        onTap?()
    }

    private func observeDownloadsEvents() {
        update()
        downloadsManager
            .publisher
            .sink { [weak self] event in
                switch event {
                case .statusChanged(let event):
                    self?.update(event)
                case .progressChanged(let event):
                    self?.progressChanged(event)
                }
            }
            .store(in: &cancellables)

        connection { [weak self] isConnected in
            if isConnected {
                self?.show()
            } else {
                self?.hidden()
            }
        }

        downloadsManager.queuePublisher
            .sink { [weak self] event in
            switch event {
            case .completed:
                self?.mustBeHidden = false
            default:
                break
            }
        }
        .store(in: &cancellables)
    }

    private func update(_ event: OfflineDownloadsManagerEventObject? = nil) {
        isHidden = downloadsManager.activeEntries.isEmpty
        if mustBeHidden { isHidden = true }
        if let entry = downloadsManager.activeEntries.first {
            if let page = try? Page.fromOfflineModel(entry.dataModel) {
                subtitleLabel.text = page.title
            }
            if let moduleItem = try? ModuleItem.fromOfflineModel(entry.dataModel) {
                subtitleLabel.text = moduleItem.title
            }
            if let file = try? File.fromOfflineModel(entry.dataModel) {
                subtitleLabel.text = file.displayName ?? file.filename
            }
        }
    }

    private func progressChanged(_ event: OfflineDownloadsManagerEventObject) {
        do {
            let eventObjectId = try event.object.toOfflineModel().id
            let objectId = downloadsManager.activeEntries.first?.dataModel.id
            guard eventObjectId == objectId else {
                return
            }
            progressView.progress = Float(event.progress)
            procentLabel.text = "\(Int(round(event.progress * 100)))%"

            if event.progress == 1 {
                progressView.progress = 0.0
                procentLabel.text = "0%"
            }
        } catch {}
    }
}
