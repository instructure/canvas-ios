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

extension InstUI {

    public struct NavigationBarButton: View {
        @Environment(\.isEnabled) private var isEnabledViaEnvironment: Bool

        internal let action: () -> Void

        @ViewBuilder private let label: () -> AnyView
        private let isBackgroundContextColor: Bool
        private let isEnabledOverride: Bool?
        private let isAvailableOffline: Bool
        private let menuContent: AnyView?
        private let a11yIdentifier: String?

        private var isEnabled: Bool {
            isEnabledOverride ?? isEnabledViaEnvironment
        }

        /// Designated init.
        public init(
            isBackgroundContextColor: Bool = false,
            isEnabled isEnabledOverride: Bool? = nil,
            isAvailableOffline: Bool = true,
            a11yIdentifier: String? = nil,
            action: @escaping () -> Void,
            menuContent: AnyView? = nil,
            label: @escaping () -> AnyView
        ) {
            self.label = label
            self.isBackgroundContextColor = isBackgroundContextColor
            self.isEnabledOverride = isEnabledOverride
            self.isAvailableOffline = isAvailableOffline
            self.action = action
            self.menuContent = menuContent
            self.a11yIdentifier = a11yIdentifier
        }

        public var body: some View {
            button
                .foregroundStyle(color)
                .environment(\.isEnabled, isEnabled)
                .accessibilityIdentifier(a11yIdentifier)
        }

        @ViewBuilder
        private var button: some View {
            if let menuContent {
                if isAvailableOffline {
                    Menu(content: { menuContent }, label: label)
                } else {
                    OfflineObservingMenu(content: { menuContent }, label: label)
                }
            } else {
                if isAvailableOffline {
                    Button(action: action, label: label)
                } else {
                    OfflineObservingButton(action: action, label: label)
                }
            }
        }

        private var color: Color {
            if isBackgroundContextColor {
                isEnabled ? .textLightest : .disabledGray
            } else {
                isEnabled ? .textDarkest : .disabledGray
            }
        }
    }
}

extension InstUI.NavigationBarButton {
    /// Button with text label.
    public init(
        isBackgroundContextColor: Bool = false,
        isEnabled isEnabledOverride: Bool? = nil,
        isAvailableOffline: Bool = true,
        title: String,
        a11yIdentifier: String? = nil,
        action: @escaping () -> Void
    ) {
        self.init(
            isBackgroundContextColor: isBackgroundContextColor,
            isEnabled: isEnabledOverride,
            isAvailableOffline: isAvailableOffline,
            a11yIdentifier: a11yIdentifier,
            action: action
        ) {
            AnyView(Text(title).font(.regular16, lineHeight: .fit))
        }
    }

    /// Button with image label.
    public init(
        isBackgroundContextColor: Bool = false,
        isEnabled isEnabledOverride: Bool? = nil,
        isAvailableOffline: Bool = true,
        image: Image,
        accessibilityLabel: String,
        action: @escaping () -> Void
    ) {
        self.init(
            isBackgroundContextColor: isBackgroundContextColor,
            isEnabled: isEnabledOverride,
            isAvailableOffline: isAvailableOffline,
            action: action
        ) {
            AnyView(image.accessibilityLabel(accessibilityLabel))
        }
    }

    /// Menu with text label.
    public init<MenuContent: View>(
        isBackgroundContextColor: Bool = false,
        isEnabled isEnabledOverride: Bool? = nil,
        isAvailableOffline: Bool = true,
        title: String,
        @ViewBuilder menuContent: () -> MenuContent
    ) {
        self.init(
            isBackgroundContextColor: isBackgroundContextColor,
            isEnabled: isEnabledOverride,
            isAvailableOffline: isAvailableOffline,
            action: {},
            menuContent: AnyView(menuContent())
        ) {
            AnyView(Text(title).font(.regular16, lineHeight: .fit))
        }
    }

    /// Menu with image label.
    public init<MenuContent: View>(
        isBackgroundContextColor: Bool = false,
        isEnabled isEnabledOverride: Bool? = nil,
        isAvailableOffline: Bool = true,
        image: Image,
        accessibilityLabel: String,
        @ViewBuilder menuContent: () -> MenuContent
    ) {
        self.init(
            isBackgroundContextColor: isBackgroundContextColor,
            isEnabled: isEnabledOverride,
            isAvailableOffline: isAvailableOffline,
            action: {},
            menuContent: AnyView(menuContent())
        ) {
            AnyView(image.accessibilityLabel(accessibilityLabel).accessibilityIdentifier(accessibilityLabel))
        }
    }
}

extension InstUI.NavigationBarButton {

    public static func cancel(
        isBackgroundContextColor: Bool = false,
        isEnabled isEnabledOverride: Bool? = nil,
        isAvailableOffline: Bool = true,
        action: @escaping () -> Void
    ) -> Self {
        .init(
            isBackgroundContextColor: isBackgroundContextColor,
            isEnabled: isEnabledOverride,
            isAvailableOffline: isAvailableOffline,
            title: String(localized: "Cancel", bundle: .core),
            a11yIdentifier: "screen.dismiss",
            action: action
        )
    }

    public static func done(
        isBackgroundContextColor: Bool = false,
        isEnabled isEnabledOverride: Bool? = nil,
        isAvailableOffline: Bool = true,
        action: @escaping () -> Void
    ) -> Self {
        .init(
            isBackgroundContextColor: isBackgroundContextColor,
            isEnabled: isEnabledOverride,
            isAvailableOffline: isAvailableOffline,
            title: String(localized: "Done", bundle: .core),
            action: action
        )
    }

    public static func add(
        isBackgroundContextColor: Bool = false,
        isEnabled isEnabledOverride: Bool? = nil,
        isAvailableOffline: Bool = true,
        action: @escaping () -> Void
    ) -> Self {
        .init(
            isBackgroundContextColor: isBackgroundContextColor,
            isEnabled: isEnabledOverride,
            isAvailableOffline: isAvailableOffline,
            title: String(localized: "Add", bundle: .core),
            action: action
        )
    }

    public static func save(
        isBackgroundContextColor: Bool = false,
        isEnabled isEnabledOverride: Bool? = nil,
        isAvailableOffline: Bool = true,
        action: @escaping () -> Void
    ) -> Self {
        .init(
            isBackgroundContextColor: isBackgroundContextColor,
            isEnabled: isEnabledOverride,
            isAvailableOffline: isAvailableOffline,
            title: String(localized: "Save", bundle: .core),
            action: action
        )
    }

    public static func moreIcon<MenuContent: View>(
        isBackgroundContextColor: Bool = false,
        isEnabled isEnabledOverride: Bool? = nil,
        isAvailableOffline: Bool = true,
        @ViewBuilder menuContent: () -> MenuContent
    ) -> Self {
        .init(
            isBackgroundContextColor: isBackgroundContextColor,
            isEnabled: isEnabledOverride,
            isAvailableOffline: isAvailableOffline,
            image: .moreLine,
            accessibilityLabel: String(localized: "More", bundle: .core),
            menuContent: menuContent
        )
    }

    public static func filterIcon(
        isBackgroundContextColor: Bool = false,
        isEnabled isEnabledOverride: Bool? = nil,
        isAvailableOffline: Bool = true,
        isSolid: Bool = false,
        action: @escaping () -> Void
    ) -> Self {
        .init(
            isBackgroundContextColor: isBackgroundContextColor,
            isEnabled: isEnabledOverride,
            isAvailableOffline: isAvailableOffline,
            image: isSolid ? .filterSolid : .filterLine,
            accessibilityLabel: String(localized: "Filter", bundle: .core),
            action: action
        )
    }
}

#if DEBUG

private func previewsFactory(isContextBackground: Bool) -> some View {
    VStack {
        InstUI.NavigationBarButton.cancel(isBackgroundContextColor: isContextBackground) { }

        InstUI.NavigationBarButton.done(isBackgroundContextColor: isContextBackground) { }
            .disabled(true)

        InstUI.NavigationBarButton.add(isBackgroundContextColor: isContextBackground, isEnabled: false) { }

        InstUI.NavigationBarButton(isBackgroundContextColor: isContextBackground, isEnabled: true, title: "Enabled button") { }

        InstUI.NavigationBarButton(isBackgroundContextColor: isContextBackground, isEnabled: false, title: "Disabled button") { }
            .disabled(false)

        InstUI.NavigationBarButton(isBackgroundContextColor: isContextBackground, isEnabled: true, image: .settingsLine, accessibilityLabel: "Settings") { }

        InstUI.NavigationBarButton(isBackgroundContextColor: isContextBackground, isEnabled: false, action: {}) {
            AnyView(Image.settingsLine)
        }
    }
}

#Preview {
    VStack {
        VStack {
            Text(verbatim: "Dialog Nav Bar Background")
            previewsFactory(isContextBackground: false)
                .background(Color.backgroundLightest)
        }
        .padding()
        .border(Color.backgroundDarkest)
        VStack {
            Text(verbatim: "Context Nav Bar Background")
            previewsFactory(isContextBackground: true)
                .background(Color(UIColor.backgroundInfo.darkenToEnsureContrast(against: .textLightest)))
        }
        .padding()
        .border(Color.backgroundDarkest)
    }
}

#endif
