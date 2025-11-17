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
    @State private var currentCardIndex: Int? = 0

    // MARK: - Dependencies

    private let programs: [Program]
    private let onTap: (Program) -> Void

    // MARK: - Init

    init(
        programs: [Program],
        onTap: @escaping (Program) -> Void
    ) {
        self.programs = programs
        self.onTap = onTap
    }

    var body: some View {
        ScrollView(.horizontal) {
            HStack(alignment: .center, spacing: .huiSpaces.space12) {
                ForEach(Array(programs.enumerated()), id: \.offset) { index, program in
                    programView(program: program)
                        .id(index)
                        .scaleEffect(
                            currentCardIndex == index ? 1 : 0.8,
                            anchor: (currentCardIndex ?? 0) < index ? .leading : .trailing
                        )
                }
            }
            .scrollTargetLayout()
            .padding(.bottom, .huiSpaces.space16)
        }
        .animation(.smooth, value: currentCardIndex)
        .scrollPosition(id: $currentCardIndex)
        .scrollTargetBehavior(.viewAligned)
        .contentMargins(.horizontal, HorizonUI.spaces.space24, for: .scrollContent)
        .scrollIndicators(.hidden)
        .onChange(of: restoreFocusTrigger) { _, _ in
            if let lastFocused = lastFocusedElement.wrappedValue,
               case .programInvitation(let id) = lastFocused {
                DispatchQueue.main.async {
                    focusedProgramID = id
                }
            }
        }
    }

    private func programView(program: Program) -> some View {
        Button {
            onTap(program)
            lastFocusedElement.wrappedValue = .programInvitation(id: program.id)

        } label: {
            UnenrolledProgramListItemWidgetView(
                program: program,
                currentIndex: currentCardIndex ?? 0,
                totalCount: programs.count,
                isCounterVisible: programs.count > 1,
                focusedProgramID: $focusedProgramID
            )
        }
        .containerRelativeFrame(.horizontal)
    }

}

#Preview {
    UnenrolledProgramListWidgetView(
        programs: [
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
        ]
    ) { _ in }
}
