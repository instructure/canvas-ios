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
    let onTap: (Program) -> Void
    let focusedProgramID: AccessibilityFocusState<String?>.Binding

    init(
        program: Program,
        onTap: @escaping (Program) -> Void,
        focusedProgramID: AccessibilityFocusState<String?>.Binding
    ) {
        self.program = program
        self.onTap = onTap
        self.focusedProgramID = focusedProgramID
    }

    var body: some View {
        VStack(alignment: .leading, spacing: .huiSpaces.space16) {
            HorizonUI.StatusChip(
                title: String(localized: "Program", bundle: .horizon),
                style: .gray
            )
            .skeletonLoadable()

            Text(descriptionText)
            .foregroundStyle(Color.huiColors.text.body)
            .huiTypography(.p1)
            .frame(maxWidth: .infinity, alignment: .leading)
            .multilineTextAlignment(.leading)
            .skeletonLoadable()

            buttonView
        }
    }

    private var buttonView: some View {
        HorizonUI.PrimaryButton(
            String(localized: "Program details", bundle: .horizon),
            type: .black,
            isSmall: true,
            fillsWidth: true
        ) {
            onTap(program)
        }
        .accessibilityFocused(focusedProgramID, equals: program.id)
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
        onTap: { _ in },
        focusedProgramID: $focusState
    )
}
