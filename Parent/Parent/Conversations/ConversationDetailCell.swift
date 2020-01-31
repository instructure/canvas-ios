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
import UIKit
import Core

class ConversationDetailCell: UITableViewCell {
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var toLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var avatar: AvatarView!
    @IBOutlet weak var attachmentStackView: HorizontalScrollingStackview!

    var message: ConversationMessage?
    var parent: ConversationDetailViewController?

    func update(_ message: ConversationMessage?, myID: String, userMap: [String: ConversationParticipant], parent: ConversationDetailViewController) {
        guard let m = message else { return }
        self.message = m
        self.parent = parent
        messageLabel.text = m.body
        toLabel.text = m.localizedAudience(myID: myID, userMap: userMap)
        fromLabel.text = userMap[ m.authorID ]?.name
        dateLabel.text = DateFormatter.localizedString(from: m.createdAt, dateStyle: .medium, timeStyle: .short)
        avatar.url = userMap[ m.authorID ]?.avatarURL
        avatar.name = userMap[ m.authorID ]?.name ?? ""

        handleAttachments(m.attachments, media: m.mediaComment)

        let template = NSLocalizedString("Message from %@, %@, on %@, %@", comment: "")
        accessibilityLabel = String.localizedStringWithFormat(template, fromLabel.text ?? "", toLabel.text ?? "", dateLabel.text ?? "", m.body)
    }

    func handleAttachments(_ attachments: [File], media: MediaComment?) {
        attachmentStackView.arrangedSubviews.forEach { v in v.removeFromSuperview() }

        if media?.mediaType == .video, let url = media?.url {
            addVideoAttachment(url: url)
        } else if media?.mediaType == .audio, media?.url != nil {
            addFileAttachment(-1, name: media?.displayName, icon: .icon(.audio))
        }

        for (index, a) in attachments.sorted(by: File.idCompare).enumerated() {
            if a.mimeClass == "image" {
                addImageAttachment(index, name: a.displayName, url: a.previewURL ?? a.thumbnailURL)
            } else if a.mimeClass == "video", let url = a.url {
                addVideoAttachment(url: url)
            } else {
                addFileAttachment(index, name: a.displayName, icon: a.icon)
            }
        }

        if !attachmentStackView.arrangedSubviews.isEmpty {
            let leftAlignViewsSpacer = UIView()
            leftAlignViewsSpacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
            attachmentStackView.addArrangedSubview(leftAlignViewsSpacer)
            attachmentStackView.isHidden = false
        } else {
            attachmentStackView.isHidden = true
        }
    }

    func addAttachmentView(_ view: UIView) {
        attachmentStackView.addArrangedSubview(view)
        NSLayoutConstraint.activate([
            view.widthAnchor.constraint(equalToConstant: 120),
            view.heightAnchor.constraint(equalToConstant: 104),
        ])
    }

    func addFileAttachment(_ index: Int, name: String?, icon: UIImage?) {
        let button = UIButton(type: .custom)
        button.accessibilityLabel = name
        button.addTarget(self, action: #selector(tapAttachment(sender:)), for: .primaryActionTriggered)
        button.layer.borderColor = UIColor.named(.borderMedium).cgColor
        button.layer.borderWidth = 1.0
        button.layer.cornerRadius = 4.0
        button.tag = index
        let imageView = UIImageView(image: icon)
        imageView.contentMode = .scaleAspectFit
        let nameLabel = UILabel()
        nameLabel.font = .scaledNamedFont(.regular14)
        nameLabel.lineBreakMode = .byTruncatingTail
        nameLabel.numberOfLines = 2
        nameLabel.textAlignment = .center
        nameLabel.text = name
        let stack = UIStackView(arrangedSubviews: [ imageView, nameLabel ])
        stack.alignment = .center
        stack.axis = .vertical
        stack.isUserInteractionEnabled = false
        stack.spacing = 8
        button.addSubview(stack)
        stack.pin(inside: button, leading: 12, trailing: 12, top: nil, bottom: nil)
        NSLayoutConstraint.activate([
            imageView.heightAnchor.constraint(equalToConstant: 32),
            imageView.widthAnchor.constraint(equalToConstant: 32),
            stack.centerYAnchor.constraint(equalTo: button.centerYAnchor),
        ])
        addAttachmentView(button)
    }

    func addImageAttachment(_ index: Int, name: String?, url: URL?) {
        let button = UIButton(type: .custom)
        button.accessibilityLabel = name
        button.addTarget(self, action: #selector(tapAttachment(sender:)), for: .primaryActionTriggered)
        button.layer.cornerRadius = 4.0
        button.layer.masksToBounds = true
        button.tag = index
        let imageView = UIImageView()
        button.addSubview(imageView)
        imageView.contentMode = .scaleAspectFill
        imageView.pin(inside: button)
        imageView.isUserInteractionEnabled = false
        addAttachmentView(button)
        imageView.load(url: url)
    }

    func addVideoAttachment(url: URL) {
        let container = UIView()
        container.layer.cornerRadius = 4.0
        container.layer.masksToBounds = true
        addAttachmentView(container)
        let controller = AVPlayerViewController()
        controller.entersFullScreenWhenPlaybackBegins = true
        controller.player = AVPlayer(url: url)
        controller.videoGravity = .resizeAspectFill
        parent?.embed(controller, in: container)
    }

    @objc func tapAttachment(sender: UIButton) {
        guard sender.tag >= 0 else { return playAudio(url: message?.mediaComment?.url) }

        guard
            let parent = parent, message?.attachments.count ?? 0 > sender.tag,
            let attachment = message?.attachments.sorted(by: File.idCompare)[sender.tag],
            let url = attachment.url
        else { return }
        if attachment.mimeClass == "audio" || attachment.contentType?.hasPrefix("audio/") == true {
            return playAudio(url: attachment.url)
        }
        parent.env.router.route(to: url, from: parent, options: .modal(embedInNav: true, addDoneButton: true))
    }

    func playAudio(url: URL?) {
        guard let parent = parent, let url = url else { return }
        let controller = AVPlayerViewController()
        controller.player = AVPlayer(url: url)
        parent.env.router.show(controller, from: parent, options: .modal()) {
            controller.player?.play()
        }
    }
}
