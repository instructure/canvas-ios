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

struct TodoListItemCell: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.viewController) private var viewController

    let item: TodoItem
    let onTap: (_ item: TodoItem, _ viewController: WeakViewController) -> Void
    let isLastItem: Bool

    var body: some View {
        VStack(spacing: 0) {
            Button {
                onTap(item, viewController)
            } label: {
                HStack(alignment: .top, spacing: 0) {
                    item.icon
                        .scaledIcon()
                        .foregroundStyle(item.color)
                        .paddingStyle(.trailing, .cellIconText)
                        .accessibilityHidden(true)

                    HStack(alignment: .center) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.contextName)
                                .font(.regular14)
                                .foregroundStyle(item.color)

                            Text(item.title)
                                .font(.regular16)
                                .foregroundStyle(.textDarkest)

                            if let subtitle = item.subtitle {
                                Text(subtitle)
                                    .font(.regular14)
                                    .foregroundStyle(.textDark)
                            }

                            Text(item.date.dateTimeStringShort)
                                .font(.regular14)
                                .foregroundStyle(.textDark)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)

                        InstUI.DisclosureIndicator()
                            .paddingStyle(.leading, .cellAccessoryPadding)
                            .accessibilityHidden(true)
                    }
                    .multilineTextAlignment(.leading)
                }
                .paddingStyle(set: .iconCell)
            }
            .accessibilityElement(children: .combine)
            InstUI.Divider(isLastItem ? .full : .padded)
        }
    }
}
