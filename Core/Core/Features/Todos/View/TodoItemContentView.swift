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

/// A reusable view component that displays the visual content of a TodoItemViewModel.
/// This component is used on the Todo List screen and on the Todo widget.
public struct TodoItemContentView: View {
    @ScaledMetric private var uiScale: CGFloat = 1

    public let item: TodoItemViewModel
    public let isCompactLayout: Bool
    private let verticalSpacing: CGFloat

    /// Initializes a TodoItemContentView
    /// - Parameters:
    ///   - item: The TodoItemViewModel to display
    ///   - isCompactLayout: If true, text will be limited to single lines with truncation and font sizes become smaller for better widget presentation.
    public init(item: TodoItemViewModel, isCompactLayout: Bool) {
        self.item = item
        self.isCompactLayout = isCompactLayout
        self.verticalSpacing = isCompactLayout ? 0 : 2
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: verticalSpacing) {
            contextSection
            titleSection
            timeSection
        }
        .multilineTextAlignment(.leading)
    }

    private var contextSection: some View {
        InstUI.JoinedSubtitleLabels(
            label1: {
                item.icon
                    .scaledIcon(size: 16)
                    .foregroundStyle(item.color)
                    .accessibilityHidden(true)
                    .padding(.top, uiScale * (isCompactLayout ? 1 : 2))
            },
            label2: {
                Text(item.contextName)
                    .foregroundStyle(item.color)
                    .font(isCompactLayout ? .regular12 : .regular14, lineHeight: .fit)
                    .lineLimit(isCompactLayout ? 1 : nil)
            },
            alignment: .top
        )
        .fixedSize(horizontal: false, vertical: true)
    }

    private var titleSection: some View {
        VStack(alignment: .leading, spacing: verticalSpacing) {
            Text(item.title)
                .font(isCompactLayout ? .semibold14 : .regular16, lineHeight: .fit)
                .foregroundStyle(.textDarkest)
                .lineLimit(isCompactLayout ? 1 : nil)
            if let subtitle = item.subtitle {
                Text(subtitle)
                    .font(isCompactLayout ? .regular12 : .regular14, lineHeight: .fit)
                    .foregroundStyle(.textDark)
                    .lineLimit(isCompactLayout ? 1 : nil)
            }
        }
    }

    private var timeSection: some View {
        Text(item.dateText)
            .font(isCompactLayout ? .regular12 : .regular14)
            .foregroundStyle(.textDark)
            .lineLimit(isCompactLayout ? 1 : nil)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#if DEBUG

#Preview(traits: .fixedLayout(width: 200, height: 400)) {
    VStack {
        TodoItemContentView(item: .make(), isCompactLayout: true)
            .background(.backgroundLightest)
        TodoItemContentView(item: .make(), isCompactLayout: false)
            .background(.backgroundLightest)
    }
    .frame(maxHeight: .infinity)
    .background(Color.backgroundDarkest)
}

#endif
