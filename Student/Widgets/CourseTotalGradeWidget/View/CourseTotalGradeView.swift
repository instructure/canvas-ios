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
import WidgetKit

struct CourseTotalGradeView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let model: CourseTotalGradeModel

    var body: some View {
        ZStack {
            if model.isLoggedIn {
                if let data = model.data {
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
                            Text(data.courseName)
                                .font(.regular14)
                                .foregroundStyle(data.courseColor ?? .gray)
                                .lineLimit(3)
                                .multilineTextAlignment(.leading)
                                .fixedSize(horizontal: false, vertical: true)

                            if let grade = data.grade {
                                if grade.locked {
                                    Image
                                        .lockLine
                                        .scaledIcon(size: 24)
                                        .foregroundStyle(.textDark)

                                } else {
                                    Text(grade.rawValue)
                                        .font(.bold22)
                                        .foregroundStyle(Color.textDarkest)
                                }
                            } else {
                                Text("No Grades")
                                    .font(.regular22)
                                    .foregroundStyle(Color.textDark)
                            }
                        }
                    }
                    .frame(maxHeight: .infinity, alignment: .top)
                } else {
                    Text("Select Course")
                }
            } else {
                Text("Logged out")
            }
        }
        .containerBackground(Color.backgroundLightest, for: .widget)
    }
}

#if DEBUG

#Preview(as: .systemSmall, widget: {
    CourseTotalGradeWidget()
}, timeline: {
    CourseTotalGradeModel(
        isLoggedIn: true,
//        data: nil
        data: CourseTotalGradeData(
            courseID: "random-course-id",
            courseName: "Music Test Course something longer than three lines just to sho...",
            courseColor: .blue,
            grade: .init("100%", locked: true)
        )
    )
})

#endif
