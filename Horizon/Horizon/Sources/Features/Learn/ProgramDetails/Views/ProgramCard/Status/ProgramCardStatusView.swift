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

struct ProgramCardStatusView: View {
    let isEnrolled: Bool
    let isRequired: Bool
    let isLinear: Bool
    let status: ProgramCardStatus
    let estimatedTime: String?
    let completionPercent: Double?

    var body: some View {
        switch status {
        case .active, .notEnrolled:
            ProgramCardActiveView(
                isEnrolled: isEnrolled,
                isRequired: isRequired,
                isLinear: isLinear,
                estimatedTime: estimatedTime
            )
        case .inProgress:
            ProgramCardInProgressView(
                isRequired: isRequired,
                isLinear: isLinear,
                estimatedTime: estimatedTime,
                completionPercent: completionPercent
            )

        case .locked:
            ProgramCardLockedView(
                isRequired: isRequired,
                isLinear: isLinear,
                estimatedTime: estimatedTime
            )
        case .completed:
            HorizonUI.StatusChip(
                title: String(localized: "Completed", bundle: .horizon),
                style: .honey
            )
        }
    }
}

#Preview {
    VStack(alignment: .leading) {
        ProgramCardStatusView(
            isEnrolled: true,
            isRequired: true,
            isLinear: true,
            status: .active,
            estimatedTime: "10 hours",
            completionPercent: 0.9
        )

        ProgramCardStatusView(
            isEnrolled: false,
            isRequired: false,
            isLinear: false,
            status: .inProgress,
            estimatedTime: "10 hours",
            completionPercent: 0.6
        )

        ProgramCardStatusView(
            isEnrolled: false,
            isRequired: false,
            isLinear: true,
            status: .locked,
            estimatedTime: "10 hours",
            completionPercent: 0.2
        )

        ProgramCardStatusView(
            isEnrolled: false,
            isRequired: false,
            isLinear: false,
            status: .completed,
            estimatedTime: "10 hours",
            completionPercent: 0.5
        )
    }
}
