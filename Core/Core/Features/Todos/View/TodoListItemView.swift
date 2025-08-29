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

struct TodoListItemView: View {
    let item: TodoItem

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            item.icon
                .font(.regular14)
                .foregroundStyle(item.color)
                .frame(width: 25)

            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.contextName)
                        .font(.regular14)
                        .foregroundStyle(item.color)

                    Text(item.title)
                        .font(.regular16)
                        .foregroundStyle(.textDarkest)
                        .lineLimit(2)

                    if let subtitle = item.subtitle {
                        Text(subtitle)
                            .font(.regular14)
                            .foregroundStyle(.textDark)
                    }

                    Text(item.date.dateTimeStringShort)
                        .font(.regular14)
                        .foregroundStyle(.textDark)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.regular14)
                    .foregroundStyle(.textDarkest)
            }
        }
    }
}
