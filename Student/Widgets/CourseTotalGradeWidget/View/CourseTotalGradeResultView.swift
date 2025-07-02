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

struct CourseTotalGradeResultView<GradeView: View>: View {

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let attributes: CourseTotalGradeModel.CourseAttributes
    @ViewBuilder let gradeView: () -> GradeView

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image("student-logomark")
                    .scaledIcon(size: 24)
                    .dynamicTypeSize(...DynamicTypeSize.accessibility2)
                Text("Grade")
                    .font(.scaledRestrictly(.semibold14))
                    .foregroundStyle(.textDarkest)
                Spacer()
            }
            .accessibilityElement()
            .accessibilityLabel(Text("Canvas single grade widget"))

            VStack(alignment: .leading, spacing: 8) {
                Text(attributes.name)
                    .font(.scaledRestrictly(.regular14))
                    .foregroundStyle(attributes.color ?? .gray)
                    .lineLimit(lineLimit)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)

                gradeView()
            }
        }
        .frame(maxHeight: .infinity, alignment: .top)
    }

    private var lineLimit: Int {
        return dynamicTypeSize > .xxLarge ? 2 : 3
    }
}

#if DEBUG

struct CourseTotalGradeResultView_Previews: PreviewProvider {

    static var previews: some View {
        CourseTotalGradeResultView(
            attributes: .init(name: "Example Course", color: .red),
            gradeView: {
                Text("95 / 100".styledAsGrade())
            }
        )
        .defaultWidgetContainerBackground()
        .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}

#endif
