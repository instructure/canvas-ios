//
// Copyright (C) 2016-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//
    
    

import UIKit
import PSPDFKit

protocol CommentTableViewCellDelegate: class {
    func didTapDelete(_ sender: UIButton, reply: CanvadocsCommentReplyAnnotation)
}

class CommentTableViewCell: UITableViewCell {
    
    @IBOutlet var userLabel: UILabel!
    @IBOutlet var commentLabel: UILabel!
    @IBOutlet var removedLabel: UILabel!
    @IBOutlet var deleteButton: UIButton!
    @IBOutlet weak var removedLabelHeightConstraint: NSLayoutConstraint!
    
    var annotation = CanvadocsCommentReplyAnnotation()
    var delegate: CommentTableViewCellDelegate?
    
    func set(annotation: CanvadocsCommentReplyAnnotation, delegate: CommentTableViewCellDelegate, metadata: CanvadocsAnnotationMetadata) {
        self.annotation = annotation
        self.delegate = delegate
        userLabel.text = annotation.userName
        commentLabel.text = annotation.contents
        let isDeletable = (metadata.permissions ?? .None) == .ReadWriteManage || annotation.isEditable
        deleteButton.isHidden = !isDeletable || annotation.isDeleted
        if annotation.isDeleted {
            removedLabel.isHidden = false
            removedLabelHeightConstraint.constant = 17
            let date = DateFormatter.localizedString(from: annotation.deletedAt ?? Date(), dateStyle: .medium, timeStyle: .none)
            if let deletedBy = annotation.deletedBy ?? annotation.deletedByID {
                let format = NSLocalizedString("Removed %1$@ by %2$@", tableName: "Localizable", bundle: Bundle(for: type(of: self)), value: "", comment: "")
                removedLabel.text = String(format: format, date, deletedBy)
            } else {
                let format = NSLocalizedString("Removed %1$@", tableName: "Localizable", bundle: Bundle(for: type(of: self)), value: "", comment: "")
                removedLabel.text = String(format: format, date)
            }
        } else {
            removedLabel.isHidden = true
            removedLabelHeightConstraint.constant = 0
        }
    }
    
    @IBAction func didTapDelete(_ sender: UIButton) {
        delegate?.didTapDelete(sender, reply: annotation)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
    }
}

