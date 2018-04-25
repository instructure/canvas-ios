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
    @IBOutlet var deleteButton: UIButton!
    
    var annotation = CanvadocsCommentReplyAnnotation()
    var delegate: CommentTableViewCellDelegate?
    
    func set(annotation: CanvadocsCommentReplyAnnotation, delegate: CommentTableViewCellDelegate) {
        self.annotation = annotation
        self.delegate = delegate
        userLabel.text = annotation.user
        commentLabel.text = annotation.contents
        deleteButton.isHidden = !annotation.isEditable
    }
    
    @IBAction func didTapDelete(_ sender: UIButton) {
        delegate?.didTapDelete(sender, reply: annotation)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
    }
}

