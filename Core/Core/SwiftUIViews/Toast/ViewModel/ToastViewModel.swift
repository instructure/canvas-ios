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

import Combine
import SwiftUI

public class ToastViewModel: ObservableObject {
    public static let AnimationTime: CGFloat = 0.25
    public static let OnScreenTime: CGFloat = 2

    // MARK: - Outputs
    @Published public private(set) var visibleToast: String?

    // MARK: - Private State
    /** Even when `visibleToast` is nil the UI still needs some time to finish the disappear animation. This variable tracks if the animation has finished or not. */
    private var isToastOnScreen = false
    private var stack: [String] = []

    // MARK: - Inputs

    public func showToast(_ toast: String) {
        stack.append(toast)
        showNextToast()
    }

    public func toastDidDisappear() {
        isToastOnScreen = false
        visibleToast = nil
        showNextToast()
    }

    // MARK: - Private Methods

    private func showNextToast() {
        if stack.isEmpty || isToastOnScreen {
            return
        }

        let toast = stack.remove(at: 0)
        visibleToast = toast
        isToastOnScreen = true

        UIAccessibility.announce(toast)

        DispatchQueue.main.asyncAfter(deadline: .now() + Self.OnScreenTime + Self.AnimationTime) {
            self.visibleToast = nil
        }
    }
}

extension ToastViewModel: Equatable {
    public static func == (lhs: ToastViewModel, rhs: ToastViewModel) -> Bool {
        lhs.visibleToast == rhs.visibleToast
    }
}
