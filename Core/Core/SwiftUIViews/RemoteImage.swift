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

import SwiftUI

public struct RemoteImage: View {
    public let url: URL
    public let width: CGFloat
    public let height: CGFloat

    @State private var loader: ImageLoader?
    @State private var loadedURL: URL?
    @State private var image: LoadedImage?
    @State private var started: Bool = false

    @State private var currentFrameIndex = 0
    @State private var animationRepeatedCount = 0
    @State private var frameAnimationTimer: Timer?

    public init(_ url: URL, width: CGFloat, height: CGFloat) {
        self.url = url
        self.width = width
        self.height = height
    }

    public var body: some View {
        if let image = image?.image.images?[currentFrameIndex] ?? image?.image {
            let isURLChanged = (url.pathComponents != loadedURL?.pathComponents)

            if isURLChanged {
                emptyState.onAppear {
                    resetState()
                    load()
                }
            } else {
                Image(uiImage: image.withRenderingMode(.alwaysOriginal))
                    .resizable().scaledToFill()
                    .frame(width: width, height: height)
            }
        } else {
            emptyState.onAppear {
                load()
            }
        }
    }

    private var emptyState: some View {
        Spacer()
            .frame(width: width, height: height)
    }

    private func resetState() {
        frameAnimationTimer?.invalidate()
        frameAnimationTimer = nil
        loader?.cancel()
        loader = nil
        currentFrameIndex = 0
        animationRepeatedCount = 0
        started = false
        image = nil
    }

    private func load() {
        guard !started else { return }
        started = true
        let localURL = url // Create a local copy in case it changes while the previous image is still loading
        loader = ImageLoader(url: localURL, frame: CGRect(x: 0, y: 0, width: width, height: height)) { result in
            loader = nil
            guard case .success(let loaded) = result else { return }
            self.image = loaded
            self.loadedURL = localURL
            if let count = loaded.image.images?.count, count > 0 {
                let frameAnimationTimer = Timer(timeInterval: loaded.image.duration / Double(count), repeats: true) { _ in
                    self.currentFrameIndex = (self.currentFrameIndex + 1) % count
                    guard self.currentFrameIndex == 0 else { return }
                    self.animationRepeatedCount += 1
                    guard loaded.repeatCount > 0, self.animationRepeatedCount >= loaded.repeatCount else { return }
                    self.frameAnimationTimer?.invalidate()
                    self.frameAnimationTimer = nil
                    self.currentFrameIndex = count - 1 // stay on end frame
                }
                RunLoop.current.add(frameAnimationTimer, forMode: .common)
                self.frameAnimationTimer = frameAnimationTimer
            }
        }
        loader?.load()
    }
}

#if DEBUG
struct RemoteImage_Previews: PreviewProvider {
    @ViewBuilder
    static var previews: some View {
        RemoteImage(URL(string: "https://upload.wikimedia.org/wikipedia/commons/2/2c/Rotating_earth_%28large%29.gif")!, width: 200, height: 200)
    }
}
#endif
