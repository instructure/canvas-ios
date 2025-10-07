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

struct SkillsHighlightCard: View {
    struct Skill: Identifiable {
        let id: String
        let title: String
        let status: String
    }

    let skill: Skill
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: .huiSpaces.space16)
                .fill(Color.huiColors.primitives.green12.opacity(ProficiencyLevel(rawValue: skill.status)?.opacity ?? 1))
            VStack(alignment: .leading, spacing: .huiSpaces.space8) {
                Text(skill.title.capitalized)
                    .huiTypography(.p2)
                    .lineLimit(1)
                    .foregroundStyle(Color.huiColors.text.body)
                    .frame(maxWidth: .infinity, alignment: .leading)
                HorizonUI.StatusChip(title: skill.status, style: .white)
            }
            .padding(.huiSpaces.space24)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text("\(skill.title), \(skill.status)"))
    }
}

#Preview {
    SkillsHighlightCard(
        skill: .init(
            id: "1",
            title: "Dolor sit skill name",
            status: "Beginner"
        )
    )
}
