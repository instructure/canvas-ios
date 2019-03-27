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

class SubmissionCommentAudioCell: UITableViewCell {
    @IBOutlet weak var containerView: UIView?
    @IBOutlet weak var loadingView: UIActivityIndicatorView?

    var loadObservation: NSKeyValueObservation?

    var playerViewController: AVPlayerViewController = {
        let av = AVPlayerViewController()
        av.updatesNowPlayingInfoCenter = false
        av.contentOverlayView?.backgroundColor = UIColor.named(.backgroundLightest)
        return av
    }()

    deinit {
        playerViewController.unembed()
    }

    func update(comment: SubmissionComment, parent: UIViewController) {
        accessibilityIdentifier = "SubmissionComments.audioCell.\(comment.id)"
        accessibilityLabel = String.localizedStringWithFormat(
            NSLocalizedString("On %@ %@ left an audio comment", bundle: .student, comment: ""),
            DateFormatter.localizedString(from: comment.createdAt, dateStyle: .long, timeStyle: .short),
            comment.authorName
        )

        containerView?.alpha = 0
        loadingView?.startAnimating()

        guard let mediaURL = comment.mediaURL else { return } // The cell should always have a valid mediaURL
        playerViewController.player = AVPlayer(url: mediaURL)
        loadObservation = playerViewController.player?.currentItem?.observe(\.status) { [weak self] (item: AVPlayerItem, _) in
            guard item.status != .unknown else { return }
            self?.loadObservation = nil
            UIView.animate(withDuration: 0.2, delay: 0.2, options: .curveLinear, animations: {
                self?.containerView?.alpha = 1
            }, completion: { _ in
                self?.loadingView?.stopAnimating()
            })
        }
        if playerViewController.view?.superview == nil, let view = containerView {
            parent.embed(playerViewController, in: view)
        }
    }
}
