//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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

struct MediumLargeGradesView: View {
    var body: some View {
        ZStack(alignment: Alignment(horizontal: .trailing, vertical: .top)) {
            Image("student-logomark")
                .resizable()
                .frame(width: 24, height: 24)
            VStack {
                if !model.assignmentGrades.isEmpty {
                    HeaderView(title: NSLocalizedString("Assignment Grades", comment: ""))
                    Spacer().frame(maxHeight: 20)
                    ForEach(model.assignmentGrades, id: \.self) { gradeItem in
                        GradeItemView(item: gradeItem)

                        if gradeItem != model.assignmentGrades.last {
                            Spacer().frame(maxHeight: 20)
                        }
                    }
                }

                if !model.courseGrades.isEmpty {
                    if !model.assignmentGrades.isEmpty {
                        Spacer().frame(maxHeight: 20)
                    }
                    HeaderView(title: NSLocalizedString("Course Grades", comment: ""))
                    Spacer().frame(maxHeight: 20)
                    ForEach(model.courseGrades, id: \.self) { gradeItem in
                        GradeItemView(item: gradeItem)

                        if gradeItem != model.courseGrades.last {
                            Spacer().frame(maxHeight: 20)
                        }
                    }
                }

                Spacer()
            }.padding(.top, 4) // This is to vertically center the first header with the logo
        }.padding()
    }

    private let model: GradeModel
    private let lineCount: Int

    init(model: GradeModel, lineCount: Int) {
        self.model = model.trimmed(to: lineCount)
        self.lineCount = lineCount
    }
}

#if DEBUG
private enum PreviewConfig {
    struct Config: Hashable {
        let lineCount: Int
        let family: WidgetFamily
        let device: PreviewSimulator
    }

    static var previewConfigs: [Config] = {
        var previewConfigs: [Config] = []
        PreviewSimulator.allCases.forEach {
            previewConfigs += [
                Config(lineCount: 2, family: .systemMedium, device: $0),
                Config(lineCount: 5, family: .systemLarge, device: $0),
            ]
        }
        return previewConfigs
    }()

    static func preview(for model: GradeModel) -> some View {
        ForEach(PreviewConfig.previewConfigs, id: \.self) { config in
            MediumLargeGradesView(model: model, lineCount: config.lineCount)
                .previewContext(WidgetPreviewContext(family: config.family))
                .previewDevice(PreviewDevice(rawValue: config.device.rawValue))
                .previewDisplayName(config.device.rawValue)
        }
    }
}

struct AssignmentAndCourseGrades: PreviewProvider {
    static var previews: some View { PreviewConfig.preview(for: GradeModel.make()) }
}

struct CourseGrades: PreviewProvider {
    static var previews: some View { PreviewConfig.preview(for: GradeModel.makeWithOneCourse()) }
}

struct AssignmentGrades: PreviewProvider {
    static var previews: some View { PreviewConfig.preview(for: GradeModel.makeWithOneAssigmnent()) }
}

#endif
