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

struct LearnProgramCardView: View {
    let program: Program

    var body: some View {
        VStack(alignment: .leading, spacing: .huiSpaces.space16) {
            programNameView
            programPercentageView
            descriptionView
        }
        .padding(.huiSpaces.space24)
        .background(Color.huiColors.surface.pageSecondary)
        .huiCornerRadius(level: .level5)
        .huiElevation(level: .level4)
        .scrollTransition(.animated) { content, phase in
            content
                .scaleEffect(phase.isIdentity ? 1 : 0.9)
        }
    }

    private var programNameView: some View {
        Text(program.name)
            .huiTypography(.labelLargeBold)
            .foregroundStyle(Color.huiColors.text.title)
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    private var programPercentageView: some View {
        HorizonUI.ProgressBar(
            progress: program.completionPercent,
            progressColor: .huiColors.surface.institution,
            size: .small,
            numberPosition: .outside,
            backgroundColor: Color.huiColors.primitives.grey14
        )
    }

    private var descriptionView: some View {
        HorizonUI.HFlow(spacing: .huiSpaces.space8, lineSpacing: .huiSpaces.space10) {
            HorizonUI.StatusChip(
                title: String(
                    format: String(localized: "%d courses"),
                    arguments: [program.courses.count]
                ),
                style: .gray
            )

            if let estimatedTime = program.estimatedTime {
                HorizonUI.StatusChip(
                    title: estimatedTime,
                    style: .gray
                )
            }

            if let date = program.date {
                HorizonUI.StatusChip(
                    title: date,
                    style: .gray,
                    icon: .huiIcons.calendarToday
                )
            }
        }
    }
}

#Preview {
    LearnProgramCardView(
        program: Program(
            id: "11",
            name: "Program Name Here",
            variant: "",
            description: "",
            date: "XX/XX/XX – XX/XX/XX",
            courseCompletionCount: 0,
            courses: []
        )
    )
}
