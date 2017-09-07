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
import AVKit
import AVFoundation

// CREDIT: https://stackoverflow.com/a/24590678
extension UIView {
    fileprivate var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}

class VideoContainerView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required init?(coder aDecoder: NSCoder) { fatalError("nope") }
    
    weak var player: AVPlayerViewController?
    
    var source: Dictionary<String, Any> = [:] {
        didSet {
            setNeedsLayout()
        }
    }

    var paused = false {
        didSet {
            if paused {
                player?.player?.pause()
            }
        }
    }

    var playing = false {
        didSet {
            if playing {
                player?.player?.play()
            }
        }
    }

    var itemURL: URL? {
        let uri = source["uri"] as? String
        return uri.flatMap(URL.init)
    }
    
    func embedPlayer() {
        guard
            let parentVC = parentViewController,
            let itemURL = itemURL else {
            return
        }
        let player = AVPlayerViewController()
        player.player = AVPlayer(url: itemURL)
        parentVC.addChildViewController(player)
        addSubview(player.view)
        player.view.frame = bounds
        player.didMove(toParentViewController: parentVC)
        self.player = player
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if (player == nil) {
            embedPlayer()
        }
        
        if (player != nil) {
            player?.view.frame = bounds
        }
    }
}
