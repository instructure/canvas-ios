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

import WidgetKit
import SwiftUI

struct SmallGradeView: View {
    var body: some View {
        VStack(spacing: 10) {
            Text(NSLocalizedString("Grades", comment: ""))
                .font(.semibold12)
                .foregroundColor(.textDark)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(gradeItem.assignmentName)
                .font(.semibold12)
                .foregroundColor(gradeItem.color)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(gradeItem.grade)
                .font(.bold24)
                .frame(maxWidth: .infinity, alignment: .leading)
            Spacer()
        }.padding().widgetURL(gradeItem.route)
    }

    private let gradeItem: GradeItem

    init(gradeItem: GradeItem) {
        self.gradeItem = gradeItem
    }
}

#if DEBUG
struct SmallGradeViewPreviews: PreviewProvider {
    static var previews: some View {
        SmallGradeView(gradeItem: GradeItem(assignmentName: "Earth: The Pale Blue Dot on two lines", grade: "20 / 25", color: .crimson)).previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
#endif
