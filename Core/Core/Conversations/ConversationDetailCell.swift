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

class ConversationDetailCell: UITableViewCell {
    @IBOutlet weak var messageLabel: UITextView!
    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var toLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var avatar: AvatarView!
    @IBOutlet weak var attachmentCardsContainer: UIView!
    let attachmentsController = AttachmentCardsViewController.create()

    var message: ConversationMessage?
    var parent: ConversationDetailViewController?

    func update(_ message: ConversationMessage?, myID: String, userMap: [String: ConversationParticipant], parent: ConversationDetailViewController) {
        guard let m = message, let createdAt = m.createdAt else { return }
        backgroundColor = .backgroundLightest
        self.message = m
        self.parent = parent
        messageLabel.text = m.body
        messageLabel.font = UIFont.scaledNamedFont(.medium14)
        messageLabel.textColor = UIColor.textDarkest
        messageLabel.sizeToFit()
        messageLabel.isScrollEnabled = false
        messageLabel.delegate = self

        toLabel.text = m.localizedAudience(myID: myID, userMap: userMap)
        fromLabel.text = userMap[ m.authorID ]?.displayName
        dateLabel.text = DateFormatter.localizedString(from: createdAt, dateStyle: .medium, timeStyle: .short)
        avatar.url = userMap[ m.authorID ]?.avatarURL
        avatar.name = userMap[ m.authorID ]?.name ?? ""

        if attachmentsController.view.superview == nil {
            parent.embed(attachmentsController, in: attachmentCardsContainer)
        }
        attachmentsController.updateAttachments(m.attachments, mediaComment: m.mediaComment)
        attachmentCardsContainer.isHidden = m.mediaComment == nil && m.attachments.isEmpty

        let template = NSLocalizedString("Message from %@, %@, on %@, %@", comment: "")
        accessibilityLabel = String.localizedStringWithFormat(template, fromLabel.text ?? "", toLabel.text ?? "", dateLabel.text ?? "", m.body)
        accessibilityIdentifier = "ConversationDetailCell.\(m.id)"
    }
}

extension ConversationDetailCell: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        guard let parent else { return true }
        AppEnvironment.shared.router.route(to: URL, from: parent)
        return false
    }
}
