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

    let model: CourseTotalGradeModel

    var body: some View {
        ZStack(alignment: .top) {
            if model.isLoggedIn {
                if let data = model.data {
                    switch data.fetchResult {
                    case .grade(let attributes, let text):
                        CourseTotalGradeResultView(
                            attributes: attributes,
                            gradeView: {
                                Text(text.styledAsGrade())
                            }
                        )
                    case .noGrade(let attributes):
                        CourseTotalGradeResultView(
                            attributes: attributes,
                            gradeView: {
                                Text("No Grades")
                                    .font(.scaledRestrictly(.regular22))
                                    .foregroundStyle(Color.textDark)
                            }
                        )
                    case .restricted(let attributes):
                        CourseTotalGradeResultView(
                            attributes: attributes,
                            gradeView: {
                                Image
                                    .lockLine
                                    .scaledIcon(size: 24)
                                    .foregroundStyle(.textDark)
                            }
                        )
                    case .failure, .courseNotFound:
                        CourseTotalGradeStatusView(status: .failure)
                    }
                } else if model.isLoading {
                    Text("Loading")
                        .font(.scaledRestrictly(.regular12))
                        .foregroundStyle(.textDark)
                } else {
                    CourseTotalGradeNoCourseView()
                }
            } else {
                CourseTotalGradeStatusView(status: .loggedOut)
            }
        }
        .widgetURL(courseGradesURL)
        .containerBackground(Color.backgroundLightest, for: .widget)
    }

    private var courseGradesURL: URL? {
        guard model.isLoggedIn, let data = model.data else { return nil }
        return .gradesRoute(
            forCourse: data.courseID,
            color: data.fetchResult.attributes?.color?.hexString.dropFirst().description
        )
    }
}

#if DEBUG

struct CourseTotalGradeView_Previews: PreviewProvider {

    static var previews: some View {
        CourseTotalGradeView(
            model: CourseTotalGradeModel(
                isLoggedIn: true,
                data: CourseTotalGradeModel.Data(
                    courseID: "random-course-id",
                    fetchResult: .grade(
                        attributes: .init(
                            name: "Music Test Course",// something longer than three lines just to sho...",
                            color: .blue
                        ),
                        text: "78/100"
                    )
                )
            )
        )
        .previewContext(WidgetPreviewContext(family: .systemSmall))
        .previewDisplayName("Results")

        CourseTotalGradeView(
            model: CourseTotalGradeModel(
                isLoggedIn: false,
                data: nil
            )
        )
        .previewContext(WidgetPreviewContext(family: .systemSmall))
        .previewDisplayName("Loggedout")

        CourseTotalGradeView(
            model: CourseTotalGradeModel(
                isLoggedIn: true,
                data: CourseTotalGradeModel.Data(
                    courseID: "random-course-id",
                    fetchResult: .failure(
                        attributes: .init(
                            name: "Music Test Course",
                            color: .blue
                        ),
                        error: "Random error"
                    )
                )
            )
        )
        .previewContext(WidgetPreviewContext(family: .systemSmall))
        .previewDisplayName("Failure")

        CourseTotalGradeView(
            model: CourseTotalGradeModel(
                isLoggedIn: true,
                data: nil,
                isLoading: true
            )
        )
        .previewContext(WidgetPreviewContext(family: .systemSmall))
        .previewDisplayName("Loading")
    }
}

#endif
