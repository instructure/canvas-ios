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

class SubmissionCommentMediaCell: UITableViewCell {
    @IBOutlet weak var authorAvatarView: AvatarView?
    @IBOutlet weak var authorNameLabel: DynamicLabel?
    @IBOutlet weak var createdAtLabel: DynamicLabel?
    @IBOutlet weak var containerView: UIView?
    @IBOutlet weak var containerBottomConstraint: NSLayoutConstraint?
    @IBOutlet weak var containerHeightConstraint: NSLayoutConstraint?
    @IBOutlet weak var containerLeadingConstraint: NSLayoutConstraint?
    @IBOutlet weak var containerTopConstraint: NSLayoutConstraint?
    @IBOutlet weak var containerTrailingConstraint: NSLayoutConstraint?

    var playerViewController: AVPlayerViewController = {
        let av = AVPlayerViewController()
        av.updatesNowPlayingInfoCenter = false
        return av
    }()

    deinit {
        playerViewController.unembed()
    }

    func update(comment: SubmissionComment, parent: UIViewController) {
        accessibilityIdentifier = "SubmissionCommentsElement.audioCell.\(comment.id)"
        accessibilityLabel = String.localizedStringWithFormat(
            NSLocalizedString("On %@ %@ added a media comment", bundle: .student, comment: ""),
            DateFormatter.localizedString(from: comment.createdAt, dateStyle: .long, timeStyle: .short),
            comment.authorName
        )
        authorAvatarView?.name = comment.authorName
        authorAvatarView?.url = comment.authorAvatarURL
        authorNameLabel?.text = comment.authorName
        createdAtLabel?.text = DateFormatter.localizedString(from: comment.createdAt, dateStyle: .long, timeStyle: .short)

        let isAudio = comment.mediaType == .some(.audio)
        containerHeightConstraint?.constant = isAudio ? 44 : 160
        containerBottomConstraint?.constant = isAudio ? -6 : 0
        containerLeadingConstraint?.constant = isAudio ? -6 : 0
        containerTopConstraint?.constant = isAudio ? 0 : 4
        containerTrailingConstraint?.constant = isAudio ? -6 : 0

        contentView.transform = CGAffineTransform(scaleX: 1, y: -1)

        playerViewController.contentOverlayView?.backgroundColor = isAudio ? UIColor.named(.backgroundLightest) : nil
        playerViewController.player = comment.mediaURL.flatMap { AVPlayer(url: $0) }
        if playerViewController.view?.superview == nil, let view = containerView {
            parent.embed(playerViewController, in: view)
        }

        setNeedsLayout()
    }
}
