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

import HorizonUI
import SwiftUI

struct ListSkillsHighlight: View {
    enum State {
        case skills([SkillsHighlightCard.Skill])
        case error
    }

    let state: State
    let onSelect: (SkillsHighlightCard.Skill) -> Void
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: .huiSpaces.space16) {
            header
            switch state {
            case .skills(let skills):
                if skills.isEmpty {
                    noDataView
                } else {
                    ForEach(skills) { skill in
                        Button {
                            onSelect(skill)
                        } label: {
                            SkillsHighlightCard(skill: skill)
                        }
                    }
                }
            case .error:
                errorView
            }
        }
        .padding(.huiSpaces.space24)
        .background {
            RoundedRectangle(cornerRadius: HorizonUI.CornerRadius.level4.attributes.radius)
                .fill(Color.huiColors.primitives.white10)
        }
        .huiElevation(level: .level4)
    }

    private var header: some View {
        HStack {
            Text("Skill Highlights", bundle: .horizon)
                .frame(maxWidth: .infinity, alignment: .leading)
                .huiTypography(.labelMediumBold)
                .foregroundStyle(Color.huiColors.text.timestamp)
                .accessibilityAddTraits(.isHeader)
            Spacer()
            Image.huiIcons.hub
                .resizable()
                .frame(width: 16, height: 16)
                .foregroundStyle(Color.huiColors.icon.default)
                .padding(.huiSpaces.space8)
                .background {
                    Circle()
                        .fill(Color.huiColors.primitives.green12)
                }
                .accessibilityHidden(true)
        }
    }

    private var noDataView: some View {
        VStack(spacing: .huiSpaces.space8) {
            Text("No data yet", bundle: .horizon)
                .frame(maxWidth: .infinity, alignment: .leading)
                .huiTypography(.h4)
                .foregroundStyle(Color.huiColors.text.body)
            Text("This widget will update once data becomes available.", bundle: .horizon)
                .huiTypography(.p2)
                .foregroundStyle(Color.huiColors.text.timestamp)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            Text(
                "No data yet. This widget will update once data becomes available.",
                bundle: .horizon
            )
        )
    }

    private var errorView: some View {
        VStack(alignment: .leading, spacing: .zero) {
            let errorTitle = String(localized: "We weren’t able to load this content.", bundle: .horizon)
            let errorDescription = String(localized: "Please try again.", bundle: .horizon)

            Text(errorTitle)
                .frame(maxWidth: .infinity, alignment: .leading)
                .huiTypography(.h4)
                .foregroundStyle(Color.huiColors.text.body)
            Text(errorDescription)
                .huiTypography(.p2)
                .foregroundStyle(Color.huiColors.text.timestamp)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, .huiSpaces.space4)
                .padding(.bottom, .huiSpaces.space16)
                .accessibilityElement(children: .combine)
                .accessibilityLabel(Text("\(errorTitle) \(errorDescription)"))

            HorizonUI.PrimaryButton(
                String(localized: "Retry", bundle: .horizon),
                type: .grayOutline,
                isSmall: true,
                trailing: Image.huiIcons.restartAlt
            ) {
                onRetry()
            }
        }
    }
}

#Preview {
   ZStack {
       Color.gray.opacity(0.6)
        ScrollView {
            ListSkillsHighlight(state: .error) { _ in } onRetry: { }

            ListSkillsHighlight(state: .skills([])) { _ in } onRetry: { }
            ListSkillsHighlight(
                state: .skills(
                    [
                        .init(
                            id: "1",
                            title: "Dolor sit amet adipiscing elit do long skill name...",
                            status: "Advanced"
                        ),
                        .init(
                            id: "2",
                            title: "Dolor sit skill name",
                            status: "Proficient"
                        ),
                        .init(
                            id: "3",
                            title: "Dolor sit skill name",
                            status: "Beginner"
                        )
                    ]
                )
            ) { _ in } onRetry: { }
        }
        .padding()
    }
}
