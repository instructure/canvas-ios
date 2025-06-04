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

open class VisibilityObservedViewController: UIViewController {

    private var onAppearTask: (() -> Void)?
    private var isVisible: Bool = false

    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        isVisible = true
        onAppearTask?()
        onAppearTask = nil
    }

    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        isVisible = false
    }

    /// Calls the closure one time, either instantly if the ViewController is visible,
    /// or on the next appearance if not.
    public func onAppearOnce(_ taskBlock: @escaping () -> Void) {
        if isVisible {
            taskBlock()
        } else {
            onAppearTask = taskBlock
        }
    }
}
