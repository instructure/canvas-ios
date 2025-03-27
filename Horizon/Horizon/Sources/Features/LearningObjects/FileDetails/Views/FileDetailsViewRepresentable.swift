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
import HorizonUI
import Core

struct FileDetailsViewRepresentable: UIViewControllerRepresentable {
    // MARK: - Dependencies

    @Binding private var isScrollTopReached: Bool
    @Binding private var isFinishLoading: Bool
    @Binding private var contentHeight: CGFloat
    private let context: Core.Context?
    private let fileID: String
    private let isScrollEnabled: Bool

    init(isScrollTopReached: Binding<Bool>,
         isFinishLoading: Binding<Bool>,
         contentHeight: Binding<CGFloat> = .constant(0.0),
         context: Core.Context?,
         fileID: String,
         isScrollEnabled: Bool = true
    ) {
        self._isScrollTopReached = isScrollTopReached
        self._isFinishLoading = isFinishLoading
        self._contentHeight = contentHeight
        self.context = context
        self.fileID = fileID
        self.isScrollEnabled = isScrollEnabled
    }

    func makeUIViewController(context: Self.Context) -> UIViewController {
        let viewController = FileDetailsViewController.create(context: self.context, fileID: fileID)
        viewController.didFinishLoading = {
            isFinishLoading = true
            if let scrollView = findScrollView(in: viewController.view) {
                // Set the file pin at the top.
                scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
                scrollView.isScrollEnabled = isScrollEnabled
                // Wait till render the view
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    contentHeight = max(300, scrollView.contentSize.height)
                }
            } else {
                contentHeight = 300
            }
        }
        if let scrollView = findScrollView(in: viewController.view) {
            scrollView.delegate = context.coordinator
        }
        return viewController
    }

    func updateUIViewController(
        _ uiViewController: UIViewController,
        context: Self.Context
    ) {
        if let scrollView = findScrollView(in: uiViewController.view) {
            scrollView.delegate = context.coordinator
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator { value in
            isScrollTopReached = !value
        }
    }

    private func findScrollView(in view: UIView) -> UIScrollView? {
        if let scrollView = view as? UIScrollView {
            return scrollView
        }
        for subview in view.subviews {
            if let scrollView = findScrollView(in: subview) {
                return scrollView
            }
        }
        return nil
    }

    // MARK: - Coordinator

    final class Coordinator: NSObject, UIScrollViewDelegate {
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

        func scrollViewDidEndZooming(
            _ scrollView: UIScrollView,
            with view: UIView?,
            atScale scale: CGFloat
        ) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
                self?.isZoomingIn = false
            }
        }
    }
}
