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

struct AssistInfoView: View {
    var onDismiss: () -> Void = {}
    @State private var isPresentingPermissionView = false
    @State private var isPresentingNutritionFactsView = false

    var body: some View {
        VStack(alignment: .leading, spacing: .huiSpaces.space16) {
            headerView
            Text("Study tools")
                .frame(maxWidth: .infinity, alignment: .leading)
                .huiTypography(.h2)
                .foregroundStyle(Color.huiColors.text.body)
            firstSection
            secondSection
        }
        .padding(.huiSpaces.space24)
        .fullScreenCover(isPresented: $isPresentingPermissionView) {
            AssistPermissionView()
        }
        .fullScreenCover(isPresented: $isPresentingNutritionFactsView) {
            NutritionFactsView()
        }
    }

    private var firstSection: some View {
        VStack(alignment: .leading, spacing: .huiSpaces.space8) {
            Text("Permission Level")
                .frame(maxWidth: .infinity, alignment: .leading)
                .huiTypography(.h4)
                .foregroundStyle(Color.huiColors.text.body)

            Text("LEVEL 1")
                .frame(maxWidth: .infinity, alignment: .leading)
                .huiTypography(.labelSmall)
                .foregroundStyle(Color(hexString: "#8A49A7"))

            Text("We utilize off-the-shelf AI models and customer data as input to provide AI-powered features. No data is used for training this model.")
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.leading)
                .huiTypography(.buttonTextMedium)
                .foregroundStyle(Color.huiColors.text.body)

            Button {
                isPresentingPermissionView = true
            } label: {
                Text("View Permission Levels")
                    .frame(alignment: .leading)
                    .foregroundStyle(Color.huiColors.text.title)
                    .huiTypography(.labelMediumBold)
                    .underline(true, color: Color.huiColors.text.body)
            }
        }
    }
    private var secondSection: some View {
        VStack(alignment: .leading, spacing: .huiSpaces.space10) {
            Text("Base Model")
                .huiTypography(.h4)
                .foregroundStyle(Color.huiColors.text.body)

            Text("Claude 3.5 Haiku by Anthropic and Cohere multi-language v3")
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.leading)
                .huiTypography(.buttonTextMedium)
                .foregroundStyle(Color.huiColors.text.body)

            Button {
                isPresentingNutritionFactsView = true
            } label: {
                Text("View AI Nutrition Facts")
                    .frame(alignment: .leading)
                    .foregroundStyle(Color.huiColors.text.title)
                    .huiTypography(.labelMediumBold)
                    .underline(true, color: Color.huiColors.text.body)
            }
        }
    }

    private var headerView: some View {
        HStack {
            Image.huiIcons.aiFilled
                .foregroundStyle(Color(hexString: "#8A49A7"))
            Text("IgniteAI")
                .foregroundStyle(Color(hexString: "#8A49A7"))
                .huiTypography(.h4)
            Spacer()

            HorizonUI.IconButton(Image.huiIcons.close, type: .white) {
                onDismiss()
            }
        }
        .fixedSize(horizontal: false, vertical: true)
    }
}

#Preview {
    AssistInfoView()
}
