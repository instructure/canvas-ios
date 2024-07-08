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

    public struct MenuItem: View {
        @ScaledMetric private var uiScale: CGFloat = 1

        private let label: String
        private let image: Image?
        private let action: () -> Void

        public init(
            label: String,
            image: Image?,
            action: @escaping () -> Void
        ) {
            self.label = label
            self.image = image
            self.action = action
        }

        public var body: some View {
            Button(
                action: action,
                label: {
                    HStack {
                        Text(label)
                            .font(.regular16, lineHeight: .fit)
                        Spacer()
                        image?
                            .size(uiScale.iconScale * 24)
                    }
                    .foregroundStyle(Color.textDarkest)
                }
            )
        }
    }
}

extension InstUI.MenuItem {
    public static func edit(action: @escaping () -> Void) -> Self {
        .init(label: String(localized: "Edit", bundle: .core), image: .editLine, action: action)
    }

    public static func delete(action: @escaping () -> Void) -> Self {
        .init(label: String(localized: "Delete", bundle: .core), image: .trashLine, action: action)
    }
}

#if DEBUG

#Preview {
    Menu(
        content: {
            InstUI.MenuItem(label: "Text Only", image: nil) { }
            InstUI.MenuItem(label: "Publish", image: .completeLine) { }
            InstUI.MenuItem(label: "Unpublish", image: .noLine) { }
            InstUI.MenuItem.edit { }
            InstUI.MenuItem.delete { }
        },
        label: {
            Text(verbatim: "Menu")
        }
    )
}

#endif
