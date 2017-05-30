//
//  VideoContainerView.swift
//  Teacher
//
//  Created by Derrick Hathaway on 5/22/17.
//  Copyright © 2017 Instructure. All rights reserved.
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
            if (paused) {
                player?.player?.pause()
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
