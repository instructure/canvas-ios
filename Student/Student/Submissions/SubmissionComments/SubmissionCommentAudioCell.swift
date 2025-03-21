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

import AVKit
import UIKit
import Core

class SubmissionCommentAudioCell: UITableViewCell {
    @IBOutlet weak var containerView: UIView?

    let player = AudioPlayerViewController.create()

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .backgroundLightest
    }

    func update(comment: SubmissionComment, parent: UIViewController) {
        accessibilityIdentifier = "SubmissionComments.audioCell.\(comment.id)"

        guard let mediaURL = comment.mediaURL else { return } // The cell should always have a valid mediaURL
        player.accessibilityPrefix = "SubmissionComments.audioCell.\(comment.id)."
        player.load(url: mediaURL)
        if player.view?.superview == nil, let view = containerView {
            parent.embed(player, in: view)
        }
    }
}
