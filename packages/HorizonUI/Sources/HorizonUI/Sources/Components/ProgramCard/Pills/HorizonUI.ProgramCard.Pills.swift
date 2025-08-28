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

extension HorizonUI.ProgramCard {
    struct Pills: View {
         let isEnrolled: Bool
         let isRequired: Bool
         let status: HorizonUI.ProgramCard.Status
         let estimatedTime: String?

        var body: some View {
            switch status {
            case .active, .notEnrolled:
                HorizonUI.ProgramCard.Pills.Active(
                    isEnrolled: isEnrolled,
                    isRequired: isRequired,
                    estimatedTime: estimatedTime
                )
            case .inProgress:
                HorizonUI.ProgramCard.Pills.InProgress(
                    isRequired: isRequired,
                    estimatedTime: estimatedTime
                )

            case .locked:
                HorizonUI.ProgramCard.Pills.Locked(
                    isRequired: isRequired,
                    estimatedTime: estimatedTime
                )
            case .completed:
                HorizonUI.ProgramCard.Pills.Completed()
            }
        }
    }
}

#Preview {
    VStack(alignment: .leading) {
        HorizonUI.ProgramCard.Pills(
            isEnrolled: true,
            isRequired: true,
            status: .active,
            estimatedTime: "10 hours"
        )

        HorizonUI.ProgramCard.Pills(
            isEnrolled: false,
            isRequired: false,
            status: .inProgress,
            estimatedTime: "10 hours"
        )

        HorizonUI.ProgramCard.Pills(
            isEnrolled: false,
            isRequired: false,
            status: .locked,
            estimatedTime: "10 hours",
        )

        HorizonUI.ProgramCard.Pills(
            isEnrolled: false,
            isRequired: false,
            status: .completed,
            estimatedTime: "10 hours"
        )
    }
}
