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
                    switch data.fetchResult {
                    case .grade(let attributes, let text):
                        CourseTodalGradeResultView(
                            attributes: attributes,
                            gradeView: {
                                Text(text)
                                    .font(.bold22)
                                    .foregroundStyle(Color.textDarkest)
                            }
                        )
                    case .noGrade(let attributes):
                        CourseTodalGradeResultView(
                            attributes: attributes,
                            gradeView: {
                                Text("No Grades")
                                    .font(.regular22)
                                    .foregroundStyle(Color.textDark)
                            }
                        )
                    case .restricted(let attributes):
                        CourseTodalGradeResultView(
                            attributes: attributes,
                            gradeView: {
                                Image
                                    .lockLine
                                    .scaledIcon(size: 24)
                                    .foregroundStyle(.textDark)
                            }
                        )
                    case .failure, .courseNotFound:
                        CourseTotalGradeErrorView()
                    }
                } else {
                    CourseTotalGradeNoCourseView()
                }
            } else {
                CourseTotalGradeLoggedoutView()
            }
        }
        .containerBackground(Color.backgroundLightest, for: .widget)
    }
}

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

#if DEBUG

struct CourseTotalGradeView_Previews: PreviewProvider {

    static var previews: some View {
        CourseTotalGradeView(
            model: CourseTotalGradeModel(
                isLoggedIn: true,
        //        data: nil
                data: CourseTotalGradeModel.Data(
                    courseID: "random-course-id",
                    fetchResult: .grade(
                        attributes: .init(
                            name: "Music Test Course",// something longer than three lines just to sho...",
                            color: .blue
                        ),
                        text: "87%"
                    )
                )
            )
        )
        .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}

#endif
