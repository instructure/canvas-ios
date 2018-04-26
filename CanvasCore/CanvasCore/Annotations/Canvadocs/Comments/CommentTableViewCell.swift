//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
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
    
    func set(annotation: CanvadocsCommentReplyAnnotation, delegate: CommentTableViewCellDelegate) {
        self.annotation = annotation
        self.delegate = delegate
        userLabel.text = annotation.user
        commentLabel.text = annotation.contents
        deleteButton.isHidden = !annotation.isEditable || annotation.isDeleted
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

