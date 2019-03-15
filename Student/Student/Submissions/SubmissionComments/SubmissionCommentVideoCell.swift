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

import AVKit
import UIKit
import Core

class SubmissionCommentVideoCell: UITableViewCell {
    @IBOutlet weak var containerView: UIView?

    var playerViewController: AVPlayerViewController = {
        let av = AVPlayerViewController()
        av.updatesNowPlayingInfoCenter = false
        return av
    }()

    deinit {
        playerViewController.unembed()
    }

    func update(comment: SubmissionComment, parent: UIViewController) {
        accessibilityIdentifier = "SubmissionCommentsElement.videoCell.\(comment.id)"
        accessibilityLabel = String.localizedStringWithFormat(
            NSLocalizedString("On %@ %@ left a video comment", bundle: .student, comment: ""),
            DateFormatter.localizedString(from: comment.createdAt, dateStyle: .long, timeStyle: .short),
            comment.authorName
        )

        playerViewController.player = comment.mediaURL.flatMap { AVPlayer(url: $0) }
        if playerViewController.view?.superview == nil, let view = containerView {
            parent.embed(playerViewController, in: view)
        }
    }
}
