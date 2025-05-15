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
    private let shouldHandleAnimatedGif: Bool

    @State private var loader: ImageLoader?
    @State private var loadedURL: URL?
    @State private var image: UIImage?
    @State private var animated: Bool = false
    @State private var started: Bool = false

    public init(_ url: URL, width: CGFloat, height: CGFloat, shouldHandleAnimatedGif: Bool = false) {
        self.url = url
        self.width = width
        self.height = height
        self.shouldHandleAnimatedGif = shouldHandleAnimatedGif
    }

    public init(_ url: URL, size: CGFloat, shouldHandleAnimatedGif: Bool = false) {
        self.init(url, width: size, height: size, shouldHandleAnimatedGif: shouldHandleAnimatedGif)
    }

    public var body: some View {
        VStack {
            let isURLChanged = url.pathComponents != loadedURL?.pathComponents
            let hasContent = image != nil || animated

            if hasContent && isURLChanged {
                emptyState.onAppear {
                    resetState()
                    load()
                }
            } else if let image {
                Image(uiImage: image.withRenderingMode(.alwaysOriginal))
                    .resizable().scaledToFill()
                    .frame(width: width, height: height)
            } else if animated {
                ImageWrapperWebView(url: url)
                    .frame(width: width, height: height)
            } else {
                emptyState.onAppear {
                    load()
                }
            }
        }
        .geometryGroup()
        .frame(width: width, height: height)
    }

    private var emptyState: some View {
        Spacer()
            .frame(width: width, height: height)
    }

    private func resetState() {
        loader?.cancel()
        loader = nil
        started = false
        image = nil
        animated = false
    }

    private func load() {
        guard !started else { return }
        started = true

        let localURL = url // Create a local copy in case it changes while the previous image is still loading
        let frame = CGRect(x: 0, y: 0, width: width, height: height)

        executeLoad(localURL: localURL, frame: frame, handleAnimatedGif: shouldHandleAnimatedGif)
    }

    private func executeLoad(localURL: URL, frame: CGRect, handleAnimatedGif: Bool) {
        loader = ImageLoader(url: localURL, frame: frame, shouldFailForAnimatedGif: handleAnimatedGif) { result in
            loader = nil

            if handleAnimatedGif {
                if result.error as? ImageLoaderError == .animatedGifFound {
                    animated = true
                    image = nil
                    loadedURL = localURL
                } else {
                    // load already cached UIImage
                    executeLoad(localURL: localURL, frame: frame, handleAnimatedGif: false)
                }
            } else {
                animated = false
                guard let image = result.value else { return }
                self.image = image
                self.loadedURL = localURL
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
