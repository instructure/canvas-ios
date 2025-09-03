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

struct ProgramStatusView: View {
    let isRequired: Bool
    let isLocked: Bool
    private let title: String

    init(isRequired: Bool, isLocked: Bool = false) {
        self.isRequired = isRequired
        self.isLocked = isLocked
        title = isRequired ? String(localized: "Required") : String(localized: "Optional")
    }
    var body: some View {
        if isLocked {
            HorizonUI.Pill(
                title: title,
                style: .outline(
                    .init(
                        borderColor: Color.huiColors.lineAndBorders.lineStroke,
                        textColor: Color.huiColors.text.title
                    )
                ),
                isSmall: true,
                cornerRadius: .level1
            )
        } else {
            HorizonUI.Pill(
                title: title,
                style: .solid(
                    .init(
                        backgroundColor: Color.huiColors.primitives.grey11,
                        textColor: Color.huiColors.text.title
                    )
                ),
                isSmall: true,
                cornerRadius: .level1,
            )
        }
    }
}
