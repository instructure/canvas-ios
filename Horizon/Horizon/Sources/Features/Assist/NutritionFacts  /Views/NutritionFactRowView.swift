//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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

import HorizonUI
import SwiftUI

struct NutritionFactRowView: View {
    let item: NutritionFactModel.RowModel
    var body: some View {
        VStack(alignment: .leading, spacing: .huiSpaces.space8) {
            Text(item.title)
                .frame(maxWidth: .infinity, alignment: .leading)
                .huiTypography(.h4)
                .foregroundStyle(Color.huiColors.text.body)
            Text(item.subtitle)
                .multilineTextAlignment(.leading)
                .huiTypography(.buttonTextMedium)
                .foregroundStyle(Color(hexString: "#2369A4"))
            Text(item.description)
                .multilineTextAlignment(.leading)
                .huiTypography(.buttonTextLarge)
                .foregroundStyle(Color.huiColors.text.body)
        }
        .padding(.huiSpaces.space16)
        .huiBorder(
            level: .level1,
            color: Color.huiColors.lineAndBorders.lineConnector,
            radius: 12
        )
    }
}

#Preview {
    NutritionFactRowView(
        item: .init(
            title: String(localized: "Base Model"),
            subtitle: String(localized: "The foundational AI on which further training and customizations are built."),
            description: String(localized: "Claude 3.5 Haiku by Anthropic and Cohere multi-language v3")
        )
    )
    .padding()
}
