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
    /// When a button is disabled in offline mode this is the alpha component we apply to it.
    public static var DisabledInOfflineAlpha: CGFloat = 0.3

    // MARK: - Public Interface

    public func makeUnavailableInOfflineMode(_ interactor: OfflineModeInteractor = OfflineModeAssembly.make()) {

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
        withUnsafePointer(to: &AssociatedObjectKeys.OfflineStateObservation) {
            objc_setAssociatedObject(self, $0, observation, .OBJC_ASSOCIATION_RETAIN)
        }
    }

    // MARK: - Private Methods

    private struct AssociatedObjectKeys {
        static var OfflineStateObservation = "OfflineStateObservation"
        static var TapGestureRecognizer = "TapGestureRecognizer"
    }

    private func setUnavailableState(isAnimated: Bool) {
        UIView.animate(withDuration: isAnimated ? 0.3 : 0.0) {
            self.alpha = UIButton.DisabledInOfflineAlpha
        }

        // Extra safety not to add any more tap recognizers if one is already in place
        let unsafeTapRecognizer = withUnsafePointer(to: &AssociatedObjectKeys.TapGestureRecognizer) {
            objc_getAssociatedObject(self, $0)
        }

        guard unsafeTapRecognizer == nil else {
            return
        }

        let tapRecognizer = UITapGestureRecognizer(target: UIAlertController.self,
                                                   action: #selector(UIAlertController.showItemNotAvailableInOfflineAlert(sender:)))
        addGestureRecognizer(tapRecognizer)

        withUnsafePointer(to: &AssociatedObjectKeys.TapGestureRecognizer) {
            objc_setAssociatedObject(self, $0, tapRecognizer, .OBJC_ASSOCIATION_RETAIN)
        }
    }

    private func setAvailableState() {
        UIView.animate(withDuration: 0.3) {
            self.alpha = 1.0
        }

        let unsafeTapRecognizer = withUnsafePointer(to: &AssociatedObjectKeys.TapGestureRecognizer) {
            objc_getAssociatedObject(self, $0)
        }

        guard let tapRecognizer = unsafeTapRecognizer as? UIGestureRecognizer else {
            return
        }

        removeGestureRecognizer(tapRecognizer)

        withUnsafePointer(to: &AssociatedObjectKeys.TapGestureRecognizer) {
            objc_setAssociatedObject(self, $0, nil, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
}
