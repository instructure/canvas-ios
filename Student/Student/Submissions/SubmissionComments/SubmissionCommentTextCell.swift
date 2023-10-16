//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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

class SubmissionCommentTextCell: UITableViewCell {
    @IBOutlet weak var commentLabel: DynamicLabel?
    @IBOutlet weak var chatBubbleView: IconView?
    @IBOutlet weak var attachmentsStackView: UIStackView?

    var onTapAttachment: ((File) -> Void)?
    private var comment: SubmissionComment?

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .backgroundLightest
    }

    func update(comment: SubmissionComment) {
        guard !comment.isFault else { return }
        self.comment = comment
        accessibilityIdentifier = "SubmissionComments.textCell.\(comment.id)"
        accessibilityLabel = String.localizedStringWithFormat(
            NSLocalizedString("On %@ %@ commented \"%@\"", bundle: .student, comment: ""),
            comment.createdAtLocalizedString,
            comment.authorName,
            comment.comment
        )
        commentLabel?.setText(comment.comment, lineHeight: .body)

        attachmentsStackView?.arrangedSubviews.forEach { subview in
            attachmentsStackView?.removeArrangedSubview(subview)
            subview.removeFromSuperview()
        }
        comment.attachments?.sorted(by: File.idCompare).enumerated().forEach { index, attachment in
            let color = Brand.shared.linkColor
            let button = UIButton(type: .system)
            var config = UIButton.Configuration.plain()
            config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 8)
            config.imagePadding = 4
            config.titleLineBreakMode = .byTruncatingTail
            config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
                var outcoming = incoming
                outcoming.font = UIFont.scaledNamedFont(.medium14)
                return outcoming
            }
            button.configuration = config

            button.setImage(UIImage.paperclipLine.withRenderingMode(.alwaysTemplate), for: .normal)
            button.tintColor = color
            button.imageView?.contentMode = .scaleAspectFit
            button.setTitle(attachment.displayName, for: .normal)
            button.setTitleColor(color, for: .normal)

            button.layer.cornerRadius = 4
            button.layer.borderColor = UIColor.borderMedium.ensureContrast(against: .white).cgColor
            button.layer.borderWidth = 1
            button.tag = index
            button.addTarget(self, action: #selector(tapAttachment(sender:)), for: .touchUpInside)
            attachmentsStackView?.addArrangedSubview(button)
        }
    }

    @objc func tapAttachment(sender: UIButton) {
        guard let attachments = comment?.attachments.flatMap(Array.init) else { return }
        onTapAttachment?(attachments[sender.tag])
    }
}
