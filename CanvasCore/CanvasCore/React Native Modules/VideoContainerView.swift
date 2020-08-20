//
// This file is part of Canvas.
// Copyright (C) 2017-present  Instructure, Inc.
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
import AVKit
import AVFoundation

// CREDIT: https://stackoverflow.com/a/24590678
extension UIView {
    var parentViewController: UIViewController? {
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

public class VideoContainerView: UIView {
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    public required init?(coder aDecoder: NSCoder) { fatalError("nope") }
    
    @objc weak var player: AVPlayerViewController?
    
    @objc
    var source: Dictionary<String, Any> = [:] {
        didSet {
            if let url = itemURL {
                player?.player?.replaceCurrentItem(with: AVPlayerItem(url: url))
            }
            setNeedsLayout()
        }
    }

    @objc
    var paused = false {
        didSet {
            if paused {
                player?.player?.pause()
            }
        }
    }

    @objc
    var playing = false {
        didSet {
            if playing {
                player?.player?.play()
            }
        }
    }

    @objc var itemURL: URL? {
        guard let uri = source["uri"] as? String else { return nil }
        if uri.hasPrefix("file://") {
            let path = String(uri.dropFirst(7))
            return URL(fileURLWithPath: path)
        }
        return URL(string: uri)
    }
    
    @objc func embedPlayer() {
        guard
            let parentVC = parentViewController,
            let itemURL = itemURL else {
            return
        }
        let player = AVPlayerViewController()
        player.player = AVPlayer(url: itemURL)
        parentVC.addChild(player)
        addSubview(player.view)
        player.view.frame = bounds
        player.didMove(toParent: parentVC)
        self.player = player
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        if (player == nil) {
            embedPlayer()
        }
        
        if (player != nil) {
            player?.view.frame = bounds
        }
    }
}
