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

struct GradeListView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.widgetFamily) internal var family

    private let model: GradeListModel
    private var items: [GradeListItem] {
        model.getItems(for: family, size: dynamicTypeSize)
    }

    init(model: GradeListModel) {
        self.model = model
    }

    var body: some View {
        VStack(spacing: 8) {
            ForEach(items) { item in
                GradeListItemView(item: item)
                if items.last != item {
                    InstUI.Divider()
                }
            }
        }
        .padding(10)
        .containerRelativeFrame(.vertical, alignment: .center)
    }
}

struct GradeListItemView: View {
    let item: GradeListItem

    var body: some View {
        Link(destination: item.courseGradesURL!) {
            HStack(spacing: 8) {
                Text(item.courseName)
                    .foregroundStyle(item.color)
                    .font(.regular14)
                    .lineLimit(2)
                Spacer()
                if item.hideGrade {
                    Image.lockLine
                        .scaledIcon(size: 16)
                        .foregroundStyle(.textDark)
                        .accessibilityLabel(item.gradeAccessibilityLabel)
                } else {
                    Text(item.grade)
                        .font(.semibold14)
                        .accessibilityLabel(item.gradeAccessibilityLabel)
                }
            }
        }
    }
}

// MARK: - Previews

#if DEBUG

#Preview("Medium", as: .systemMedium) {
    GradeListWidget()
} timeline: {
    GradeListWidgetEntry(data: GradeListModel.make(), date: Date())
}

#Preview("Large", as: .systemLarge) {
    GradeListWidget()
} timeline: {
    GradeListWidgetEntry(data: GradeListModel.make(), date: Date())
}

#endif
