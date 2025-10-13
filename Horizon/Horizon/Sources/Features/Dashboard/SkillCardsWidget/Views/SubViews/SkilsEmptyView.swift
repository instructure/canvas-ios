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

struct SkillWidgetEmptyView: View {
    var body: some View {
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
}

#Preview {
    SkillWidgetEmptyView()
}
