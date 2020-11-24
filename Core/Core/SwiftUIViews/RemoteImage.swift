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
    @State var loader: ImageLoader?
    @State var started: Bool = false
    @State var image: LoadedImage?
    @State var index = 0
    @State var repeatedCount = 0
    @State var timer: Timer?

    public init(_ url: URL, width: CGFloat, height: CGFloat) {
        self.url = url
        self.width = width
        self.height = height
    }

    public var body: some View {
        if let image = image?.image.images?[index] ?? image?.image {
            Image(uiImage: image.withRenderingMode(.alwaysOriginal))
                .resizable().scaledToFill()
                .frame(width: width, height: height)
        } else {
            Spacer()
                .frame(width: width, height: height)
                .onAppear(perform: load)
        }
    }

    func load() {
        guard !started else { return }
        started = true
        loader = ImageLoader(url: url, frame: CGRect(x: 0, y: 0, width: width, height: height)) { result in
            loader = nil
            guard case .success(let loaded) = result else { return }
            self.image = loaded
            if let count = loaded.image.images?.count, count > 0 {
                self.timer = Timer.scheduledTimer(withTimeInterval: loaded.image.duration / Double(count), repeats: true) { _ in
                    self.index = (self.index + 1) % count
                    guard self.index == 0 else { return }
                    self.repeatedCount += 1
                    guard loaded.repeatCount > 0, self.repeatedCount >= loaded.repeatCount else { return }
                    self.timer?.invalidate()
                    self.timer = nil
                    self.index = count - 1 // stay on end frame
                }
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
