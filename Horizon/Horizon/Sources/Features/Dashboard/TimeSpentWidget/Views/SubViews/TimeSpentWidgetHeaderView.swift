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

struct TimeSpentWidgetHeader: View {
    var body: some View {
        HStack {
            Text("Time", bundle: .horizon)
                .foregroundStyle(Color.huiColors.text.dataPoint)
                .huiTypography(.labelMediumBold)
                .frame(alignment: .leading)
                .skeletonLoadable()

            Spacer()

            Image.huiIcons.schedule
                .resizable()
                .frame(width: 16, height: 16)
                .foregroundStyle(Color.huiColors.icon.default)
                .padding(.huiSpaces.space8)
                .background {
                    Circle()
                        .fill(Color.huiColors.primitives.honey12)
                }
                .accessibilityHidden(true)
                .skeletonLoadable()
        }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isHeader)
    }
}

#Preview {
    TimeSpentWidgetHeader()
}
