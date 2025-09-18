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

struct ProgramLineView: View {
    let firstPoint: ListProgramCards.ProgramCardPoint?
    let lastPoint: ListProgramCards.ProgramCardPoint?
    let lastCompletedPoint: ListProgramCards.ProgramCardPoint?

    var body: some View {
        Group {
            drawLine(
                from: firstPoint?.point,
                to: lastPoint?.point,
                color: .huiColors.lineAndBorders.lineStroke
            )
            drawLine(
                from: firstPoint?.point,
                to: lastCompletedPoint?.point,
                color: .huiColors.lineAndBorders.containerStroke
            )
        }
    }

    @ViewBuilder
    private func drawLine(from: CGPoint?, to: CGPoint?, color: Color) -> some View {
        if let from, let to {
            Path {
                $0.move(to: from)
                $0.addLine(to: to)
            }
            .stroke(color, lineWidth: 1)
        }
    }
}
