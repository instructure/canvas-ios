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
            VStack(spacing: 21) {
                if !model.assignmentGrades.isEmpty {
                    HeaderView(title: NSLocalizedString("Assignment Grades", comment: ""))
                    ForEach(model.assignmentGrades, id: \.self) { gradeItem in
                        GradeItemView(item: gradeItem)
                    }
                }

                if !model.courseGrades.isEmpty {
                    HeaderView(title: NSLocalizedString("Course Grades", comment: ""))
                    ForEach(model.courseGrades, id: \.self) { gradeItem in
                        GradeItemView(item: gradeItem)
                    }
                }

                if shouldAddBottomSpacer {
                    Spacer()
                }
            }
        }.padding()
    }

    private let model: GradeModel
    private let lineCount: Int
    private let shouldAddBottomSpacer: Bool

    init(model: GradeModel, lineCount: Int, shouldAddBottomSpacer: Bool) {
        self.model = model.trimmed(to: lineCount)
        self.lineCount = lineCount
        self.shouldAddBottomSpacer = shouldAddBottomSpacer
    }
}

#if DEBUG
struct MediumLargeGradesViewPreview: PreviewProvider {
    static var previews: some View {
        let model = GradeModel.make()
        MediumLargeGradesView(model: model, lineCount: 2, shouldAddBottomSpacer: false).previewContext(WidgetPreviewContext(family: .systemMedium))
        MediumLargeGradesView(model: model, lineCount: 5, shouldAddBottomSpacer: true).previewContext(WidgetPreviewContext(family: .systemLarge))
    }
}
#endif
