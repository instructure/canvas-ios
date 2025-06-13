//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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

final class ScrollTrackingCoordinator: NSObject, UIScrollViewDelegate {
    private let threshold: CGFloat = 100
    private var lastYOffset: CGFloat = 0
    private var lastZoomScale: CGFloat = 1.0
    private let minDelta: CGFloat = 0.1
    private let minScrollThreshold: CGFloat = 5.0
    private var yOffsets: [CGFloat] = []

    var isZoomingIn = false
    let didScroll: (Bool) -> Void

    init(didScroll: @escaping (Bool) -> Void) {
        self.didScroll = didScroll
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let yOffset = scrollView.contentOffset.y.rounded()
        let delta = abs(yOffset - lastYOffset)

        guard delta > minScrollThreshold else { return }

        lastYOffset = yOffset
        yOffsets.append(yOffset)

        if yOffsets.count == 10 {
            let averageYOffset = yOffsets.reduce(0, +) / CGFloat(yOffsets.count)
            didScroll(isZoomingIn || averageYOffset > threshold)
            yOffsets.removeAll()
        }
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let zoomScale = scrollView.zoomScale
        guard abs(zoomScale - lastZoomScale) > minDelta else { return }

        isZoomingIn = zoomScale > 1
        lastZoomScale = zoomScale
    }

    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            self?.isZoomingIn = false
        }
    }
}
