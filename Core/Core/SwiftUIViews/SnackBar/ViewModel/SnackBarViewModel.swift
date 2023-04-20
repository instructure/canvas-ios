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

public class SnackBarViewModel: ObservableObject {
    public static let AnimationTime: CGFloat = 0.25
    public static let OnScreenTime: CGFloat = 2

    // MARK: - Outputs
    @Published public private(set) var visibleSnack: String?

    // MARK: - Private State
    /** Even when `visibleSnack` is nil the UI still needs some time to finish the disappear animation. This variable tracks if the animation has finished or not. */
    private var isSnackOnScreen = false
    private var stack: [String] = []

    // MARK: - Inputs

    public func showSnack(_ snack: String) {
        stack.append(snack)
        showNextSnack()
    }

    public func snackDidDisappear() {
        isSnackOnScreen = false
        visibleSnack = nil
        showNextSnack()
    }

    // MARK: - Private Methods

    private func showNextSnack() {
        if stack.isEmpty || isSnackOnScreen {
            return
        }

        let snack = stack.remove(at: 0)
        visibleSnack = snack
        isSnackOnScreen = true

        UIAccessibility.announce(snack)

        DispatchQueue.main.asyncAfter(deadline: .now() + Self.OnScreenTime + Self.AnimationTime) {
            self.visibleSnack = nil
        }
    }
}

extension SnackBarViewModel: Equatable {
    public static func == (lhs: SnackBarViewModel, rhs: SnackBarViewModel) -> Bool {
        lhs.visibleSnack == rhs.visibleSnack
    }
}
