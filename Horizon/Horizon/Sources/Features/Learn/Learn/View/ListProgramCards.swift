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

    private let viewModel: ListProgramCardsViewModel
    private let programs: [ProgramCardModel]
    private let isLoading: Bool
    private let isLinear: Bool
    private let onTapSelect: (ProgramCardModel) -> Void
    private let onTapEnroll: (ProgramCardModel) -> Void

    // MARK: - Private Propertites

    private let coordinateSpaceID = "programID"
    private let indexCicleSize: CGFloat = 26
    @State private var selectCourse: ProgramCardModel?

    // MARK: - Init

    init(
        viewModel: ListProgramCardsViewModel,
        programs: [ProgramCardModel],
        isLinear: Bool,
        isLoading: Bool,
        onTapSelect: @escaping (ProgramCardModel) -> Void,
        onTapEnroll: @escaping (ProgramCardModel) -> Void
    ) {
        self.viewModel = viewModel
        self.programs = programs
        self.isLinear = isLinear
        self.isLoading = isLoading
        self.onTapSelect = onTapSelect
        self.onTapEnroll = onTapEnroll
    }

    var body: some View {
        ZStack(alignment: .leading) {
            if isLinear {
                drawLine(
                    from: viewModel.firstPoint?.point,
                    to: viewModel.lastPoint?.point,
                    color: Color.huiColors.lineAndBorders.lineStroke
                )

                // Completed line
                drawLine(
                    from: viewModel.firstPoint?.point,
                    to: viewModel.lastCompletedPoint?.point,
                    color: Color.huiColors.lineAndBorders.containerStroke
                )
            }

            VStack(spacing: .huiSpaces.space16) {
                ForEach(programs) { program in
                    Button {
                        if program.isEnrolled {
                            onTapSelect(program)
                        }
                    } label: {
                        contentView(program: program)
                    }
                    .buttonStyle(.plain)
                }
            }
            .coordinateSpace(name: coordinateSpaceID)
        }
    }

    private func contentView(program: ProgramCardModel) -> some View {
        HStack(spacing: .huiSpaces.space8) {
            if isLinear {
                indexView(program: program)
            }
            programCrard(program: program)
        }
        .readingFrame(coordinateSpace: .named(coordinateSpaceID)) { frame in
            guard isLinear, programs.count != viewModel.points.count else { return }
            let pointX = frame.minX + indexCicleSize / 2
            let pointY = frame.midY
            let point = CGPoint(x: pointX, y: pointY)
            viewModel.append(.init(point: point, isCompleted: program.status.isCompleted))
        }
    }
    private func programCrard(program: ProgramCardModel) -> some View {
        HorizonUI.ProgramCard(
            courseName: program.courseName,
            isEnrolled: program.isEnrolled,
            isSelfEnrolled: program.isSelfEnrolled,
            isRequired: program.isRequired,
            isLocked: program.isLocked,
            isLoading: .constant(selectCourse?.id == program.id ? isLoading : false),
            estimatedTime: program.estimatedTime,
            dueDate: program.dueDate,
            status: program.status
        ) {
            selectCourse = program
            onTapEnroll(program)
        }
    }

    private func indexView(program: ProgramCardModel) -> some View {
        Circle()
            .fill(Color.huiColors.primitives.white10)
            .frame(width: indexCicleSize, height: indexCicleSize)
            .background {
                Circle()
                    .stroke(program.status.borderColor, lineWidth: 1)
            }
            .overlay {
                Text(program.index.description)
                    .foregroundStyle(Color.huiColors.text.title)
                    .huiTypography(.labelSmallBold)
            }
            .hidden(!program.isRequired)
    }

    @ViewBuilder
    private func drawLine(
        from: CGPoint?,
        to: CGPoint?,
        color: Color
    ) -> some View {
        if let from, let to {
            Path { path in
                path.move(to: from)
                path.addLine(to: to)
            }
            .stroke(color, lineWidth: 1)
        }
    }
}

extension ListProgramCards {
    struct ProgramCardPoint: Equatable {
        let point: CGPoint
        let isCompleted: Bool
    }
}
