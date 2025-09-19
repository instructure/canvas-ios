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

struct ProgramSwitcherHeaderView: View {
    let programName: String
    let shouldHighlightProgram: Bool
    let onBack: () -> Void
    let onSelectOverview: () -> Void

    var body: some View {
        VStack(spacing: .zero) {
            Button(action: onBack) {
                HStack(spacing: .huiSpaces.space8) {
                    Image.huiIcons.arrowBack
                        .foregroundStyle(Color.huiColors.icon.default)
                    Text("All", bundle: .horizon)
                        .foregroundStyle(Color.huiColors.text.body)
                        .huiTypography(.buttonTextLarge)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(.huiSpaces.space16)

            Text(programName)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundStyle(Color.huiColors.text.body)
                .huiTypography(.labelLargeBold)
                .multilineTextAlignment(.leading)
                .padding(.horizontal, .huiSpaces.space16)
                .frame(minHeight: 42)

            Divider()

            Button(action: onSelectOverview) {
                Text("Program overview", bundle: .horizon)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundStyle(
                        shouldHighlightProgram
                        ? Color.huiColors.surface.pagePrimary
                        : Color.huiColors.text.body
                    )
                    .huiTypography(.buttonTextLarge)
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal, .huiSpaces.space16)
                    .frame(minHeight: 42)
                    .background(
                        shouldHighlightProgram
                        ? Color.huiColors.surface.inverseSecondary
                        : .clear
                    )
            }
        }
    }
}
