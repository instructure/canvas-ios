//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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

import Combine
import UIKit

/**
 This class keeps track of a UISplitViewController's isCollapsed state. Useful when you have different logic inside a view depending on if it's in a split view environment or not.
 */
public class SplitViewModeObserver {
    public var isCollapsed: AnyPublisher<Bool, Never> { isCollapsedStateChange.removeDuplicates().eraseToAnyPublisher() }
    /** The external split viewcontroller to observe. */
    public weak var splitViewController: UISplitViewController? {
        didSet { splitViewChanged() }
    }
    private let isCollapsedStateChange = CurrentValueSubject<Bool, Never>(true)
    private var subscriptions = Set<AnyCancellable>()

    public init() {
    }

    private func splitViewChanged() {
        subscriptions.removeAll()

        guard let splitViewController = splitViewController else {
            isCollapsedStateChange.send(true)
            return
        }

        subscribeToSplitViewChanges(splitViewController)
        isCollapsedStateChange.send(splitViewController.isCollapsed)
    }

    private func subscribeToSplitViewChanges(_ splitViewController: UISplitViewController) {
        NotificationCenter
            .default
            .publisher(for: UIViewController.showDetailTargetDidChangeNotification, object: nil)
            .compactMap { [weak splitViewController] (notificationObject) -> UISplitViewController? in
                guard let changedSplitView = notificationObject.object as? UISplitViewController,
                      let splitViewController,
                      splitViewController == changedSplitView
                else { return nil }

                return splitViewController
            }
            .map { $0.isCollapsed }
            .subscribe(isCollapsedStateChange)
            .store(in: &subscriptions)
    }
}
