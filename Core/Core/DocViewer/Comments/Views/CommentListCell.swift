//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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
import PSPDFKit

protocol CommentListCellDelegate: AnyObject {
    func deletePressed(on: DocViewerCommentReplyAnnotation)
}

class CommentListCell: UITableViewCell {
    @IBOutlet weak var userLabel: DynamicLabel?
    @IBOutlet weak var commentLabel: DynamicLabel?
    @IBOutlet weak var removedLabel: DynamicLabel?
    @IBOutlet weak var deleteButton: DynamicButton?
    @IBOutlet weak var removedLabelHeightConstraint: NSLayoutConstraint!

    var comment = DocViewerCommentReplyAnnotation()
    weak var delegate: CommentListCellDelegate?

    func update(comment: DocViewerCommentReplyAnnotation, delegate: CommentListCellDelegate, metadata: APIDocViewerAnnotationsMetadata?) {
        accessibilityIdentifier = "CommentListItem.\(comment.name ?? "")"
        backgroundColor = .backgroundLightest
        self.comment = comment
        self.delegate = delegate
        userLabel?.text = comment.userName
        commentLabel?.text = comment.contents
        let isDeletable = metadata?.permissions == .readwritemanage || comment.isEditable
        deleteButton?.isHidden = !isDeletable || comment.isDeleted
        deleteButton?.accessibilityIdentifier = "CommentListItem.\(comment.name ?? "").deleteButton"
        deleteButton?.accessibilityLabel = String(localized: "Delete comment", bundle: .core)
        if comment.isDeleted {
            removedLabel?.isHidden = false
            removedLabelHeightConstraint?.constant = 19.5
            let date = DateFormatter.localizedString(from: comment.deletedAt ?? Date(), dateStyle: .medium, timeStyle: .none)
            if let deletedBy = comment.deletedBy ?? comment.deletedByID {
                let format = String(localized: "Removed %1$@ by %2$@", bundle: .core)
                removedLabel?.text = String.localizedStringWithFormat(format, date, deletedBy)
            } else {
                let format = String(localized: "Removed %1$@", bundle: .core)
                removedLabel?.text = String.localizedStringWithFormat(format, date)
            }
        } else {
            removedLabel?.isHidden = true
            removedLabelHeightConstraint?.constant = 0
        }
    }

    @IBAction func deletePressed(_ sender: UIButton) {
        delegate?.deletePressed(on: comment)
    }
}
