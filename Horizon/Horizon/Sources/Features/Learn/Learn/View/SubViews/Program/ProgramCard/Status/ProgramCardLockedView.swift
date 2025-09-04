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

struct ProgramCardLockedView: View {
    let isRequired: Bool
    let isLinear: Bool
    let estimatedTime: String?

    var body: some View {
        HorizonUI.HFlow {
            HorizonUI.Pill(
                title: String(localized: "Locked"),
                style: .outline(
                    .init(
                        borderColor: Color.huiColors.lineAndBorders.lineStroke,
                        textColor: Color.huiColors.text.title,
                        iconColor: Color.huiColors.icon.default
                    )
                ),
                isSmall: true,
                cornerRadius: .level1,
                icon: .huiIcons.lock
            )

            if isLinear {
                ProgramStatusView(isRequired: isRequired, isLocked: true)
            }

            if let estimatedTime {
                HorizonUI.Pill(
                    title: estimatedTime,
                    style: .outline(
                        .init(
                            borderColor: Color.huiColors.lineAndBorders.lineStroke,
                            textColor: Color.huiColors.text.title
                        )
                    ),
                    isSmall: true,
                    cornerRadius: .level1
                )
            }
        }
    }
}

#Preview {
    ProgramCardLockedView(
    isRequired: true,
    isLinear: true,
    estimatedTime: "10 hours"
    )
}
