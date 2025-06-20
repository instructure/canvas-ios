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

import WidgetKit
import SwiftUI
import Core

struct GradesListView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.widgetFamily) internal var family

    @ScaledMetric private var scale: CGFloat = 1

    private var initialItems: [GradesListItem]
    @State private var visibleItems: [GradesListItem] = []

    init(items: [GradesListItem]) {
        self.initialItems = items
    }

    var body: some View {
        VStack(spacing: 8) {
            ForEach(visibleItems) { item in
                HStack(spacing: 8) {
                    Text(item.courseName)
                        .foregroundStyle(item.color)
                        .font(.regular14)
                        .lineLimit(2)
                    Spacer()
                    Text(item.grade)
                        .font(.semibold14)
                }
                if visibleItems.last != item {
                    InstUI.Divider()
                }
            }
        }
        .padding(10)
        .containerRelativeFrame(.vertical, alignment: .center)
        .onAppear {
            filterItems()
        }
    }

    private func filterItems() {
        let maxLongLineCount = family == .systemMedium ? 2 : 6
        let maxItemCount = family == .systemMedium ? 3 : 7
        let longCourseNameCount = initialItems.filter {
            $0.courseName.count > 40
        }.count
        visibleItems = longCourseNameCount > maxLongLineCount ? Array(initialItems[0..<maxItemCount]) : initialItems
    }
}

// MARK: - Previews

#if DEBUG

#Preview("Medium - Long Course Names", as: .systemMedium) {
    GradesListWidget()
} timeline: {
    GradesListWidgetEntry(data: GradesListModel.makeWithLongCourseNames(), date: Date())
}

#Preview("Medium - One Long Course Name", as: .systemMedium) {
    GradesListWidget()
} timeline: {
    GradesListWidgetEntry(data: GradesListModel.makeWithOneLongCourseName(), date: Date())
}

#Preview("Medium - Regular Course Names", as: .systemMedium) {
    GradesListWidget()
} timeline: {
    GradesListWidgetEntry(data: GradesListModel.make(), date: Date())
}

#Preview("Large - Long Course Names", as: .systemLarge) {
    GradesListWidget()
} timeline: {
    GradesListWidgetEntry(data: GradesListModel.makeWithLongCourseNames(), date: Date())
}

#endif
