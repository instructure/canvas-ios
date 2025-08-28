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

struct ProgramIndexCircleView: View {
    let program: ProgramCourse
    let indexCircleSize: CGFloat = 26

    var body: some View {
        Circle()
            .fill(Color.huiColors.primitives.white10)
            .frame(width: indexCircleSize, height: indexCircleSize)
            .background {
                Circle().stroke(circleBorderColor, lineWidth: 1)
            }
            .overlay {
                Text(program.index.description)
                    .foregroundStyle(Color.huiColors.text.title)
                    .huiTypography(.labelSmallBold)
            }
            .hidden(!program.isRequired)
    }

    private var circleBorderColor: Color {
        if program.isCompleted { return .huiColors.primitives.honey30 }
        return program.courseStatus == .locked
            ? .huiColors.lineAndBorders.lineStroke
            : .huiColors.lineAndBorders.containerStroke
    }
}
