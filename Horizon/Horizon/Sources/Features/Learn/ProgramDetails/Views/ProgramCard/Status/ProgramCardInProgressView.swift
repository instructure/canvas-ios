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

struct ProgramCardInProgressView: View {
    let isEnrolled: Bool
    let isRequired: Bool
    let isLinear: Bool
    let estimatedTime: String?
    let completionPercent: Double?

    init(
        isEnrolled: Bool = false,
        isRequired: Bool,
        isLinear: Bool,
        estimatedTime: String?,
        completionPercent: Double?
    ) {
        self.isEnrolled = isEnrolled
        self.isRequired = isRequired
        self.isLinear = isLinear
        self.estimatedTime = estimatedTime
        self.completionPercent = completionPercent
    }

    var body: some View {
        HorizonUI.HFlow {
            if let completionPercent {
                progressBar(completionPercent: completionPercent)
            }
            if isLinear {
                HorizonUI.StatusChip(
                    title: isRequired
                    ? String(localized: "Required", bundle: .horizon)
                    : String(localized: "Optional", bundle: .horizon),
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

    private func progressBar(completionPercent: Double) -> some View {
        VStack(spacing: .huiSpaces.space8) {
            let rounded = round(completionPercent * 100)
            Group {
                Text(rounded, format: .number) + Text("% complete", bundle: .horizon)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .huiTypography(.p2)
            .foregroundStyle(Color.huiColors.surface.institution)
            HorizonUI.ProgressBar(
                progress: completionPercent,
                size: .small,
                numberPosition: .hidden,
                backgroundColor: Color.huiColors.surface.pageTertiary
            )
            .padding(.bottom, .huiSpaces.space12)
        }
    }
}

#Preview {
    ProgramCardInProgressView(
        isEnrolled: true,
        isRequired: true,
        isLinear: true,
        estimatedTime: "10 hours",
        completionPercent: 0.3
    )
}
