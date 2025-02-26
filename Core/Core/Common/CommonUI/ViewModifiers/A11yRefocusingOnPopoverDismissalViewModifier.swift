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
    static let popoverDismissRegionAccessibilityID = "PopoverDismissRegion"

    private static var latestFocused = [String]()

    @AccessibilityFocusState
    private var isAccFocused: Bool

    private let trackingPopoverID: String
    init(trackingPopoverID: String) {
        self.trackingPopoverID = trackingPopoverID
    }

    func body(content: Content) -> some View {
        content
            .accessibilityFocused($isAccFocused)
            .onChange(of: isAccFocused) { focused in
                if focused {
                    Self.latestFocused.append(trackingPopoverID)
                }
            }
            .onReceive(didDismissPopover) {
                guard Self.latestFocused.last == trackingPopoverID else { return }

                isAccFocused = true
                Self.latestFocused.removeAll()
            }
    }

    private var didDismissPopover: AnyPublisher<Void, Never> {
        NotificationCenter
            .default
            .publisher(for: UIAccessibility.elementFocusedNotification)
            .filter({ notif in
                guard let info = notif.userInfo,
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
    /// - parameters:
    ///    - trackingPopoverID: This ID is used to distinguish popover source when there are multiple elements on screen that can activate popovers. It is important to pass a distinct value even if you have only single element on screen that can activate popover.
    public func accessibilityRefocusingOnPopoverDismissal(_ trackingPopoverID: String) -> some View {
        modifier(
            A11yRefocusingOnPopoverDismissalViewModifier(
                trackingPopoverID: trackingPopoverID
            )
        )
    }
}
