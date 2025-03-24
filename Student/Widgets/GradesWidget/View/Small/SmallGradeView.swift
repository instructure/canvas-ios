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
            Text("Grades")
                .font(.semibold12)
                .foregroundColor(.textDark)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(gradeItem.name)
                .font(.semibold12)
                .foregroundColor(gradeItem.color)
                .frame(maxWidth: .infinity, alignment: .leading)
                .lineLimit(40)
            Text(gradeItem.grade)
                .font(.bold24)
                .frame(maxWidth: .infinity, alignment: .leading)
                .minimumScaleFactor(0.5)
            Spacer(minLength: 0)
        }
        .widgetURL(gradeItem.route)
    }

    private let gradeItem: GradeItem

    init(gradeItem: GradeItem) {
        self.gradeItem = gradeItem
    }
}

#if DEBUG

struct SmallGradeViewPreviews: PreviewProvider {
    static var previews: some View {
        SmallGradeView(gradeItem: GradeItem(name: "Earth: The Pale Blue Dot on two lines or more since it's very long",
                                            grade: "95.50 / 100",
                                            color: .textDanger))
        .containerBackground(for: .widget) {
            SwiftUI.EmptyView()
        }
        .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}

#endif
