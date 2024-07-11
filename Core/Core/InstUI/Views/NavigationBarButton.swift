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

        @ViewBuilder private let content: () -> AnyView
        private let isBackgroundContextColor: Bool
        private let isEnabledOverride: Bool?
        private let isAvailableOffline: Bool
        private let action: () -> Void

        private var isEnabled: Bool {
            isEnabledOverride ?? isEnabledViaEnvironment
        }

        public init(
            isBackgroundContextColor: Bool = false,
            isEnabled isEnabledOverride: Bool? = nil,
            isAvailableOffline: Bool = true,
            action: @escaping () -> Void,
            content: @escaping () -> AnyView
        ) {
            self.content = content
            self.isBackgroundContextColor = isBackgroundContextColor
            self.isEnabledOverride = isEnabledOverride
            self.isAvailableOffline = isAvailableOffline
            self.action = action
        }

        public init(
            isBackgroundContextColor: Bool = false,
            isEnabled isEnabledOverride: Bool? = nil,
            isAvailableOffline: Bool = true,
            label: String,
            action: @escaping () -> Void
        ) {
            self.init(
                isBackgroundContextColor: isBackgroundContextColor,
                isEnabled: isEnabledOverride,
                isAvailableOffline: isAvailableOffline,
                action: action
            ) {
                AnyView(Text(label).font(.regular16, lineHeight: .fit))
            }
        }

        public init(
            isBackgroundContextColor: Bool = false,
            isEnabled isEnabledOverride: Bool? = nil,
            isAvailableOffline: Bool = true,
            image: Image,
            action: @escaping () -> Void
        ) {
            self.init(
                isBackgroundContextColor: isBackgroundContextColor,
                isEnabled: isEnabledOverride,
                isAvailableOffline: isAvailableOffline,
                action: action
            ) {
                AnyView(image)
            }
        }

        public var body: some View {
            button
                .foregroundStyle(color)
                .environment(\.isEnabled, isEnabled)
        }

        @ViewBuilder
        private var button: some View {
            if isAvailableOffline {
                Button(action: action, label: content)
            } else {
                OfflineObservingButton(action: action, label: content)
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
            label: String(localized: "Cancel", bundle: .core),
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
            label: String(localized: "Done", bundle: .core),
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
            label: String(localized: "Add", bundle: .core),
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
            label: String(localized: "Save", bundle: .core),
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

        InstUI.NavigationBarButton(isBackgroundContextColor: isContextBackground, isEnabled: true, label: "Enabled button") { }

        InstUI.NavigationBarButton(isBackgroundContextColor: isContextBackground, isEnabled: false, label: "Disabled button") { }
            .disabled(false)

        InstUI.NavigationBarButton(isBackgroundContextColor: isContextBackground, isEnabled: true, image: .settingsLine) { }

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
                .background(Color(UIColor.electric.darkenToEnsureContrast(against: .textLightest)))
        }
        .padding()
        .border(Color.backgroundDarkest)
    }
}

#endif
