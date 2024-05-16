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

        private let label: String
        private let isEnabledOverride: Bool?
        private let action: () -> Void

        private var isEnabled: Bool {
            isEnabledOverride ?? isEnabledViaEnvironment
        }

        public init(label: String, isEnabled isEnabledOverride: Bool? = nil, action: @escaping () -> Void) {
            self.label = label
            self.isEnabledOverride = isEnabledOverride
            self.action = action
        }

        public var body: some View {
            Button(
                action: action,
                label: {
                    Text(label)
                        .font(.regular16, lineHeight: .fit)
                        .foregroundStyle(isEnabled ? Color.textDarkest : Color.disabledGray)
                }
            )
            .environment(\.isEnabled, isEnabled)
        }
    }
}

extension InstUI.NavigationBarButton {

    public static func cancel(isEnabled isEnabledOverride: Bool? = nil, action: @escaping () -> Void) -> Self {
        .init(label: String(localized: "Cancel", bundle: .core), isEnabled: isEnabledOverride, action: action)
    }

    public static func done(isEnabled isEnabledOverride: Bool? = nil, action: @escaping () -> Void) -> Self {
        .init(label: String(localized: "Done", bundle: .core), isEnabled: isEnabledOverride, action: action)
    }

    public static func add(isEnabled isEnabledOverride: Bool? = nil, action: @escaping () -> Void) -> Self {
        .init(label: String(localized: "Add", bundle: .core), isEnabled: isEnabledOverride, action: action)
    }

    public static func save(isEnabled isEnabledOverride: Bool? = nil, action: @escaping () -> Void) -> Self {
        .init(label: String(localized: "Save", bundle: .core), isEnabled: isEnabledOverride, action: action)
    }
}

#if DEBUG

#Preview {
    VStack {
        InstUI.NavigationBarButton.cancel(action: {})

        InstUI.NavigationBarButton.done(action: {})
            .disabled(true)

        InstUI.NavigationBarButton.add(isEnabled: false, action: {})

        InstUI.NavigationBarButton(label: "Enabled button", isEnabled: true, action: {})
            .disabled(true)

        InstUI.NavigationBarButton(label: "Disabled button", isEnabled: false, action: {})
            .disabled(false)
    }
}

#endif
