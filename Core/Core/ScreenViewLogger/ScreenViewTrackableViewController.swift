//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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

import UIKit

public typealias ScreenViewTrackableViewController = ScreenViewTrackerViewController & ScreenViewTrackable
public typealias ScreenViewTrackableTableViewController = ScreenViewTrackerTableViewController & ScreenViewTrackable
public typealias ScreenViewTrackableHorizontalMenuViewController = HorizontalMenuViewController & ScreenViewTrackable

/// If you need to track a screen time on a view controller, don't inherit from this class directly. Use `ScreenViewTrackableViewController` instead
open class ScreenViewTrackerViewController: UIViewController {
    private var tracker: ScreenViewTracker?

    override open func viewDidLoad() {
        super.viewDidLoad()
        if let screenViewTrackable = self as? ScreenViewTrackable {
            tracker = ScreenViewTrackerLive(
                parameters: screenViewTrackable.screenViewTrackingParameters
            )
        }
    }

    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard tracker != nil else { return }
        tracker?.startTrackingTimeOnViewController()
    }

    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard tracker != nil else { return }
        tracker?.stopTrackingTimeOnViewController()
    }
}

/// If you need to track a screen time on a table view controller, don't inherit from this class directly. Use `ScreenViewTrackableTableViewController` instead
open class ScreenViewTrackerTableViewController: UITableViewController {
    private var tracker: ScreenViewTracker?

    override open func viewDidLoad() {
        super.viewDidLoad()
        if let screenViewTrackable = self as? ScreenViewTrackable {
            tracker = ScreenViewTrackerLive(
                parameters: screenViewTrackable.screenViewTrackingParameters
            )
        }
    }

    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard tracker != nil else { return }
        tracker?.startTrackingTimeOnViewController()
    }

    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard tracker != nil else { return }
        tracker?.stopTrackingTimeOnViewController()
    }
}
