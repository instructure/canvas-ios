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
        let viewController = FileDetailsViewController.create(context: self.context, fileID: fileID, environment: AppEnvironment.shared)
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

    func makeCoordinator() -> ScrollTrackingCoordinator {
        ScrollTrackingCoordinator { value in
            isScrollTopReached = !value
        }
    }

    private func findScrollView(in view: UIView) -> UIScrollView? {
        var maxScrollView: UIScrollView?
        var maxHeight: CGFloat = 0
        // We need to traverse all the scrollViews because files like PDFs may contain more than one,
        // and we want to get the one with the maximum height.
        func traverse(_ view: UIView) {
            if let scrollView = view as? UIScrollView {
                let height = scrollView.contentSize.height
                if height > maxHeight {
                    maxHeight = height
                    maxScrollView = scrollView
                }
            }

            for subview in view.subviews {
                traverse(subview)
            }
        }
        traverse(view)
        return maxScrollView
    }
}
