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

/// A reusable view component that displays the visual content of a TodoItem.
/// This component is used on the Todo List screen and on the Todo widget.
public struct TodoItemContentView: View {
    @ScaledMetric private var uiScale: CGFloat = 1

    public let item: TodoItem
    public let isCompactLayout: Bool

    /// Initializes a TodoItemContentView
    /// - Parameters:
    ///   - item: The TodoItem to display
    ///   - isCompactLayout: If true, text will be limited to single lines with truncation. If false, text can wrap to multiple lines for full display.
    public init(item: TodoItem, isCompactLayout: Bool) {
        self.item = item
        self.isCompactLayout = isCompactLayout
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            contextSection
            titleSection
            timeSection
        }
        .background(Color.backgroundLightest)
    }

    private var contextSection: some View {
        HStack(spacing: 5) {
            item.icon
                .scaledIcon(size: 16)
                .foregroundStyle(item.color)
                .accessibilityHidden(true)
                .frame(maxHeight: .infinity, alignment: .top)
            InstUI.Divider()
            Text(item.contextName)
                .foregroundStyle(item.color)
                .font(.regular12, lineHeight: .fit)
                .lineLimit(isCompactLayout ? 1 : nil)
        }
        .fixedSize(horizontal: false, vertical: true)
    }

    private var titleSection: some View {
        VStack(alignment: .leading) {
            Text(item.title)
                .font(.semibold14, lineHeight: .fit)
                .foregroundStyle(.textDarkest)
                .lineLimit(isCompactLayout ? 1 : nil)
            if let subtitle = item.subtitle {
                Text(subtitle)
                    .font(.regular12, lineHeight: .fit)
                    .foregroundStyle(.textDark)
                    .lineLimit(isCompactLayout ? 1 : nil)
            }
        }
    }

    private var timeSection: some View {
        Text(item.date.dateTimeStringShort)
            .font(.regular12)
            .foregroundStyle(.textDark)
            .lineLimit(isCompactLayout ? 1 : nil)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#if DEBUG

#Preview(traits: .fixedLayout(width: 300, height: 400)) {
    VStack {
        TodoItemContentView(item: .make(), isCompactLayout: true)
        TodoItemContentView(item: .make(), isCompactLayout: false)
    }
    .frame(maxHeight: .infinity)
    .background(Color.backgroundDarkest)
}

#endif
