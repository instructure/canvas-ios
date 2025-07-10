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

import UIKit

public protocol VisibilityObservingViewController: UIViewController {
    var visibilityObservation: VisibilityObservation { get }
}

extension VisibilityObservingViewController {
    public var isVisible: Bool { visibilityObservation.isVisible }

    /// Calls the closure one time, either instantly if the ViewController is visible,
    /// or on the next appearance if not.
    public func onAppearOnce(_ block: @escaping () -> Void) {
        if visibilityObservation.isVisible {
            block()
        } else {
            visibilityObservation.appearTask = block
        }
    }
}

public class VisibilityObservation {

    fileprivate var appearTask: (() -> Void)?
    fileprivate var isVisible: Bool = false

    public init() {}

    func viewDidAppear() {
        isVisible = true
        appearTask?()
        appearTask = nil
    }

    func viewDidDisappear() {
        isVisible = false
    }
}

open class VisibilityObservedViewController: UIViewController, VisibilityObservingViewController {

    public private(set) var visibilityObservation = VisibilityObservation()

    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        visibilityObservation.viewDidAppear()
    }

    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        visibilityObservation.viewDidDisappear()
    }
}
