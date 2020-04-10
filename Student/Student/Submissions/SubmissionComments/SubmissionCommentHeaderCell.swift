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

class SubmissionCommentHeaderCell: UITableViewCell {
    @IBOutlet weak var authorAvatarView: AvatarView?
    @IBOutlet weak var authorNameLabel: DynamicLabel?
    @IBOutlet weak var createdAtLabel: DynamicLabel?
    @IBOutlet weak var chatBubbleView: IconView?

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .named(.backgroundLightest)
    }

    func update(comment: SubmissionComment) {
        isAccessibilityElement = false
        accessibilityElementsHidden = true
        authorAvatarView?.name = comment.authorName
        authorAvatarView?.url = comment.authorAvatarURL
        authorNameLabel?.text = User.displayName(comment.authorName, pronouns: comment.authorPronouns)
        createdAtLabel?.text = comment.createdAtLocalizedString
        chatBubbleView?.isHidden = comment.attempt != nil || comment.mediaURL != nil
    }
}
