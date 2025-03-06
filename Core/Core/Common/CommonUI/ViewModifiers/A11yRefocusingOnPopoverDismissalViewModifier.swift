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

import Foundation
import Combine
import SwiftUI

struct A11yRefocusingOnPopoverDismissalViewModifier: ViewModifier {
    // Apple use this value for area where user can tap to dismiss pop-overs
    private static let popoverDismissRegionAccessibilityID = "PopoverDismissRegion"
    private static var lastFocused: String?

    @AccessibilityFocusState
    private var isAccFocused: Bool

    @State
    private var trackingPopoverID: String = Foundation.UUID().uuidString

    func body(content: Content) -> some View {
        content
            .accessibilityFocused($isAccFocused)
            .onChange(of: isAccFocused) { focused in
                if focused {
                    Self.lastFocused = trackingPopoverID
                }
            }
            .onReceive(didDismissPopover) {
                guard Self.lastFocused == trackingPopoverID else { return }

                isAccFocused = true
                Self.lastFocused = nil
            }
    }

    private var didDismissPopover: AnyPublisher<Void, Never> {
        NotificationCenter
            .default
            .publisher(for: UIAccessibility.elementFocusedNotification)
            .filter({ notification in
                guard let info = notification.userInfo,
                      let popupView = info[UIAccessibility.unfocusedElementUserInfoKey] as? UIAccessibilityElement
                else { return false }
                return popupView.accessibilityIdentifier == Self.popoverDismissRegionAccessibilityID
            })
            .mapToVoid()
            .eraseToAnyPublisher()
    }
}

// MARK: - View Helper

extension View {

    /// Refocuses VoiceOver after popover dismissal to the element which activated it. Common examples are `DatePicker`s & `Menu`s
    public func accessibilityRefocusingOnPopoverDismissal() -> some View {
        modifier(A11yRefocusingOnPopoverDismissalViewModifier())
    }
}
