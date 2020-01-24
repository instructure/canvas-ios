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
    @IBOutlet weak var messageLabel: DynamicLabel!
    @IBOutlet weak var fromLabel: DynamicLabel!
    @IBOutlet weak var toLabel: DynamicLabel!
    @IBOutlet weak var dateLabel: DynamicLabel!
    @IBOutlet weak var avatar: AvatarView!
    @IBOutlet weak var audioPlayerContainer: UIView!
    @IBOutlet weak var attachmentStackView: HorizontalScrollingStackview!

    var audioPlayer: AudioPlayerViewController?
    var message: ConversationMessage?
    var onTapAttachment: ((URL) -> Void)?

    func update(_ message: ConversationMessage?, myID: String, userMap: [String: ConversationParticipant], parent: UIViewController) {
        guard let m = message else { return }
        self.message = m
        messageLabel.text = m.body
        toLabel.text = m.localizedAudience(myID: myID, userMap: userMap)
        fromLabel.text = userMap[ m.authorID ]?.name
        dateLabel.text = DateFormatter.localizedString(from: m.createdAt, dateStyle: .medium, timeStyle: .short)
        avatar.url = userMap[ m.authorID ]?.avatarURL
        avatar.name = userMap[ m.authorID ]?.name ?? ""

        handleAttachments(m.attachments, media: m.mediaComment, parent: parent)
    }

    func handleAttachments(_ attachments: [File], media: MediaComment?, parent: UIViewController) {
        attachmentStackView.arrangedSubviews.forEach { v in v.removeFromSuperview() }

        audioPlayerContainer.isHidden = true
        if /*media?.mediaType == .video,*/ let url = media?.url {
            addVideoAttachment(url: url, parent: parent)
        } else if media?.mediaType == .audio {
            addAudioPlayer(url: media?.url, parent: parent)
        }

        for (index, a) in attachments.sorted(by: File.idCompare).enumerated() {
            if a.mimeClass == "image" {
                addImageAttachment(index, name: a.displayName, url: a.previewURL ?? a.thumbnailURL)
            } else if a.mimeClass == "video", let url = a.url {
                addVideoAttachment(url: url, parent: parent)
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

    func addAudioPlayer(url: URL?, parent: UIViewController) {
        if audioPlayer == nil {
            let audioPlayer = AudioPlayerViewController.create()
            parent.embed(audioPlayer, in: audioPlayerContainer)
            self.audioPlayer = audioPlayer
        }
        audioPlayer?.load(url: url)
        audioPlayerContainer.isHidden = false
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

    func addVideoAttachment(url: URL, parent: UIViewController) {
        let container = UIView()
        container.layer.cornerRadius = 4.0
        container.layer.masksToBounds = true
        addAttachmentView(container)
        let controller = AVPlayerViewController()
        controller.entersFullScreenWhenPlaybackBegins = true
        controller.player = AVPlayer(url: url)
        parent.embed(controller, in: container)
    }

    @objc func tapAttachment(sender: UIButton) {
        guard message?.attachments.count ?? 0 > sender.tag else { return }
        guard let url = message?.attachments.sorted(by: File.idCompare)[sender.tag].url else { return }
        onTapAttachment?(url)
    }
}
