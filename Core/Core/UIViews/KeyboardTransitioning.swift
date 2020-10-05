//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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

/// To successfully avoid the keyboard, you need to animate a constraint in sync with the keyboard.
/// Initialize a `KeyboardTransitioning` in `viewDidAppear` and save it as a property.
public class KeyboardTransitioning {
    weak var view: UIView?
    weak var space: NSLayoutConstraint?
    var callback: (() -> Void)?

    public init(view: UIView?, space: NSLayoutConstraint?, callback: (() -> Void)? = nil) {
        self.view = view
        self.space = space
        self.callback = callback

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(_:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc func keyboardWillChangeFrame(_ notification: Notification) {
        guard
            let view = view, let space = space,
            let info = notification.userInfo as? [String: Any],
            let keyboardFrame = info[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
        else { return }
        let safe = space.firstAnchor == view.bottomAnchor ? 0 : view.safeAreaInsets.bottom
        let constant = max(0, view.bounds.height - safe - view.convert(keyboardFrame, from: nil).origin.y)
        guard
            let animationCurve = info[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt,
            let animationDuration = info[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval
        else {
            space.constant = constant
            view.layoutIfNeeded()
            return
        }
        UIView.animate(withDuration: animationDuration, delay: 0, options: .init(rawValue: animationCurve), animations: {
            space.constant = constant
            view.layoutIfNeeded()
        }, completion: nil)
    }
}
