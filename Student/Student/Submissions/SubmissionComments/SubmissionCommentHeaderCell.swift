//
// Copyright (C) 2019-present Instructure, Inc.
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
import Core

class SubmissionCommentHeaderCell: UITableViewCell {
    @IBOutlet weak var authorAvatarView: AvatarView?
    @IBOutlet weak var authorNameLabel: DynamicLabel?
    @IBOutlet weak var createdAtLabel: DynamicLabel?
    @IBOutlet weak var chatBubbleView: IconView?

    override func awakeFromNib() {
        super.awakeFromNib()
        chatBubbleView?.image = UIImage(named: "chatBubble", in: Bundle.core, compatibleWith: nil)
    }

    func update(comment: SubmissionComment) {
        isAccessibilityElement = false
        accessibilityElementsHidden = true
        authorAvatarView?.name = comment.authorName
        authorAvatarView?.url = comment.authorAvatarURL
        authorNameLabel?.text = comment.authorName
        createdAtLabel?.text = DateFormatter.localizedString(from: comment.createdAt, dateStyle: .long, timeStyle: .short)
        chatBubbleView?.isHidden = comment.attempt != nil || comment.mediaURL != nil
    }
}
