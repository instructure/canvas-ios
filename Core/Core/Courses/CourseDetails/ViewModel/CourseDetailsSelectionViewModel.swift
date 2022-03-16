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

import SwiftUI

public class CourseDetailsSelectionViewModel: ObservableObject {
    public weak var splitViewController: UISplitViewController? {
        didSet { splitViewChanged() }
    }
    @Published public private(set) var isHomeButtonHighlighted: Bool = false
    private var splitLayoutChangeListener: NSObjectProtocol?

    init() {
    }

    private func splitViewChanged() {
        guard let splitViewController = splitViewController else {
            splitLayoutChangeListener = nil
            return
        }

        subscribeToSplitViewChanges(splitViewController)
        update(isCollapsed: splitViewController.isCollapsed)
    }

    private func subscribeToSplitViewChanges(_ splitViewController: UISplitViewController) {
        splitLayoutChangeListener = NotificationCenter.default.addObserver(forName: UIViewController.showDetailTargetDidChangeNotification,
                                                                           object: splitViewController,
                                                                           queue: .main) { [weak self] in
            self?.splitViewLayoutNotificationReceived($0)
        }
    }

    private func splitViewLayoutNotificationReceived(_ notification: Notification) {
        guard let splitViewController = notification.object as? UISplitViewController else {
            return
        }

        update(isCollapsed: splitViewController.isCollapsed)
    }

    private func update(isCollapsed: Bool) {
        let isSplitMode = !isCollapsed

        isHomeButtonHighlighted = isSplitMode
    }
}
