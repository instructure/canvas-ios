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
import Core

fileprivate struct ModuleItemViewRepresentable: UIViewControllerRepresentable {
    // MARK: - Dependencies

    @Binding private var isScrollTopReached: Bool
    private let viewController: UIViewController

    init(
        viewController: UIViewController,
        isScrollTopReached: Binding<Bool>
    ) {
        self.viewController = viewController
        self._isScrollTopReached = isScrollTopReached
    }

    func makeUIViewController(context: Self.Context) -> UIViewController {
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
        let didScroll: (Bool) -> Void
        private let threshold: CGFloat = 100

        init(didScroll: @escaping (Bool) -> Void) {
            self.didScroll = didScroll
        }

        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            let yOffset = scrollView.contentOffset.y
            didScroll(yOffset > threshold)
        }
    }
}

struct ModuleItemView: View {
    @State private var isShowHeader: Bool = true
    private let viewController: UIViewController

    init(viewController: UIViewController) {
        self.viewController = viewController
    }

    var body: some View {
        ModuleItemViewRepresentable(
            viewController: viewController,
            isScrollTopReached: $isShowHeader
        )
        .preference(key: HeaderVisibilityKey.self, value: isShowHeader)
    }
}
