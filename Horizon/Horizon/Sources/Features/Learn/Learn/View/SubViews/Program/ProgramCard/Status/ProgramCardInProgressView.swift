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
                ProgramStatusView(isRequired: isRequired)
            }

            if let estimatedTime {
                defaultPill(title: estimatedTime)
            }
        }
    }

    private func progressBar(completionPercent: Double) -> some View {
        VStack(spacing: .huiSpaces.space8) {
            let rounded = round(completionPercent * 100)
            HStack(spacing: .huiSpaces.space2) {
                Text(rounded, format: .number) + Text("%")
                Text("complete", bundle: .horizon)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .huiTypography(.p2)
            .foregroundStyle(Color.huiColors.surface.institution)
            HorizonUI.ProgressBar(
                progress: 0.4,
                size: .small,
                numberPosition: .hidden,
                backgroundColor: Color.huiColors.surface.pageTertiary
            )
        }
    }

    private func defaultPill(title: String) -> some View {
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

#Preview {
    ProgramCardInProgressView(
        isEnrolled: true,
        isRequired: true,
        isLinear: true,
        estimatedTime: "10 hours",
        completionPercent: 0.3
    )
}
