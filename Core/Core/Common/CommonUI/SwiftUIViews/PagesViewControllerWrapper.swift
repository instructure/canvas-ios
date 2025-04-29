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

public struct PagesViewControllerWrapper: UIViewControllerRepresentable {
    var dataSource: PagesViewControllerDataSource?
    var delegate: PagesViewControllerDelegate?
    private var introspect: ((PagesViewController) -> Void)?

    public init(
        dataSource: PagesViewControllerDataSource? = nil,
        delegate: PagesViewControllerDelegate? = nil
    ) {
        self.dataSource = dataSource
        self.delegate = delegate
    }

    /// Use this method to receive a reference to the underlying `PagesViewController` instance.
    public func introspect(
        _ introspect: @escaping (PagesViewController) -> Void
    ) -> Self {
        var modified = self
        modified.introspect = introspect
        return modified
    }

    // MARK: - UIViewControllerRepresentable

    public func makeUIViewController(
        context: Self.Context
    ) -> PagesViewController {
        let pagesViewController = PagesViewController()
        pagesViewController.dataSource = dataSource
        pagesViewController.delegate = delegate
        return pagesViewController
    }

    public func updateUIViewController(
        _ uiViewController: PagesViewController,
        context: Self.Context
    ) {
        context.coordinator.notifyIntrospectListener(viewController: uiViewController)
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(view: self)
    }
}

extension PagesViewControllerWrapper {

    public class Coordinator {
        let view: PagesViewControllerWrapper
        /// This flag is used to prevent multiple calls to the introspect closure
        private var shouldNotifyIntrospectListener = true

        init(view: PagesViewControllerWrapper) {
            self.view = view
        }

        func notifyIntrospectListener(viewController: PagesViewController) {
            guard shouldNotifyIntrospectListener else { return }
            view.introspect?(viewController)
            shouldNotifyIntrospectListener = false
        }
    }
}
