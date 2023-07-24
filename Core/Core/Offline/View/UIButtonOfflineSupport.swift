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

extension UIButton {

    // MARK: - Public Interface

    public func makeUnavailableInOfflineMode(_ interactor: OfflineModeInteractor = OfflineModeInteractorLive.shared) {

        // This method is usually called in some setup method and it looks better if the button is instantly disabled
        // rather then animating to its disabled state while the view controller is animating in.
        if interactor.isOfflineModeEnabled() {
            setUnavailableState(isAnimated: false)
        }

        unowned let uSelf = self
        let observation = interactor
            .observeIsOfflineMode()
            .removeDuplicates()
            .sink { offlineMode in
                if offlineMode {
                    uSelf.setUnavailableState(isAnimated: true)
                } else {
                    uSelf.setAvailableState()
                }
            }
        objc_setAssociatedObject(self, &AssociatedObjectKeys.OfflineStateObservation, observation, .OBJC_ASSOCIATION_RETAIN)
    }

    // MARK: - Private Methods

    private struct AssociatedObjectKeys {
        static var OfflineStateObservation = "OfflineStateObservation"
        static var TapGestureRecognizer = "TapGestureRecognizer"
    }

    private func setUnavailableState(isAnimated: Bool) {
        UIView.animate(withDuration: isAnimated ? 0.3 : 0.0) {
            self.alpha = 0.3
        }

        // Extra safety not to add any more tap recognizers if one is already in place
        guard objc_getAssociatedObject(self, &AssociatedObjectKeys.TapGestureRecognizer) == nil else {
            return
        }

        let tapRecognizer = UITapGestureRecognizer(target: UIAlertController.self,
                                                   action: #selector(UIAlertController.showItemNotAvailableInOfflineAlert(sender:)))
        addGestureRecognizer(tapRecognizer)
        objc_setAssociatedObject(self, &AssociatedObjectKeys.TapGestureRecognizer, tapRecognizer, .OBJC_ASSOCIATION_RETAIN)
    }

    private func setAvailableState() {
        UIView.animate(withDuration: 0.3) {
            self.alpha = 1.0
        }

        guard let tapRecognizer = objc_getAssociatedObject(self, &AssociatedObjectKeys.TapGestureRecognizer) as? UIGestureRecognizer else {
            return
        }

        removeGestureRecognizer(tapRecognizer)
        objc_setAssociatedObject(self, &AssociatedObjectKeys.TapGestureRecognizer, nil, .OBJC_ASSOCIATION_ASSIGN)
    }
}
