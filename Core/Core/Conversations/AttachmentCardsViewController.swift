//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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

import AVKit
import Foundation
import UIKit

public class AttachmentCardsViewController: UIViewController {
    let stackView = HorizontalScrollingStackview()

    var attachments: [File] = []
    let env = AppEnvironment.shared
    var mediaComment: MediaComment?
    var showOptions: ((File) -> Void)?

    static func create() -> AttachmentCardsViewController {
        return AttachmentCardsViewController()
    }

    override public func loadView() {
        view = stackView
        stackView.scrollView.showsHorizontalScrollIndicator = false
        stackView.spacing = 12
        stackView.leadingPadding.constant = 16
        stackView.trailingPadding.constant = 16
    }

    func updateAttachments(_ attachments: [File], mediaComment: MediaComment? = nil) {
        self.attachments = attachments
        self.mediaComment = mediaComment
        var cardIndex = 0
        if let url = mediaComment?.url {
            let card = getCard(cardIndex)
            if mediaComment?.mediaType == .video {
                card.updateVideo(url, parent: self)
            } else {
                card.updateFile(name: mediaComment?.displayName, icon: .audioLine)
            }
            card.button?.addTarget(self, action: #selector(tapAttachment(sender:)), for: .primaryActionTriggered)
            card.tag = -1
            cardIndex += 1
        }

        for (index, a) in self.attachments.enumerated() {
            let card = getCard(cardIndex)
            if a.uploadError != nil {
                card.updateFile(name: NSLocalizedString("Failed. Tap for options", bundle: .core, comment: ""), icon: .warningLine)
                card.iconView?.tintColor = .textDanger
            } else if a.isUploading, a.size > 0 {
                card.updateProgress(name: a.displayName ?? a.localFileURL?.lastPathComponent, sent: a.bytesSent, of: a.size)
            } else if a.mimeClass == "image", let c = a.createdAt, Clock.now.timeIntervalSince(c) > 3600 {
                // Only use thumbnailURL if this image was created at least an hour ago,
                // so we don't get a blank thumbnail.
                card.updateImage(name: a.displayName, url: a.thumbnailURL ?? a.url)
            } else if a.mimeClass == "image" {
                card.updateImage(name: a.displayName, url: a.url)
            } else if a.mimeClass == "video", let url = a.url {
                card.updateVideo(url, parent: self)
            } else {
                card.updateFile(name: a.displayName, icon: a.icon)
            }
            card.button?.addTarget(self, action: #selector(tapAttachment(sender:)), for: .primaryActionTriggered)
            card.tag = index
            card.accessibilityIdentifier = "AttachmentCardView.\(index)"
            cardIndex += 1
        }

        stackView.arrangedSubviews.dropFirst(cardIndex).forEach { $0.removeFromSuperview() }
    }

    func getCard(_ index: Int) -> AttachmentCardView {
        if index < stackView.arrangedSubviews.count, let view = stackView.arrangedSubviews[index] as? AttachmentCardView {
            return view
        }
        let view = AttachmentCardView.create()
        if showOptions != nil {
            view.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(longPressAttachment(sender:))))
        }
        stackView.addArrangedSubview(view)
        return view
    }

    @objc func tapAttachment(sender: UIButton) {
        let tag = sender.superview?.tag ?? -1
        guard tag >= 0 else { return playAudio(mediaComment?.url) }

        guard attachments.count > tag else { return }
        let attachment = attachments[tag]
        if attachment.uploadError != nil || attachment.isUploading {
            showOptions?(attachment)
            return
        }
        guard let url = attachment.url else { return }
        if attachment.mimeClass == "audio" || attachment.contentType?.hasPrefix("audio/") == true {
            return playAudio(url)
        }
        env.router.route(to: url, from: self, options: .modal(embedInNav: true, addDoneButton: true))
    }

    @objc func longPressAttachment(sender: UILongPressGestureRecognizer) {
        guard let tag = sender.view?.tag, tag >= 0, attachments.count > tag else { return }
        showOptions?(attachments[tag])
    }

    func playAudio(_ url: URL?) {
        guard let url = url else { return }
        let controller = AVPlayerViewController()
        controller.player = AVPlayer(url: url)
        env.router.show(controller, from: self, options: .modal()) {
            controller.player?.play()
        }
    }
}

class AttachmentCardView: UIView {
    static func create() -> AttachmentCardView {
        let view = AttachmentCardView()
        view.layer.borderColor = UIColor.borderMedium.cgColor
        view.layer.cornerRadius = 4.0
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.widthAnchor.constraint(equalToConstant: 120),
            view.heightAnchor.constraint(equalToConstant: 104),
        ])
        return view
    }

    var button: UIButton?
    func getButton() -> UIButton {
        if let button = button { return button }
        let button = UIButton(type: .custom)
        addSubview(button)
        button.pin(inside: self)
        self.button = button
        button.isHidden = false
        return button
    }

    var fileStackView: UIStackView?
    var iconView: UIImageView?
    var nameLabel: UILabel?
    func updateFile(name: String?, icon: UIImage?) {
        layer.borderWidth = 1
        imageView?.isHidden = true
        playerController?.view.isHidden = true
        progressView?.isHidden = true
        let button = getButton()
        let stack = fileStackView ?? {
            let iconView = UIImageView()
            iconView.contentMode = .scaleAspectFit
            self.iconView = iconView
            let nameLabel = UILabel()
            nameLabel.font = .scaledNamedFont(.regular14)
            nameLabel.lineBreakMode = .byTruncatingTail
            nameLabel.numberOfLines = 2
            nameLabel.textAlignment = .center
            nameLabel.textColor = .textDarkest
            self.nameLabel = nameLabel
            let stack = UIStackView(arrangedSubviews: [ iconView, nameLabel ])
            stack.alignment = .center
            stack.axis = .vertical
            stack.isUserInteractionEnabled = false
            stack.spacing = 8
            button.addSubview(stack)
            stack.pin(inside: button, leading: 12, trailing: 12, top: nil, bottom: nil)
            NSLayoutConstraint.activate([
                iconView.heightAnchor.constraint(equalToConstant: 32),
                iconView.widthAnchor.constraint(equalToConstant: 32),
                stack.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            ])
            fileStackView = stack
            return stack
        }()
        button.accessibilityLabel = name
        stack.isHidden = false
        iconView?.image = icon
        iconView?.tintColor = Brand.shared.primary
        nameLabel?.text = name
    }

    var imageView: UIImageView?
    func updateImage(name: String?, url: URL?) {
        layer.borderWidth = 0
        fileStackView?.isHidden = true
        playerController?.view.isHidden = true
        progressView?.isHidden = true
        let button = getButton()
        let imageView = self.imageView ?? {
            let imageView = UIImageView()
            button.addSubview(imageView)
            imageView.contentMode = .scaleAspectFill
            imageView.pin(inside: button)
            imageView.isUserInteractionEnabled = false
            self.imageView = imageView
            return imageView
        }()
        button.accessibilityLabel = name
        imageView.isHidden = false
        imageView.load(url: url)
    }

    var progressView: CircleProgressView?
    var progressLabel: UILabel?
    var progressTimer: CADisplayLink?
    var startProgressTime = Clock.now
    var startProgressValue: Double = 0
    var endProgressValue: Double = 1
    func updateProgress(name: String?, sent: Int, of total: Int) {
        layer.borderWidth = 1
        fileStackView?.isHidden = true
        imageView?.isHidden = true
        playerController?.view.isHidden = true
        let button = getButton()
        let progressView = self.progressView ?? {
            let progressView = CircleProgressView()
            progressView.isUserInteractionEnabled = false
            button.addSubview(progressView)
            progressView.pin(inside: button, leading: 29, trailing: 29, top: 21, bottom: 21)
            let progressLabel = UILabel()
            progressLabel.font = .scaledNamedFont(.semibold14)
            progressLabel.lineBreakMode = .byClipping
            progressLabel.textAlignment = .center
            progressLabel.textColor = .textDarkest
            progressLabel.translatesAutoresizingMaskIntoConstraints = false
            progressView.addSubview(progressLabel)
            progressLabel.centerXAnchor.constraint(equalTo: progressView.centerXAnchor).isActive = true
            progressLabel.centerYAnchor.constraint(equalTo: progressView.centerYAnchor).isActive = true
            self.progressLabel = progressLabel
            self.progressView = progressView
            return progressView
        }()
        let progress = Double(sent) / Double(total)
        button.accessibilityLabel = String.localizedStringWithFormat(
            NSLocalizedString("Uploading %@ is at %@", bundle: .core, comment: ""),
            name ?? NSLocalizedString("File", bundle: .core, comment: ""),
            NumberFormatter.localizedString(from: NSNumber(value: progress), number: .percent)
        )
        progressView.isHidden = false

        progressTimer?.invalidate()
        progressTimer = CADisplayLink(target: self, selector: #selector(stepProgress))
        startProgressTime = Clock.now
        startProgressValue = Double(progressView.progress ?? 0)
        endProgressValue = progress
        progressTimer?.add(to: .current, forMode: .default)
        stepProgress()
    }

    @objc func stepProgress() {
        let duration: TimeInterval = 1
        let animStep = endProgressValue < startProgressValue ? 1
            : min(1, Clock.now.timeIntervalSince(startProgressTime) / duration)
        if animStep == 1 {
            progressTimer?.invalidate()
            progressTimer = nil
        }
        let t = 1 - pow(1 - animStep, 3) // easeOutCubic
        let progress = startProgressValue + (t * (endProgressValue - startProgressValue))
        progressView?.progress = CGFloat(progress)
        progressLabel?.text = NumberFormatter.localizedString(from: NSNumber(value: progress), number: .percent)
    }

    var playerController: AVPlayerViewController?
    func updateVideo(_ url: URL, parent: UIViewController) {
        layer.borderWidth = 0
        button?.isHidden = true
        let controller = playerController ?? {
            let controller = AVPlayerViewController()
            controller.entersFullScreenWhenPlaybackBegins = true
            controller.videoGravity = .resizeAspectFill
            parent.embed(controller, in: self)
            playerController = controller
            return controller
        }()
        controller.view.isHidden = false
        if url != (controller.player?.currentItem?.asset as? AVURLAsset)?.url {
            controller.player = AVPlayer(url: url)
        }
    }
}
