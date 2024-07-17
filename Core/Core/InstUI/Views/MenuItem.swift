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

    /// `MenuItem` is to be used in `SwiftUI.Menu` content. It is a pre-styled `Button` with a `title` and an optional `image` as it's label.
    public struct MenuItem: View {
        @ScaledMetric private var uiScale: CGFloat = 1

        private let title: String
        private let image: Image?
        private let action: () -> Void

        public init(
            title: String,
            image: Image?,
            action: @escaping () -> Void
        ) {
            self.title = title
            self.image = image
            self.action = action
        }

        public var body: some View {
            Button(
                action: action,
                label: {
                    HStack {
                        Text(title)
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
        .init(title: String(localized: "Edit", bundle: .core), image: .editLine, action: action)
    }

    public static func delete(action: @escaping () -> Void) -> Self {
        .init(title: String(localized: "Delete", bundle: .core), image: .trashLine, action: action)
    }
}

#if DEBUG

#Preview {
    Menu(
        content: {
            InstUI.MenuItem(title: "Text Only", image: nil) { }
            InstUI.MenuItem(title: "Publish", image: .completeLine) { }
            InstUI.MenuItem(title: "Unpublish", image: .noLine) { }
            InstUI.MenuItem.edit { }
            InstUI.MenuItem.delete { }
        },
        label: {
            Text(verbatim: "Menu")
        }
    )
}

#endif
