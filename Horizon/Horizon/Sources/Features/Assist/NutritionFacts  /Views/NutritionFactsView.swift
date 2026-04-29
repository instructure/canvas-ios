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

struct NutritionFactsView: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        VStack(alignment: .leading, spacing: .zero) {
            headerView
            ScrollView(showsIndicators: false) {
                VStack(spacing: .huiSpaces.space24) {
                    titleView(text: "Study Tools")
                    ForEach(NutritionFactModel.getSections()) { section in
                        listItemView(section: section)
                    }
                }
                .padding(.huiSpaces.space24)
            }
            Divider()
            footerView
        }
    }

    private func titleView(text: String) -> some View {
        Text(text)
            .foregroundStyle(Color.huiColors.text.title)
            .frame(maxWidth: .infinity, alignment: .leading)
            .huiTypography(.h3)
    }

    private func listItemView(section: NutritionFactModel) -> some View {
        VStack(spacing: .huiSpaces.space10) {
            titleView(text: section.sectionName)
            ForEach(section.items) { item in
                NutritionFactRowView(item: item)
            }
        }
    }

    private var headerView: some View {
        VStack(spacing: .huiSpaces.space2) {
            HStack {
                HorizonUI.icons.aiFilled
                    .accessibilityHidden(true)
                    .foregroundStyle(Color(hexString: "#8A49A7"))
                Text(String(localized: "IgniteAI", bundle: .horizon))
                    .huiTypography(.h4)
                    .foregroundStyle(Color(hexString: "#8A49A7"))
                    .accessibilityAddTraits(.isHeader)
                Spacer()
                HorizonUI.IconButton(Image.huiIcons.close, type: .white) {
                    dismiss()
                }
            }
            .padding(.horizontal, .huiSpaces.space24)
            Text("Nutrition Facts")
                .frame(maxWidth: .infinity, alignment: .leading)
                .huiTypography(.h2)
                .foregroundStyle(Color.huiColors.text.title)
                .padding(.horizontal, .huiSpaces.space24)
                .padding(.bottom, .huiSpaces.space8)
            Divider()
        }
    }

    private var footerView: some View {
        HStack {
            Spacer()
            HorizonUI.PrimaryButton(String(localized: "Close"), type: .black) {
                dismiss()
            }
            .padding(.horizontal, .huiSpaces.space24)
            .padding(.top, .huiSpaces.space10)
        }
    }
}

#Preview {
    NutritionFactsView()
}
