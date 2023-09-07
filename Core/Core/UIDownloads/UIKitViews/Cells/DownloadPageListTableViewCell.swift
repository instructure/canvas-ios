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
import UIKit
import mobile_offline_downloader_ios

final public class DownloadPageListTableViewCell: UITableViewCell {

    // MARK: - Injected -

    @Injected(\.reachability) var reachability: ReachabilityProvider
    private let storageManager = OfflineStorageManager.shared
    private let downloadsManager = OfflineDownloadsManager.shared

    // MARK: - Properties -

    private var cancellable: AnyCancellable?

    private var accessIconView: AccessIconView = .init(frame: .zero)

    private var titleLabel: UILabel = {
        let titleLabel =  UILabel()
        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = .textDarkest
        titleLabel.numberOfLines = 2
        return titleLabel
    }()

    private let dateLabel: UILabel = {
        let dateLabel = UILabel()
        dateLabel.font = .systemFont(ofSize: 16, weight: .medium)
        dateLabel.textColor = .textDark
        return dateLabel
    }()

    var downloadButtonHelper = DownloadStatusProvider()
    var page: Page?
    var course: Course?

    // MARK: - Init -

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configure()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configuration -

    private func configure() {
        backgroundColor = .backgroundLightest
        accessoryType = .disclosureIndicator
        [titleLabel, dateLabel, accessIconView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }

        layout()
        actions()
    }

    // MARK: - Layout -

    private func layout() {

        accessIconView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15).isActive = true
        accessIconView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        accessIconView.widthAnchor.constraint(equalToConstant: 24).isActive = true
        accessIconView.heightAnchor.constraint(equalToConstant: 24).isActive = true

        titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 60).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -60).isActive = true

        dateLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor).isActive = true
        dateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8).isActive = true
        dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 60).isActive = true
        dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -60).isActive = true
    }

    // MARK: - Action -

    private func actions() {}

    // MARK: - Intent -

    func update(page: Page?, course: Course?, indexPath: IndexPath, color: UIColor?) {
        self.page = page
        self.course = course
        selectedBackgroundView = ContextCellBackgroundView.create(color: color)
        titleLabel.accessibilityIdentifier = "PageList.\(indexPath.row)"
        accessIconView.icon = UIImage.documentLine
        accessIconView.published = page?.published == true
        let dateText = page?.lastUpdated.map { // TODO: page?.lastUpdated?.dateTimeString
            DateFormatter.localizedString(from: $0, dateStyle: .medium, timeStyle: .short)
        }
        dateLabel.setText(dateText, style: .textCellSupportingText)
        titleLabel.setText(page?.title, style: .textCellTitle)
        titleLabel.lineBreakMode = .byTruncatingTail
        prepareForDownload()
    }

    func prepareForDownload() {
        guard let page = page, let course = course else {
            return
        }
        let downloadButton = addDownloadButton()
        let canDonwload = downloadButtonHelper.canDownload(object: page)
        downloadButton.isHidden = !canDonwload || !reachability.isConnected

        guard !downloadButton.isHidden else {
            return
        }

        let userInfo = page.htmlURL?.changeScheme("Page")?.absoluteString ?? "Page://site.com/courses/\(course.id)/modules"
        downloadButtonHelper.update(
            object: page,
            course: course,
            userInfo: userInfo
        )
        downloadButtonHelper.status(
            for: page,
            onState: { [weak self] isSupported, state, progress, eventObjectId in
                guard let self = self, eventObjectId == self.page?.id else {
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
            guard let self = self, let page = self.page else {
                return
            }
            OfflineLogsMananger().logEventForState(state, itemURL: page.url)
            switch state {
            case .downloaded:
                self.downloadButtonHelper.delete(object: page)
            case .downloading, .waiting:
                self.downloadButtonHelper.pause(object: page)
            case .retry:
                self.downloadButtonHelper.resume(object: page)
            case .idle:
                self.downloadButtonHelper.download(object: page)
            }
        }
    }

    func addDownloadButton() -> DownloadButton {
        removeDownloadButton()
        let downloadButton: DownloadButton = .init(frame: .zero)
        downloadButton.mainTintColor = Brand.shared.linkColor
        downloadButton.currentState = .idle
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
