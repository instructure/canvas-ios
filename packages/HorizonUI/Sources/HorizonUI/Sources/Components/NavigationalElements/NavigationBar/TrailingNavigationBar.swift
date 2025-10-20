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

import SwiftUI

extension HorizonUI.NavigationBar {
    public struct Trailing<FocusValue: Hashable>: View {
        // MARK: - Dependencies

        private let hasUnreadNotification: Bool
        private let hasUnreadInboxMessage: Bool
        private let onNotebookDidTap: (() -> Void)?
        private let onNotificationDidTap: () -> Void
        private let onMailDidTap: () -> Void
        private let focusedButton: AccessibilityFocusState<FocusValue?>.Binding
        private let notebookFocusValue: FocusValue?
        private let notificationFocusValue: FocusValue?
        private let mailFocusValue: FocusValue?

        // MARK: - Init

        public init(
            hasUnreadNotification: Bool,
            hasUnreadInboxMessage: Bool,
            onNotebookDidTap: (() -> Void)? = nil,
            onNotificationDidTap: @escaping () -> Void,
            onMailDidTap: @escaping () -> Void,
            focusedButton: AccessibilityFocusState<FocusValue?>.Binding,
            notebookFocusValue: FocusValue? = nil,
            notificationFocusValue: FocusValue? = nil,
            mailFocusValue: FocusValue? = nil
        ) {
            self.hasUnreadNotification = hasUnreadNotification
            self.hasUnreadInboxMessage = hasUnreadInboxMessage
            self.onNotebookDidTap = onNotebookDidTap
            self.onNotificationDidTap = onNotificationDidTap
            self.onMailDidTap = onMailDidTap
            self.focusedButton = focusedButton
            self.notebookFocusValue = notebookFocusValue
            self.notificationFocusValue = notificationFocusValue
            self.mailFocusValue = mailFocusValue
        }

        public var body: some View {
            HStack(spacing: .huiSpaces.space8) {
                if let onNotebookDidTap = onNotebookDidTap {
                    ZStack {
                        HorizonUI.IconButton(
                            Image.huiIcons.menuBookNotebook,
                            type: .white
                        ) {
                            onNotebookDidTap()
                        }
                        .accessibilityLabel(String(localized: "Notebook"))
                    }
                    .dropShadow()
                    .accessibilityFocused(focusedButton, equals: notebookFocusValue)
                }

                ZStack(alignment: .topTrailing) {
                    HorizonUI.IconButton(
                        Image.huiIcons.notifications,
                        type: .white
                    ) {
                        onNotificationDidTap()
                    }
                    .accessibilityLabel(
                        Text(
                            hasUnreadNotification
                                ? String(localized: "Notifications, unread notifications available")
                                : String(localized: "Notifications")
                        )
                    )
                    if hasUnreadNotification {
                        HorizonUI.Badge(
                            type: .solidColor,
                            style: .custom(backgroundColor: .huiColors.surface.inversePrimary, foregroundColor: .clear)
                        )
                        .accessibilityHidden(true)
                    }
                }
                .dropShadow()
                .accessibilityFocused(focusedButton, equals: notificationFocusValue)

                ZStack(alignment: .topTrailing) {
                    HorizonUI.IconButton(
                        Image.huiIcons.mail,
                        type: .white
                    ) {
                        onMailDidTap()
                    }
                    .accessibilityLabel(
                        Text(
                            hasUnreadNotification
                                ? String(localized: "Inbox, unread messages available")
                                : String(localized: "Inbox")
                        )
                    )

                    if hasUnreadInboxMessage {
                        HorizonUI.Badge(
                            type: .solidColor,
                            style: .custom(backgroundColor: .huiColors.surface.inversePrimary, foregroundColor: .clear)
                        )
                        .accessibilityHidden(true)
                    }
                }
                .dropShadow()
                .accessibilityFocused(focusedButton, equals: mailFocusValue)
            }
        }
    }
}

extension HorizonUI.NavigationBar.Trailing where FocusValue == Int {
    public init(
        hasUnreadNotification: Bool,
        hasUnreadInboxMessage: Bool,
        onNotebookDidTap: (() -> Void)? = nil,
        onNotificationDidTap: @escaping () -> Void,
        onMailDidTap: @escaping () -> Void
    ) {
        @AccessibilityFocusState var dummyFocus: Int?
        self.hasUnreadNotification = hasUnreadNotification
        self.hasUnreadInboxMessage = hasUnreadInboxMessage
        self.onNotebookDidTap = onNotebookDidTap
        self.onNotificationDidTap = onNotificationDidTap
        self.onMailDidTap = onMailDidTap
        self.focusedButton = $dummyFocus
        self.notebookFocusValue = nil
        self.notificationFocusValue = nil
        self.mailFocusValue = nil
    }
}

#Preview {
    @Previewable @AccessibilityFocusState var focusedButton: String?
    HorizonUI.NavigationBar.Trailing(
        hasUnreadNotification: true,
        hasUnreadInboxMessage: true,
        onNotebookDidTap: {},
        onNotificationDidTap: {},
        onMailDidTap: {},
        focusedButton: $focusedButton,
        notebookFocusValue: "notebook",
        notificationFocusValue: "notification",
        mailFocusValue: "mail"
    )
}

fileprivate struct DropShadowModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .foregroundStyle(Color.huiColors.icon.default)
            .frame(width: 44, height: 44)
            .background {
                Rectangle()
                    .fill(Color.huiColors.surface.pageSecondary)
                    .huiCornerRadius(level: .level6)
                    .huiElevation(level: .level4)
            }
    }
}

extension View {
    fileprivate func dropShadow() -> some View {
        modifier(DropShadowModifier())
    }
}

extension HorizonUI {
    public struct NavigationBar {}
}
