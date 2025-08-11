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

extension HorizonUI.ProgramCard.Pills {
    struct Active: View {
        let isEnrolled: Bool
        let isRequired: Bool
        let estimatedTime: String?
        let dueDate: String?

        var body: some View {
            HorizonUI.ProgramCard.Pills.Inprogress(
                isEnrolled: isEnrolled,
                isRequired: isRequired,
                estimatedTime: estimatedTime,
                dueDate: dueDate
            )
        }
    }
}

#Preview {
    HorizonUI.ProgramCard.Pills.Active(
        isEnrolled: true,
        isRequired: true,
        estimatedTime: "10 hours",
        dueDate: "10-10-2020"
    )
}
