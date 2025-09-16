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

struct ProgramCardActiveView: View {
    let isEnrolled: Bool
    let isRequired: Bool
    let isLinear: Bool
    let estimatedTime: String?

    var body: some View {
        HorizonUI.HFlow {
            if isEnrolled {
                HorizonUI.StatusChip(
                    title: String(localized: "Enrolled"),
                    style: .green,
                    icon: .huiIcons.checkCircleFull
                )
            }
            if isLinear {
                HorizonUI.StatusChip(
                    title: isRequired ? String(localized: "Required") : String(localized: "Optional"),
                    style: .gray
                )
            }

            if let estimatedTime {
                HorizonUI.StatusChip(
                    title: estimatedTime,
                    style: .gray
                )
            }
        }
    }
}

#Preview {
    ProgramCardActiveView(
        isEnrolled: true,
        isRequired: true,
        isLinear: true,
        estimatedTime: "10 hours"
    )
}
