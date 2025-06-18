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

struct CourseTodalGradeResultView<GradeView: View>: View {

    let attributes: CourseTotalGradeModel.CourseAttributes
    @ViewBuilder let gradeView: () -> GradeView

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image("student-logomark")
                    .scaledIcon(size: 24)
                Text("Grade")
                    .font(.semibold14)
                    .foregroundStyle(.textDarkest)
                Spacer()
            }

            VStack(alignment: .leading, spacing: 8) {
                Text(attributes.name)
                    .font(.regular14)
                    .foregroundStyle(attributes.color ?? .gray)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)

                gradeView()
            }
        }
        .frame(maxHeight: .infinity, alignment: .top)
    }
}
