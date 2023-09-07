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

extension FileListCell {

    func prepareForDownload() {
        guard let file = file, let course = course else {
            return
        }
        let downloadButton = addDownloadButton()
        let canDonwload = downloadButtonHelper.canDownload(object: file)
        downloadButton.isHidden = !canDonwload || !reachability.isConnected

        guard !downloadButton.isHidden else {
            return
        }

        var url = file.url
        if let fileURL = url, DownloadsHelper.getCourseId(userInfo: fileURL.absoluteString) == nil {
            url = fileURL.appendingPathComponent("/courses/\(course.id)")
        }
        let userInfo = url?.changeScheme("File")?.absoluteString ?? "File://site.com/courses/\(course.id)/modules"
        downloadButtonHelper.update(
            object: file,
            course: course,
            userInfo: userInfo
        )
        downloadButtonHelper.status(
            for: file,
            onState: { [weak self] isSupported, state, progress, eventObjectId in
                guard let self = self, eventObjectId == self.file?.id else {
                    return
                }

                downloadButton.isUserInteractionEnabled = isSupported
                if isSupported {
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

                if !isSupported {
                    return
                }
                debugLog(downloadButton.progress, "downloadButton.progress")
                downloadButton.progress = Float(progress)
                downloadButton.currentState = state
                if state == .waiting {
                    downloadButton.waitingView.startSpinning()
                }
            }
        )
        downloadButton.onTap = { [weak self] state in
            guard let self = self, let file = self.file else {
                return
            }
            OfflineLogsMananger().logEventForState(state, itemURL: file.url?.absoluteString ?? "")
            switch state {
            case .downloaded:
                self.downloadButtonHelper.delete(object: file)
            case .downloading, .waiting:
                self.downloadButtonHelper.pause(object: file)
            case .retry:
                self.downloadButtonHelper.resume(object: file)
            case .idle:
                self.downloadButtonHelper.download(object: file)
            }
        }
    }

    func addDownloadButton() -> DownloadButton {
        let downloadButton: DownloadButton = .init(frame: .zero)
        downloadButton.mainTintColor = Brand.shared.linkColor
        downloadButton.currentState = .idle
        downloadButton.backgroundColor = .backgroundLightest
        contentView.addSubview(downloadButton)
        downloadButton.translatesAutoresizingMaskIntoConstraints = false
        downloadButton.widthAnchor.constraint(equalToConstant: 35).isActive = true
        downloadButton.heightAnchor.constraint(equalToConstant: 35).isActive = true
        downloadButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        downloadButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15).isActive = true
        return downloadButton
    }

    func removeDownloadButton() {
        downloadButton()?.removeFromSuperview()
    }

    func downloadButton() -> DownloadButton? {
        contentView.subviews.first(where: { $0 is DownloadButton }) as? DownloadButton
    }
}
