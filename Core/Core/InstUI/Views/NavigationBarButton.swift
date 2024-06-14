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
        private let isEnabledOverride: Bool?
        private let action: () -> Void

        private var isEnabled: Bool {
            isEnabledOverride ?? isEnabledViaEnvironment
        }

        public init(
            isEnabled isEnabledOverride: Bool? = nil,
            action: @escaping () -> Void,
            content: @escaping () -> AnyView
        ) {
            self.content = content
            self.isEnabledOverride = isEnabledOverride
            self.action = action
        }

        public var body: some View {
            Button(action: action) {
                content()
                    // TODO: Add option for darker(context) backgrounds
                    .foregroundStyle(isEnabled ? Color.textDarkest : Color.disabledGray)
            }
            .environment(\.isEnabled, isEnabled)
        }
    }
}

extension InstUI.NavigationBarButton {

    public static func cancel(
        isEnabled isEnabledOverride: Bool? = nil,
        action: @escaping () -> Void
    ) -> Self {
        .textButton(
            isEnabled: isEnabledOverride,
            label: String(localized: "Cancel", bundle: .core),
            action: action
        )
    }

    public static func done(
        isEnabled isEnabledOverride: Bool? = nil,
        action: @escaping () -> Void
    ) -> Self {
        .textButton(
            isEnabled: isEnabledOverride,
            label: String(localized: "Done", bundle: .core),
            action: action
        )
    }

    public static func add(
        isEnabled isEnabledOverride: Bool? = nil,
        action: @escaping () -> Void
    ) -> Self {
        .textButton(
            isEnabled: isEnabledOverride,
            label: String(localized: "Add", bundle: .core),
            action: action
        )
    }

    public static func save(
        isEnabled isEnabledOverride: Bool? = nil,
        action: @escaping () -> Void
    ) -> Self {
        .textButton(
            isEnabled: isEnabledOverride,
            label: String(localized: "Save", bundle: .core),
            action: action
        )
    }

    public static func textButton(
        isEnabled isEnabledOverride: Bool? = nil,
        label: String,
        action: @escaping () -> Void
    ) -> Self {
        .init(
            isEnabled: isEnabledOverride,
            action: action) {
                AnyView(Text(label).font(.regular16, lineHeight: .fit))
            }
    }
}

#if DEBUG

#Preview {
    VStack {
        let previewsFactory = {
            VStack {
                InstUI.NavigationBarButton.cancel(action: {})

                InstUI.NavigationBarButton.done(action: {})
                    .disabled(true)

                InstUI.NavigationBarButton.add(isEnabled: false, action: {})

                InstUI.NavigationBarButton.textButton(isEnabled: true, label: "Enabled button", action: {})

                InstUI.NavigationBarButton.textButton(isEnabled: false, label: "Disabled button", action: {})
                    .disabled(false)

                InstUI.NavigationBarButton(isEnabled: true, action: {}) {
                    AnyView(Image.settingsLine)
                }

                InstUI.NavigationBarButton(isEnabled: false, action: {}) {
                    AnyView(Image.settingsLine)
                }
            }
        }
        VStack {
            Text(verbatim: "Dialog Nav Bar Background")
            previewsFactory().background(Color.backgroundLightest)
        }
        .padding()
        .border(Color.backgroundDarkest)
        VStack {
            Text(verbatim: "Context Nav Bar Background")
            previewsFactory().background(Color(UIColor.electric.darkenToEnsureContrast(against: .textLightest)))
        }
        .padding()
        .border(Color.backgroundDarkest)
    }
}

#endif
