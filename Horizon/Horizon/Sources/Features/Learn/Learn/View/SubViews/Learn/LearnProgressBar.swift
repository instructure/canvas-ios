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

import SwiftUI
import HorizonUI

struct LearnProgressBar: View {
    let completionPercent: Double?

    var body: some View {
        VStack(spacing: .huiSpaces.space8) {
            let completion = completionPercent ?? 0
            let rounded = round(completion * 100)

            if completion == 0 {
                Text("Not started", bundle: .horizon)
                    .foregroundStyle(Color.huiColors.text.title)
                    .huiTypography(.p2)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                HStack(spacing: .huiSpaces.space2) {
                    Text(rounded, format: .number) + Text("%")
                    Text("complete", bundle: .horizon)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .huiTypography(.p2)
                .foregroundStyle(Color.huiColors.surface.institution)
            }

            HorizonUI.ProgressBar(
                progress: completion,
                size: .small,
                numberPosition: .hidden,
                backgroundColor: Color.huiColors.surface.pageSecondary
            )
        }
    }
}
