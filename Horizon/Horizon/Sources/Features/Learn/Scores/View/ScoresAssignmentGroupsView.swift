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

struct ScoresAssignmentGroupsView: View {
    let details: ScoreDetails

    @State private var isExpanded: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: .huiSpaces.space16) {
            Text(
                String.localizedStringWithFormat(
                    String(localized: "Total: %@", bundle: .horizon),
                    details.score
                )
            )
            .huiTypography(.h2)
            .foregroundStyle(Color.huiColors.text.body)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding([.leading, .trailing], .huiSpaces.space24)
            HStack(spacing: .huiSpaces.space8) {
                arrowIcon
                Text("Assignment Group Weights", bundle: .horizon)
                    .huiTypography(.p1)
                    .foregroundStyle(Color.huiColors.text.body)
            }
            .padding([.leading, .trailing], .huiSpaces.space24)
            .padding(.bottom, isExpanded ? -16 : 0)

            if isExpanded {
                assignmentGroupList(groups: details.assignmentGroups)
            }
        }
        .padding(.top, .huiSpaces.space24)
        .padding(.bottom, isExpanded ? 0 : .huiSpaces.space24)
        .background(Color.huiColors.primitives.white10)
        .huiCornerRadius(level: .level5)
        .onTapGesture {
            isExpanded.toggle()
        }
    }

    private var arrowIcon: some View {
        Image.huiIcons
            .keyboardArrowDown
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 24, height: 24)
            .rotationEffect(isExpanded ? .degrees(-180) : .degrees(0))
    }

    @ViewBuilder
    private func assignmentGroupList(groups: [HAssignmentGroup]) -> some View {
        VStack(spacing: .zero) {
            ForEach(Array(groups.enumerated()), id: \.offset) { index, group in
                assignmentGroupListRow(group: group)
                    .padding([.leading, .trailing], .huiSpaces.space24)
                if index != groups.count - 1 {
                    divider
                }
            }
            divider
            Text(
                String.localizedStringWithFormat(
                    String(localized: "Total Weight: %@", bundle: .horizon),
                    groups.groupWeightSumString + "%"
                )
            )
            .huiTypography(.h4)
            .foregroundStyle(Color.huiColors.text.body)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, .huiSpaces.space16)
            .padding(.bottom, .huiSpaces.space24)
            .padding([.leading, .trailing], .huiSpaces.space24)
        }
    }

    private var divider: some View {
        Divider()
            .frame(maxWidth: .infinity)
            .frame(height: 1)
            .foregroundColor(Color.huiColors.surface.divider)
    }

    @ViewBuilder
    private func assignmentGroupListRow(group: HAssignmentGroup) -> some View {
        VStack(alignment: .leading, spacing: .huiSpaces.space8) {
            Text(group.name)
                .huiTypography(.p1)
                .foregroundStyle(Color.huiColors.text.body)
                .frame(maxWidth: .infinity, alignment: .leading)
            if let groupWeightString = group.groupWeightString {
                Text(
                    String.localizedStringWithFormat(
                        String(localized: "Weight: %@", bundle: .horizon),
                        groupWeightString + "%"
                    )
                )
                .huiTypography(.p1)
                .foregroundStyle(Color.huiColors.text.body)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(.vertical, .huiSpaces.space16)
    }
}

#Preview {
    VStack {
        ScoresAssignmentGroupsView(
            details: .init(
                score: "28% (C)",
                assignmentGroups: [
                    .init(id: "1", name: "Group 1", groupWeight: 20, assignments: []),
                    .init(id: "2", name: "Group 2", groupWeight: 80, assignments: [])
                ]
            )
        )
    }
    .background(Color.gray)
}
