//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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
import UserNotifications
import UIKit

public enum KeyboardState {
    case willShow
    case shown
    case willHide
    case hidden
}

public protocol KeyboardObserving {
    var keyboardStatePublisher: AnyPublisher<KeyboardState, Never> { get }
}

public extension KeyboardObserving {
    var keyboardStatePublisher: AnyPublisher<KeyboardState, Never> {
        let center = NotificationCenter.default

        let willShow = center
            .publisher(for: UIResponder.keyboardWillShowNotification)
            .map({ _ in KeyboardState.willShow })

        let didShow = center
            .publisher(for: UIResponder.keyboardDidShowNotification)
            .map({ _ in KeyboardState.shown })

        let willHide = center
            .publisher(for: UIResponder.keyboardWillHideNotification)
            .map({ _ in KeyboardState.willHide })

        let didHide = center
            .publisher(for: UIResponder.keyboardDidHideNotification)
            .map({ _ in KeyboardState.hidden })

        return Publishers
            .Merge4(willShow, didShow, willHide, didHide)
            .eraseToAnyPublisher()
    }
}

/// Use this whenever you need quick access to keyboard state
/// without worrying about state publishing. Keyboard state is assumed
/// to be `hidden` when this object is initialized.
public class KeyboardObserved: KeyboardObserving {
    public private(set) var state: KeyboardState = .hidden
    private var subscription: AnyCancellable?

    public init() {
        subscription = keyboardStatePublisher.sink { [weak self] state in
            self?.state = state
        }
    }

    public var isShowing: Bool {
        switch state {
        case .willShow, .shown: return true
        case .willHide, .hidden: return false
        }
    }

    public var isHiding: Bool {
        isShowing == false
    }
}
