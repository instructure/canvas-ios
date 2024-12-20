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

import CombineExt
import UIKit

public extension UITabBarItem {

    // MARK: - Public Interface

    func makeUnavailableInOfflineMode(_ interactor: OfflineModeInteractor = OfflineModeAssembly.make()) {
        if interactor.isOfflineModeEnabled() {
            isEnabled = false
        }

        let observation = interactor
            .observeIsOfflineMode()
            .removeDuplicates()
            .map { !$0 }
            .assign(to: \.isEnabled, on: self, ownership: .weak)

        withUnsafePointer(to: &AssociatedObjectKeys.OfflineStateObservation) {
            objc_setAssociatedObject(self, $0, observation, .OBJC_ASSOCIATION_RETAIN)
        }
    }

    // MARK: - Private Methods

    private struct AssociatedObjectKeys {
        static var OfflineStateObservation = "OfflineStateObservation"
        static var TapGestureRecognizer = "TapGestureRecognizer"
    }
}
