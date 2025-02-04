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

import SwiftUI

extension HorizonUI {
    struct PrimaryButton: View {
        private let label: String
        private let type: HorizonUI.ButtonStyles.ButtonType
        private let isSmall: Bool
        private let fillsWidth: Bool
        private let leading: Image?
        private let trailing: Image?
        private let action: () -> Void

        init(
            _ label: String,
            type: HorizonUI.ButtonStyles.ButtonType = .blue,
            isSmall: Bool = false,
            fillsWidth: Bool = false,
            leading: Image? = nil,
            trailing: Image? = nil,
            action: @escaping () -> Void
        ) {
            self.label = label
            self.type = type
            self.isSmall = isSmall
            self.fillsWidth = fillsWidth
            self.leading = leading
            self.trailing = trailing
            self.action = action
        }

        var body: some View {
            Button(self.label, action: action)
                .buttonStyle(
                    HorizonUI.ButtonStyles.primary(
                        type,
                        isSmall: isSmall,
                        fillsWidth: isSmall,
                        leading: leading,
                        trailing: trailing
                    )
                )
        }
    }
}

public extension HorizonUI {
    struct IconButton: View {
        private let type: HorizonUI.ButtonStyles.ButtonType
        private let isSmall: Bool
        private let badgeNumber: String?
        private let icon: Image?
        private let action: () -> Void

        public init(
            _ icon: Image?,
            type: HorizonUI.ButtonStyles.ButtonType = .blue,
            isSmall: Bool = false,
            badgeNumber: String? = nil,
            action: @escaping () -> Void
        ) {
            self.type = type
            self.isSmall = isSmall
            self.badgeNumber = badgeNumber
            self.icon = icon
            self.action = action
        }

        public var body: some View {
            Button("", action: action)
                .labelStyle(.iconOnly)
                .buttonStyle(
                    HorizonUI.ButtonStyles.icon(
                        type,
                        isSmall: isSmall,
                        badgeNumber: badgeNumber,
                        icon: icon
                    )
                )
        }
    }
}

public extension HorizonUI {
    struct TextButton: View {
        private let label: String
        private let type: HorizonUI.ButtonStyles.ButtonType
        private let isSmall: Bool
        private let fillsWidth: Bool
        private let leading: Image?
        private let trailing: Image?
        private let action: () -> Void

        public init(
            _ label: String,
            type: HorizonUI.ButtonStyles.ButtonType = .blue,
            isSmall: Bool = false,
            fillsWidth: Bool = false,
            leading: Image? = nil,
            trailing: Image? = nil,
            action: @escaping () -> Void
        ) {
            self.label = label
            self.type = type
            self.isSmall = isSmall
            self.fillsWidth = fillsWidth
            self.leading = leading
            self.trailing = trailing
            self.action = action
        }

        public var body: some View {
            Button(label, action: action)
            .buttonStyle(
                HorizonUI.ButtonStyles.textLink(
                    type,
                    isSmall: isSmall,
                    fillsWidth: fillsWidth,
                    leading: leading,
                    trailing: trailing
                )
            )
        }
    }
}
