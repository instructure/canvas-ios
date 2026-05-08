//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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

import Core
import SwiftUI

struct WeeklySummaryWidgetWeekSelectorView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @AccessibilityFocusState private var isWeekRangeFocused: Bool
    var viewModel: WeeklySummaryWidgetViewModel
    @Binding var transitionOffset: CGFloat

    var body: some View {
        HStack(spacing: 8) {
            Button {
                transitionOffset = -WeeklySummaryWidgetView.weekTransitionOffsetMagnitude
                withAnimation(WeeklySummaryWidgetView.animation) {
                    viewModel.navigateToPreviousWeek()
                }
            } label: {
                Image.chevronRight
                    .scaledIcon(size: 18)
                    .rotationEffect(.degrees(180))
            }
            .accessibilityLabel(viewModel.previousWeekA11yLabel)
            .identifier("Dashboard.Forecast.prevWeekButton")
            .unredacted()

            Text(viewModel.weekRangeText)
                .font(.regular16)
                .frame(maxWidth: .infinity)
                .id(viewModel.weekStartDate)
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .offset(x: transitionOffset)),
                    removal: .opacity.combined(with: .offset(x: -transitionOffset))
                ))
                .accessibilityFocused($isWeekRangeFocused)
                .onChange(of: viewModel.isWeekRangeFocused) {
                    isWeekRangeFocused = true
                }

            Button {
                transitionOffset = WeeklySummaryWidgetView.weekTransitionOffsetMagnitude
                withAnimation(WeeklySummaryWidgetView.animation) {
                    viewModel.navigateToNextWeek()
                }
            } label: {
                Image.chevronRight
                    .scaledIcon(size: 18)
            }
            .accessibilityLabel(viewModel.nextWeekA11yLabel)
            .identifier("Dashboard.Forecast.nextWeekButton")
            .unredacted()
        }
        .padding(.vertical, 8)
        .foregroundStyle(Color.textLightest)
        .clipped()
    }
}

#if DEBUG

#Preview {
    WeeklySummaryWidgetWeekSelectorView(
        viewModel: WeeklySummaryWidgetViewModel(
            config: .make(id: .weeklySummary),
            router: PreviewEnvironment().router
        ),
        transitionOffset: .constant(80)
    )
    .padding(.horizontal, 16)
    .background(Color.course4)
}

#endif
