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

/// When `overrideUserInterfaceStyle` is not `.unspecified` the builtin `UserInterfaceStyle` tracking is disabled.
/// Neither `traitCollectionDidChange()` is called nor callbacks via `registerForTraitChanges()`.
/// This class manages an observation for cases when the override needs to be changed.
public final class OverrideUserInterfaceStyleManager {
    public typealias StyleChangeHandler = (UIUserInterfaceStyle) -> Void

    private weak var host: UIView?
    private var additionalAction: StyleChangeHandler?
    private var observer: NSObjectProtocol?

    public init(host: UIView) {
        self.host = host
    }

    public convenience init(host: UIViewController) {
        self.init(host: host.view)
    }

    /// Starts the style change observation and sets the override style.
    /// Observation is started regardless of the current override style.
    public func setup(currentStyle: UIUserInterfaceStyle, additionalAction: StyleChangeHandler? = nil) {
        self.additionalAction = additionalAction
        startStyleChangeObservation()
        setOverrideStyle(currentStyle)
    }

    public func setOverrideStyle(_ style: UIUserInterfaceStyle) {
        host?.overrideUserInterfaceStyle = style
    }

    private func startStyleChangeObservation() {
        guard observer == nil else { return }

        observer = NotificationCenter.default.addObserver(
            forName: .windowUserInterfaceStyleDidChange,
            object: nil,
            queue: .main,
            using: { [weak self] notification in
                let style = notification.userInfo?["style"] as? UIUserInterfaceStyle ?? .unspecified
                self?.setOverrideStyle(style)
                self?.additionalAction?(style)
            }
        )
    }
}
