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

struct UnenrolledProgramListItemWidgetView: View {
    let program: Program
    let currentIndex: Int
    let totalCount: Int
    let isCounterVisible: Bool
    let focusedProgramID: AccessibilityFocusState<String?>.Binding

    init(
        program: Program,
        currentIndex: Int,
        totalCount: Int,
        isCounterVisible: Bool,
        focusedProgramID: AccessibilityFocusState<String?>.Binding
    ) {
        self.program = program
        self.currentIndex = currentIndex
        self.totalCount = totalCount
        self.isCounterVisible = isCounterVisible
        self.focusedProgramID = focusedProgramID
    }

    var body: some View {
        VStack(alignment: .leading, spacing: .huiSpaces.space16) {
            HStack(spacing: .zero) {
                HorizonUI.StatusChip(
                    title: String(localized: "Program", bundle: .horizon),
                    style: .gray
                )
                .skeletonLoadable()
                .accessibilityHidden(true)
                Spacer()

                if isCounterVisible {
                    countView
                        .accessibilityHidden(true)
                }
            }

            Text(descriptionText)
                .foregroundStyle(Color.huiColors.text.body)
                .huiTypography(.p1)
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)
                .skeletonLoadable()
                .accessibilityHidden(true)
        }
        .padding(.huiSpaces.space24)
        .background(Color.huiColors.surface.pageSecondary)
        .huiCornerRadius(level: .level5)
        .huiElevation(level: .level4)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(combinedAccessibilityLabel))
        .accessibilityFocused(focusedProgramID, equals: program.id)
    }

    private var countView: some View {
        Text(
            String(
                format: String(localized: "%@ of %@"),
                (currentIndex + 1).description,
                totalCount.description
            )
        )
        .huiTypography(.p1)
        .foregroundStyle(Color.huiColors.text.dataPoint)
        .skeletonLoadable()
    }

    private var descriptionText: String {
        String.localizedStringWithFormat(
            String(localized: "Welcome to %@ %@", bundle: .horizon),
            program.name,
            String(
                localized: "View your program to enroll in your first course.",
                bundle: .horizon
            )
        )
    }

    private var combinedAccessibilityLabel: String {
        var components: [String] = []
        components.append(String(localized: "Program"))
        components.append(descriptionText)
        if isCounterVisible {
            let counterText = String(
                format: String(localized: "Program %@ of %@"),
                (currentIndex + 1).description,
                totalCount.description
            )
            components.append(counterText)
        }

        return components.joined(separator: ", ")
    }
}

#Preview {
    @Previewable @AccessibilityFocusState var focusState: String?

    UnenrolledProgramListItemWidgetView(
        program: .init(
            id: "1",
            name: "Dolor Sit Amet Program",
            variant: "",
            description: "",
            date: nil,
            courseCompletionCount: 10,
            courses: []
        ),
        currentIndex: 0,
        totalCount: 10,
        isCounterVisible: true,
        focusedProgramID: $focusState
    )
}
