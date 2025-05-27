//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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
import SwiftUI

public struct VideoPlayer: UIViewControllerRepresentable {
    public let url: URL?

    public init(url: URL?) {
        self.url = url
    }

    public func makeUIViewController(context: Self.Context) -> AVPlayerViewController {
        let uiViewController = AVPlayerViewController()
        let player = url.flatMap { AVPlayer(playerItem: $0.toPlayerItem()) }
        uiViewController.player = player ?? AVPlayer()
        return uiViewController
    }

    public func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Self.Context) {
        if url != (uiViewController.player?.currentItem?.asset as? AVURLAsset)?.url {
            uiViewController
                .player?
                .replaceCurrentItem(with: url?.toPlayerItem())
        }
    }
}
