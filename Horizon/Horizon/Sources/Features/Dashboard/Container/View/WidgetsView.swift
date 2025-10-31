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

struct WidgetsView: View {
    // MARK: - Private variables

    @State private var currentCardIndex: Int? = 0

    // MARK: - Dependencies

    let skillsCountWidgetView: SkillsCountWidgetView
    let timeSpentWidgetView: TimeSpentWidgetView
    let completedWidgetView: CompletedWidgetView

    init(
        skillsCountWidgetView: SkillsCountWidgetView,
        timeSpentWidgetView: TimeSpentWidgetView,
        completedWidgetView: CompletedWidgetView
    ) {
        self.skillsCountWidgetView = skillsCountWidgetView
        self.timeSpentWidgetView = timeSpentWidgetView
        self.completedWidgetView = completedWidgetView
    }

    var body: some View {
        ScrollView(.horizontal) {
            HStack(alignment: .center, spacing: .huiSpaces.space12) {
                widgetView(completedWidgetView, index: 0)
                widgetView(timeSpentWidgetView, index: 1)
                widgetView(skillsCountWidgetView, index: 2)
            }
            .scrollTargetLayout()
            .padding(.top, .huiSpaces.space12 - 4)
            .padding(.bottom, .huiSpaces.space16)
        }
        .animation(.smooth, value: currentCardIndex)
        .scrollPosition(id: $currentCardIndex)
        .scrollTargetBehavior(.viewAligned)
        .contentMargins(.horizontal, HorizonUI.spaces.space24, for: .scrollContent)
        .scrollIndicators(.hidden)
    }

    @ViewBuilder
    private func widgetView<Content: View>(
        _ content: Content,
        index: Int
    ) -> some View {
        content
            .id(index)
            .scaleEffect(scale(for: index), anchor: anchor(for: index))
    }

    private func scale(for index: Int) -> CGFloat {
        currentCardIndex == index ? 1 : 0.8
    }

    private func anchor(for index: Int) -> UnitPoint {
        (currentCardIndex ?? 0) < index ? .leading : .trailing
    }
}
