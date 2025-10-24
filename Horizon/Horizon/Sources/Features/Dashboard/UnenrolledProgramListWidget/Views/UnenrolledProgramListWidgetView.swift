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

struct UnenrolledProgramListWidgetView: View {
    @Environment(\.dashboardLastFocusedElement) private var lastFocusedElement
    @Environment(\.dashboardRestoreFocusTrigger) private var restoreFocusTrigger
    @AccessibilityFocusState private var focusedProgramID: String?
    @State private var transitionDirection: Edge = .leading

    // MARK: - Dependencies

    private let viewModel: UnenrolledProgramListWidgetViewModel
    private let onTap: (Program) -> Void

    // MARK: - Init

    init(
        viewModel: UnenrolledProgramListWidgetViewModel,
        onTap: @escaping (Program) -> Void
    ) {
        self.viewModel = viewModel
        self.onTap = onTap
    }

    var body: some View {
        VStack(alignment: .leading, spacing: .huiSpaces.space16) {
            if let program = viewModel.currentProgram {
                UnenrolledProgramListItemWidgetView(
                    program: program,
                    onTap: onTap,
                    focusedProgramID: $focusedProgramID
                )
                .id(viewModel.currentProgram?.id)
                .paginationTransition(transitionDirection)
                if viewModel.isNavigationButtonVisiable {
                    programNavigationButtons
                }
            }
        }
        .padding(.huiSpaces.space24)
        .background(Color.huiColors.surface.pageSecondary)
        .huiCornerRadius(level: .level5)
        .huiElevation(level: .level4)
        .onChange(of: restoreFocusTrigger) { _, _ in
            if let lastFocused = lastFocusedElement.wrappedValue,
               case .programInvitation(let id) = lastFocused {
                DispatchQueue.main.async {
                    focusedProgramID = id

                }
            }
        }
    }

    private var programNavigationButtons: some View {
        HStack {
            HorizonUI.IconButton(Image.huiIcons.chevronLeft, type: .grayOutline) {
                transitionDirection = .leading
                withAnimation(.spring(response: 0.45, dampingFraction: 0.8)) {
                    viewModel.goPreviousProgram()
                }

            }
            .disabled(!viewModel.isPreviousButtonEnabled)
            .opacity(viewModel.isPreviousButtonEnabled ? 1.0 : 0.5)
            .skeletonLoadable()
            .accessibilityLabel(Text("Go to the previous program"))
            .accessibilityAddTraits(.isButton)
            .accessibilityHidden(!viewModel.isPreviousButtonEnabled)

            Spacer()

            Text(
                String(
                    format: String(localized: "%@ of %@"),
                    (viewModel.currentInex + 1).description,
                    viewModel.programs.count.description
                )
            )
            .huiTypography(.p1)
            .foregroundStyle(Color.huiColors.text.title)
            .skeletonLoadable()
            .accessibilityLabel(
                Text(
                    String(
                        format: String(localized: "Program %@ of %@"),
                        (viewModel.currentInex + 1).description,
                        viewModel.programs.count.description
                    )
                )
            )

            Spacer()

            HorizonUI.IconButton(Image.huiIcons.chevronRight, type: .grayOutline) {
                transitionDirection = .trailing
                withAnimation(.spring(response: 0.45, dampingFraction: 0.8)) {
                    viewModel.goNextProgram()
                }
            }
            .disabled(!viewModel.isNextButtonEnabled)
            .opacity(viewModel.isNextButtonEnabled ? 1.0 : 0.5)
            .skeletonLoadable()
            .accessibilityLabel(Text("Go to the next program"))
            .accessibilityAddTraits(.isButton)
            .accessibilityHidden(!viewModel.isNextButtonEnabled)
        }
    }
}

#Preview {
    UnenrolledProgramListWidgetView(
        viewModel: .init(programs: [
            .init(
                id: "1",
                name: "Dolor Sit Amet Program",
                variant: "",
                description: "",
                date: nil,
                courseCompletionCount: 10,
                courses: []
            ),
            .init(
                id: "2",
                name: "Dolor Sit Amet Program - 2",
                variant: "",
                description: "",
                date: nil,
                courseCompletionCount: 10,
                courses: []
            )
        ])
    ) { _ in }
}
