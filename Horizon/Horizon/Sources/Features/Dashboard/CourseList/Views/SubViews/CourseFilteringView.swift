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

struct CourseFilteringView: View {
    @State var selectedStatus: CourseCardModel.CourseStatus?
    @State private var isListCoursesVisiable = false
    let onSelect: (CourseCardModel.CourseStatus?) -> Void

    var body: some View {
        CourseSelectionButton(status: selectedStatus?.name ?? "") {
            isListCoursesVisiable.toggle()
        }
        .frame(minWidth: 130)
        .accessibilityHint(Text("Double tab to select a different course", bundle: .horizon))
        .popover(isPresented: $isListCoursesVisiable, attachmentAnchor: .point(.center), arrowEdge: .top) {
            courseListView
                .presentationCompactAdaptation(.none)
                .presentationBackground(Color.huiColors.surface.cardPrimary)
        }
    }

    private var courseListView: some View {
        ScrollView {
            VStack(spacing: .zero) {
                ForEach(CourseCardModel.CourseStatus.allCases, id: \.self) { status in
                    Button {
                        selectedStatus = status
                        onSelect(status)
                        isListCoursesVisiable.toggle()
                    } label: {
                        TimeSpentCourseView(
                            name: status.name,
                            isSelected: status == selectedStatus
                        )
                    }
                }
            }
        }
    }
}
