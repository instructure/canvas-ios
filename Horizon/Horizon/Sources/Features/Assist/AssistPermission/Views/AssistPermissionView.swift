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

struct AssistPermissionView: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        VStack(alignment: .leading, spacing: .zero) {
            headerView
            ScrollView(showsIndicators: false) {
                contentView
             }
            Divider()
            footerView
        }
    }

    private var contentView: some View {
        VStack(alignment: .leading, spacing: .huiSpaces.space24) {
            levelOneView
            levelTwoView
            levelThreeView
            levelFourView
        }
        .padding(.huiSpaces.space24)
    }

        private var levelOneView: some View {
            itemView(
                title: String(localized: "LEVEL 1"),
                subtitle: String(localized: "Descriptive Analytics and Research"),
                description: String(
                    localized: "We leverage anonymized aggregate data for detailed analytics to inform model development and product improvements. No AI models are used at this level."
                )
            )
        }

    private var levelTwoView: some View {
        VStack(spacing: .zero) {
            Text("Current Feature: Study Tools")
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.huiSpaces.space10)
                .foregroundStyle(Color.huiColors.text.surfaceColored)
                .huiTypography(.h3)
                .background(linearGradient)
            itemView(
                title: String(localized: "LEVEL 2"),
                subtitle: String(localized: "AI-Powered Features Without Data Training"),
                description: String(localized: "We utilize off-the-shelf AI models and customer data as input to provide AI-powered features. No data is used for training this model.")
            )
            .padding()
        }
       .huiCornerRadius(level: .level1_5)
       .huiBorder(level: .level1, color: Color.huiColors.surface.igniteAIPrimaryStart, radius: 12)
    }

    private var levelThreeView: some View {
        itemView(
            title: String(localized: "LEVEL 3"),
            subtitle: String(localized: "AI Customization for Individual Institutions"),
            // swiftlint:disable:next line_length
            description: String(localized: "We customize AI solutions tailored to the unique needs and resources of educational institutions. We use customer data to fine-tune data and train AI models that only serve your institution. Your institution's data only serves them through trained models.")
        )
    }

    private var levelFourView: some View {
        itemView(
            title: String(localized: "LEVEL 4"),
            subtitle: String(localized: "ACollaborative AI Consortium"),
            // swiftlint:disable:next line_length
            description: String(localized: "We established a consortium with educational institutions that shares anonymized data, best practices, and research findings. This fosters collaboration and accelerates the responsible development of AI in education. Specialized AI models are created for better outcomes in education, cost savings, and more.")
        )
    }

    private func itemView(title: String, subtitle: String, description: String) -> some View {
        VStack(alignment: .leading, spacing: .zero) {
            Text(title)
                .frame(maxWidth: .infinity, alignment: .leading)
                .huiTypography(.labelSmall)
                .foregroundStyle(Color(hexString: "#8A49A7"))
                .padding(.bottom, .huiSpaces.space4)
            Text(subtitle)
                .huiTypography(.h4)
                .padding(.bottom, .huiSpaces.space10)
                .foregroundStyle(Color.huiColors.text.body)
            Text(description)
                .huiTypography(.buttonTextMedium)
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)
                .foregroundStyle(Color(hexString: "#2369A4"))
        }
    }

    private var linearGradient: some View {
        LinearGradient(
            gradient: Gradient(
                colors: [
                    Color.huiColors.surface.igniteAIPrimaryStart,
                    Color.huiColors.surface.igniteAIPrimaryEnd
                ]
            ),
            startPoint: .leading,
            endPoint: .trailing
        )
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
           Text("Data Permission Levels")
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
    AssistPermissionView()
}
