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

import HorizonUI
import SwiftUI

struct TimeSpentWidgetListCursesView: View {
    @State private var isCourseListVisible = false
    let courses: [TimeSpentWidgetModel]
    @State var selectedCourse: TimeSpentWidgetModel?
    let onSelect: (TimeSpentWidgetModel?) -> Void

    var body: some View {
        TimeSpentWidgetCourseButton(
            courseName: selectedCourse?.courseName ?? "",
            isSelected: selectedCourse != nil
        ) {
            isCourseListVisible.toggle()
        }
        .accessibilityLabel(Text(selectedCourse?.titleAccessibilityButtonLabel ?? ""))
        .accessibilityHint(Text("Double tab to select a different course", bundle: .horizon))
        .popover(isPresented: $isCourseListVisible, attachmentAnchor: .point(.center), arrowEdge: .top) {
            courseListView
                .presentationCompactAdaptation(.none)
                .presentationBackground(Color.huiColors.surface.cardPrimary)
        }
    }

    private var courseListView: some View {
        ScrollView {
            VStack(spacing: .zero) {
                ForEach(courses) { course in
                    Button {
                        selectedCourse = course
                        onSelect(course)
                        isCourseListVisible.toggle()
                    } label: {
                        TimeSpentCourseView(
                            name: course.courseName,
                            isSelected: course == selectedCourse
                        )
                    }
                    .accessibilityLabel(Text(course.titleAccessibilityLabel))
                }
            }
        }
    }
}

#Preview {
    TimeSpentWidgetListCursesView(courses: [
        .init(id: "1", courseName: "Introduction to SwiftUI", minutesPerDay: 125),
        .init(id: "2", courseName: "Advanced iOS Development", minutesPerDay: 90),
        .init(id: "3", courseName: "UI/UX Design Principles", minutesPerDay: 45)
    ]) { _ in }
}
