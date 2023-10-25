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

import mobile_offline_downloader_ios
import UIKit

extension ModuleItemCell {

    func prepareForDownload() {
        guard let item = item, let course = course else {
            return
        }
        let downloadButton = addDownloadButton()
        let canDonwload = downloadButtonHelper.canDownload(object: item)
        downloadButton.isHidden = !canDonwload || !reachability.isConnected

        guard !downloadButton.isHidden else {
            return
        }

        let userInfo = item.htmlURL?.changeScheme("ModuleItem")?.absoluteString ?? "ModuleItem://site.com/courses/\(course.id)/modules"
        downloadButtonHelper.update(
            object: item,
            course: course,
            userInfo: userInfo
        )
        downloadButtonHelper.status(
            for: item,
            onState: { [weak self] result in
                result.event.flatMap { event in
                    guard let self = self, result.eventObjectId == self.item?.id else {
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

                    debugLog(downloadButton.progress, "downloadButton.progress")
                    downloadButton.progress = Float(event.progress)
                    downloadButton.currentState = result.state

                    if result.state == .retry, event.isServerError {
                        downloadButton.retryButtonImage = UIImage(
                            systemName: "autostartstop.trianglebadge.exclamationmark",
                            withConfiguration: downloadButton.buttonConfiguration
                        )!
                    }

                    if result.state == .waiting {
                        downloadButton.waitingView.startSpinning()
                    }
                }
            }
        )
        downloadButton.onTap = { [weak self] state in
            guard let self = self, let item = self.item else {
                return
            }
            OfflineLogsMananger().logEventForState(state, itemURL: item.url?.absoluteString ?? "")
            switch state {
            case .downloaded:
                self.downloadButtonHelper.delete(object: item)
            case .downloading, .waiting:
                self.downloadButtonHelper.pause(object: item)
            case .retry:
                if downloadButtonHelper.isServerError {
                    onRetryServerError?(item)
                    return
                }
                self.downloadButtonHelper.resume(object: item)
            case .idle:
                self.downloadButtonHelper.download(object: item)
            }
        }
    }

    private func addDownloadButton() -> DownloadButton {
        removeDownloadButton()
        let downloadButton: DownloadButton = .init(frame: .zero)
        downloadButton.mainTintColor = course?.color ?? Brand.shared.linkColor
        downloadButton.currentState = .idle
        hStackView.addArrangedSubview(downloadButton)
        if let index = hStackView.arrangedSubviews.firstIndex(where: {$0 == completedStatusView}) {
            hStackView.insertArrangedSubview(downloadButton, at: index)
        } else {
            hStackView.addArrangedSubview(downloadButton)
        }
        downloadButton.translatesAutoresizingMaskIntoConstraints = false
        downloadButton.widthAnchor.constraint(equalToConstant: 35).isActive = true
        downloadButton.alpha = isUserInteractionEnabled ? 1.0 : 0.5
        return downloadButton
    }

    private func removeDownloadButton() {
        downloadButton()?.removeFromSuperview()
    }

    private func downloadButton() -> DownloadButton? {
        hStackView.arrangedSubviews.first(where: { $0 is DownloadButton }) as? DownloadButton
    }

    private func addSavedImage() {
        if !hStackView.arrangedSubviews.contains(where: { $0.tag == 888 }) {
            let imageView = UIImageView(image: .init(systemName: "checkmark.icloud"))
            imageView.tag = 888
            hStackView.addArrangedSubview(imageView)
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.widthAnchor.constraint(equalToConstant: 25).isActive = true
        }
    }

    private func removeSavedImage() {
        if let imageView = hStackView.arrangedSubviews.first(where: { $0.tag == 888 }) {
            imageView.removeFromSuperview()
        }
    }

    private func addActivityIndicator() -> UIActivityIndicatorView {
        if let activityIndicator = hStackView.arrangedSubviews.first(where: { $0.tag == 555 }) as? UIActivityIndicatorView {
            return activityIndicator
        } else {
            let activityIndicator = UIActivityIndicatorView()
            activityIndicator.color = .lightGray
            activityIndicator.tag = 555
            hStackView.addArrangedSubview(activityIndicator)
            activityIndicator.translatesAutoresizingMaskIntoConstraints = false
            activityIndicator.widthAnchor.constraint(equalToConstant: 25).isActive = true
            return activityIndicator
        }
    }

    private func removeActivityIndicator() {
        if let activityIndicator = hStackView.arrangedSubviews.first(where: { $0.tag == 555 }) {
            activityIndicator.removeFromSuperview()
        }
    }
}
