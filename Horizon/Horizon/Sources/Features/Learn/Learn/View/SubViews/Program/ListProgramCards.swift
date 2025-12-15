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

struct ListProgramCards: View {
    // MARK: - Dependencies

    let programs: [ProgramCourse]
    let isLoading: Bool
    let isLinear: Bool
    let focusedID: AccessibilityFocusState<String?>.Binding
    let onTapSelect: (ProgramCourse) -> Void
    let onTapEnroll: (ProgramCourse) -> Void

    // MARK: - Private

    private enum Constants {
        static let coordinateSpaceID = "programID"
        static let indexCircleSize: CGFloat = 26
    }

    // MARK: - State

    @State private var selectedCourse: ProgramCourse?
    @State private var points: [ProgramCardPoint] = []

    // MARK: - Computed

    private var sortedPoints: [ProgramCardPoint] { points.sorted { $0.point.y < $1.point.y } }
    private var firstPoint: ProgramCardPoint? { sortedPoints.first }
    private var lastPoint: ProgramCardPoint? { sortedPoints.last }

    private var lastCompletedPoint: ProgramCardPoint? {

        guard let lastCompletedIndex = sortedPoints.lastIndex(where: { $0.isCompleted && $0.isRequired }) else {
            return nil
        }
        let nextIndex = lastCompletedIndex + 1
        let candidateIndex = (sortedPoints[safe: nextIndex]?.isRequired == true)
        ? nextIndex
        : lastCompletedIndex
        let safeIndex = min(candidateIndex, sortedPoints.count - 1)
        return sortedPoints[safe: safeIndex]
    }

    var body: some View {
        ZStack(alignment: .leading) {
            if isLinear {
                ProgramLineView(
                    firstPoint: firstPoint,
                    lastPoint: lastPoint,
                    lastCompletedPoint: lastCompletedPoint
                )
                .accessibilityHidden(true)
            }

            VStack(spacing: .huiSpaces.space16) {
                ForEach(programs) { program in
                    let status = ProgramCardStatus(
                        completionPercent: program.completionPercent,
                        status: program.status
                    )
                    Button {
                        if status == .notEnrolled, UIAccessibility.isVoiceOverRunning {
                            onTapEnroll(program)
                        } else {
                            onTapSelect(program)
                        }
                    } label: {
                        contentView(for: program, status: status)
                    }
                    .buttonStyle(.plain)
                }
            }
            .coordinateSpace(name: Constants.coordinateSpaceID)
        }
    }

    // MARK: - Subviews
    private func contentView(for program: ProgramCourse, status: ProgramCardStatus) -> some View {
        HStack(spacing: .huiSpaces.space8) {
            if isLinear { ProgramIndexCircleView(program: program).accessibilityHidden(true) }
            programCard(for: program, status: status)
        }
        .readingFrame(coordinateSpace: .named(Constants.coordinateSpaceID)) { frame in
            guard isLinear else { return }
            let point = CGPoint(
                x: frame.minX + Constants.indexCircleSize / 2,
                y: frame.midY
            )
            let isLastAndNotRequired = program.id == programs.last?.id && !program.isRequired
            if !isLastAndNotRequired {
                points.append(.init(point: point, isCompleted: program.isCompleted, isRequired: program.isRequired))
            }
        }
        .id(isLoading)
        .onChange(of: isLoading) { _, _ in
            points = []
        }
    }

    @ViewBuilder
    private func programCard(for program: ProgramCourse, status: ProgramCardStatus) -> some View {
        ProgramCardView(
            programCourse: program,
            isLinear: isLinear,
            status: status,
            isLoading: .constant(selectedCourse?.id == program.id ? isLoading : false)
        ) {
            selectedCourse = program
            onTapEnroll(program)
        }
        .identifier(program.id)
        .accessibilityFocused(focusedID, equals: program.id)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(program.accessibilityLabelText(status: status, isLinear: isLinear))
        .accessibilityHint(program.accessibilityHintString(status: status))
    }
}

extension ListProgramCards {
    struct ProgramCardPoint: Equatable {
        let point: CGPoint
        let isCompleted: Bool
        let isRequired: Bool
    }
}
