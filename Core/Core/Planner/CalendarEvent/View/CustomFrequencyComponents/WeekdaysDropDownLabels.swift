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

struct WeekdaysDropDownPromptLabel: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        HStack(spacing: 7) {
            Text("Choose days", bundle: .core)
                .textStyle(.cellValue)
            InstUI.Icons.DropDown()
                .foregroundStyle(Color.textDark)
        }
        .paddingStyle(set: .selectionValueLabel)
        .contentShape(Rectangle())
    }
}

struct WeekdaysDropDownSelectedLabel: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let text: String
    var body: some View {
        Text(text)
            .lineLimit(1)
            .minimumScaleFactor(0.7)
            .textStyle(.selectedValue)
            .paddingStyle(set: .selectionValueLabel)
            .background(Color.backgroundLight)
            .clipShape(RoundedRectangle(cornerRadius: 4))
    }
}
