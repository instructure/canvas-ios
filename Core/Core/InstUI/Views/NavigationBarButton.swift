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
        @Environment(\.isEnabled) private var isEnabled: Bool

        private let label: String
        private let action: () -> Void

        public init(label: String, action: @escaping () -> Void) {
            self.label = label
            self.action = action
        }

        public var body: some View {
            Button(
                action: action,
                label: {
                    Text(label)
                        .font(.regular16, lineHeight: .fit)
                        .foregroundStyle(isEnabled ? Color.textDarkest : Color.textDarkest.opacity(0.5))
                }
            )
        }
    }
}

extension InstUI.NavigationBarButton {
    public static func cancel(action: @escaping () -> Void) -> Self {
        .init(label: String(localized: "Cancel", bundle: .core), action: action)
    }

    public static func done(action: @escaping () -> Void) -> Self {
        .init(label: String(localized: "Done", bundle: .core), action: action)
    }

    public static func add(action: @escaping () -> Void) -> Self {
        .init(label: String(localized: "Add", bundle: .core), action: action)
    }

    public static func save(action: @escaping () -> Void) -> Self {
        .init(label: String(localized: "Save", bundle: .core), action: action)
    }
}

#if DEBUG

#Preview {
    VStack {
        InstUI.NavigationBarButton.cancel(action: {})
        InstUI.NavigationBarButton.done(action: {})
            .disabled(true)
    }
}

#endif
