//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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
import WebKit

public class CoreWebVideoPictureInPictureInteractor {
    public static let shared = CoreWebVideoPictureInPictureInteractor()

    /// This is the webview that started the picture in picture playback,
    /// we store as a strong reference to keep it alive even if it was removed from the view hierarchy.
    private var webView: WKWebView?
    /// We store these references as weak because we don't want to influence these players' lifecycle that is managed by the OS.
    @WeakArray private var players: [AVPlayerViewController]
    private var timer: Timer?

    public init() {}

    public func webViewDidCloseFullscreenVideoPlayer(
        _ webView: WKWebView
    ) {
        let pictureInPictureVideoPlayers = webView.pictureInPictureVideoPlayers

        if pictureInPictureVideoPlayers.isPictureInPictureVideoClosed {
            return
        }

        self.webView = webView
        self.players = pictureInPictureVideoPlayers
        startObservingPictureInPictureModeExit()
    }

    private func startObservingPictureInPictureModeExit() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            guard let self else {
                return timer.invalidate()
            }
            releaseWebViewIfNoPictureInPicturePlaybackDetected()
        }
    }

    private func releaseWebViewIfNoPictureInPicturePlaybackDetected() {
        guard players.isPictureInPictureVideoClosed else {
            return
        }

        timer?.invalidate()
        timer = nil
        webView = nil
    }
}

private extension Array where Element == AVPlayerViewController {

    var isPictureInPictureVideoClosed: Bool {
        allSatisfy { player in
            player.parent == nil
        }
    }
}

private extension UIView {

    var pictureInPictureVideoPlayers: [AVPlayerViewController] {
        guard let windowScene = window?.windowScene else {
            return []
        }

        var players: [AVPlayerViewController] = []

        for window in windowScene.windows {
            guard let rootViewController = window.rootViewController else {
                continue
            }

            for childViewController in rootViewController.children {
                if let videoController = childViewController as? AVPlayerViewController {
                    players.append(videoController)
                }
            }
        }

        return players
    }
}
