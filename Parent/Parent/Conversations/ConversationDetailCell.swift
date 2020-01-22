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

import UIKit
import Core

class ConversationDetailCell: UITableViewCell {
    @IBOutlet weak var messageLabel: DynamicLabel!
    @IBOutlet weak var fromLabel: DynamicLabel!
    @IBOutlet weak var toLabel: DynamicLabel!
    @IBOutlet weak var dateLabel: DynamicLabel!
    @IBOutlet weak var avatar: AvatarView!
    @IBOutlet weak var stackview: UIStackView!
    @IBOutlet weak var attachmentStackView: HorizontalScrollingStackview!

    var onTapAttachment: ((File) -> Void)?
    var message: ConversationMessage?

    func update(_ message: ConversationMessage?, myID: String, userMap: [String: ConversationParticipant]) {
        guard let m = message else { return }
        self.message = m
        messageLabel.text = m.body
        toLabel.text = m.localizedAudience(myID: myID, userMap: userMap)
        fromLabel.text = userMap[ m.authorID ]?.name
        dateLabel.text = DateFormatter.localizedString(from: m.createdAt, dateStyle: .medium, timeStyle: .short)
        avatar.url = userMap[ m.authorID ]?.avatarURL
        avatar.name = userMap[ m.authorID ]?.name ?? ""

        handleAttachments(m.attachments)
    }

    func handleAttachments(_ attachments: [File]) {
        attachmentStackView.arrangedSubviews.forEach { v in v.removeFromSuperview() }
        attachmentStackView.isHidden = attachments.isEmpty == true
        if attachments.isEmpty == false {
            for (index, a) in  attachments.sorted(by: File.idCompare).enumerated() {
                let view = buildAttachmentView(attachment: a, atIndex: index)
                attachmentStackView.addArrangedSubview(view)
                NSLayoutConstraint.activate([
                    view.widthAnchor.constraint(equalToConstant: 120),
                    view.heightAnchor.constraint(equalToConstant: 104),
                ])
            }
            let leftAlignViewsSpacer = UIView()
            leftAlignViewsSpacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
            attachmentStackView.addArrangedSubview(leftAlignViewsSpacer)
        }
    }

    func buildAttachmentView(attachment: File, atIndex: Int) -> UIView {
        if let icon = attachment.icon, attachment.mimeClass != "image" {
            let view = NonPhotoAttachment()
            view.imageView.image = icon
            view.label.text = attachment.displayName
            view.button.addTarget(self, action: #selector(tapAttachment(sender:)), for: .primaryActionTriggered)
            view.button.tag = atIndex
            return view
        } else {
            let view = PhotoAttachment()
            view.imageView.load(url: attachment.previewURL ?? attachment.thumbnailURL ?? attachment.url)
            view.button.addTarget(self, action: #selector(tapAttachment(sender:)), for: .primaryActionTriggered)
            view.button.tag = atIndex
            return view
        }
    }

    @objc func tapAttachment(sender: UIButton) {
        guard message?.attachments.count ?? 0 > sender.tag,
            let attachment = message?.attachments[sender.tag] else { return }
        onTapAttachment?(attachment)
    }

    class PhotoAttachment: UIView {
        var imageView: UIImageView!
        var button: UIButton!

        override init(frame: CGRect) {
            super.init(frame: frame)
            commonInit()
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        func commonInit() {
            imageView = UIImageView()
            imageView.contentMode = .scaleAspectFill
            button = UIButton(type: .system)
            addSubview(imageView)
            addSubview(button)
            imageView.pin(inside: self)
            button.pin(inside: self)

            layer.cornerRadius = 4.0
            layer.masksToBounds = true
        }
    }

    class NonPhotoAttachment: UIView {
        var imageView: UIImageView!
        var button: UIButton!
        var label: DynamicLabel!

        override init(frame: CGRect) {
            super.init(frame: frame)
            commonInit()
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        func commonInit() {
            label = DynamicLabel()
            label.font = UIFont.scaledNamedFont(.regular14)
            label.lineBreakMode = .byTruncatingTail
            label.numberOfLines = 2
            label.textAlignment = .center
            imageView = UIImageView()
            imageView.contentMode = .scaleAspectFit
            button = UIButton(type: .system)
            addSubview(imageView)
            addSubview(label)
            addSubview(button)

            label.addConstraintsWithVFL("V:[view(>=21)]-(>=16)-|")
            label.addConstraintsWithVFL("H:|[view]|")

            imageView.addConstraintsWithVFL("V:[view(30)]-(8)-[label]", views: ["label": label])
            imageView.addConstraintsWithVFL("H:[view(30)]")
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true

            button.pin(inside: self)

            layer.borderColor = tintColor.cgColor
            layer.borderWidth = 1.0
            layer.cornerRadius = 4.0
        }
    }

}
