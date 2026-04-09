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

import Combine
import Core
import SwiftUI

struct WeeklySummaryWidgetView: View {
    static let animation: Animation = .snappy
    static let weekTransitionOffsetMagnitude: CGFloat = 80

    @Environment(\.viewController) var controller
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @State private var weekTransitionOffset: CGFloat = 80

    var viewModel: WeeklySummaryWidgetViewModel

    init(viewModel: WeeklySummaryWidgetViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        DashboardTitledWidget(String(localized: "Weekly Summary", bundle: .student)) {
            if viewModel.state == .error {
                DashboardWidgetCard {
                    DashboardWidgetErrorView {
                        viewModel.retryRefresh()
                    }
                }
            } else {
                DashboardWidgetCard(background: .tint) {
                    VStack(spacing: 8) {
                        WeeklySummaryWidgetWeekSelectorView(viewModel: viewModel, transitionOffset: $weekTransitionOffset)
                        VStack(spacing: 8) {
                            WeeklySummaryWidgetSegmentedControl(viewModel: viewModel)
                            if let expanded = viewModel.expandedFilter {
                                assignmentList(filter: expanded)
                            }
                        }
                        .redacted(reason: viewModel.state == .loading || viewModel.isWeekLoading ? .placeholder : [])
                        .allowsHitTesting(viewModel.state != .loading && !viewModel.isWeekLoading)
                    }
                    .paddingStyle(.top, .sectionHeaderVertical)
                    .paddingStyle(.horizontal, .standard)
                    .paddingStyle(.bottom, .standard)
                }
                .animation(Self.animation, value: viewModel.expandedFilter?.assignments.map(\.id))
                .animation(Self.animation, value: viewModel.weekStartDate)
            }
        } trailingContent: {
            currentWeekButton
        }
        .animation(Self.animation, value: viewModel.state)
        .animation(Self.animation, value: viewModel.isCurrentWeek)
    }

    private var currentWeekButton: some View {
        Button {
            weekTransitionOffset = viewModel.isFutureWeek
                ? -Self.weekTransitionOffsetMagnitude
                : Self.weekTransitionOffsetMagnitude
            withAnimation(Self.animation) {
                viewModel.navigateToCurrentWeek()
            }
        } label: {
            AUI.PillContent(
                title: String(localized: "Current Week", bundle: .student),
                trailingIcon: .calendarTab,
                size: .height24
            )
        }
        .buttonStyle(.pillTintFilled)
        .hidden(viewModel.isCurrentWeek)
        .identifier("Dashboard.Forecast.currentWeekButton")
    }

    @ViewBuilder
    private func assignmentList(filter: WeeklySummaryWidgetFilterViewModel) -> some View {
        if filter.assignments.isEmpty {
            WeeklySummaryWidgetEmptyView(filter: filter)
                .transition(.opacity.combined(with: .offset(y: -20)))
        } else {
            WeeklySummaryWidgetAssignmentListView(
                viewModel: viewModel,
                assignments: filter.assignments,
                controller: controller
            )
            .transition(.opacity.combined(with: .offset(y: -20)))
        }
    }
}

#if DEBUG

#Preview("Data") {
    @Previewable @State var subscriptions = Set<AnyCancellable>()
    @Previewable @State var viewModel = makeWeeklySummaryDataPreviewViewModel()

    WeeklySummaryWidgetView(viewModel: viewModel)
        .padding()
        .frame(maxHeight: .infinity, alignment: .top)
        .background(Color.backgroundLight)
        .tint(.course4)
        .onAppear {
            viewModel.refresh(ignoreCache: false)
                .sink { _ in }
                .store(in: &subscriptions)
        }
}

#Preview("Loading") {
    WeeklySummaryWidgetView(
        viewModel: WeeklySummaryWidgetViewModel(
            config: .make(id: .weeklySummary)
        )
    )
    .padding()
    .frame(maxHeight: .infinity, alignment: .top)
    .background(Color.backgroundLight)
    .tint(.course4)
}

#Preview("Error") {
    @Previewable @State var subscriptions = Set<AnyCancellable>()
    @Previewable @State var viewModel = makeWeeklySummaryErrorPreviewViewModel()

    WeeklySummaryWidgetView(viewModel: viewModel)
        .padding()
        .frame(maxHeight: .infinity, alignment: .top)
        .background(Color.backgroundLight)
        .tint(.course4)
        .onAppear {
            viewModel.refresh(ignoreCache: false)
                .sink { _ in }
                .store(in: &subscriptions)
        }
}

private func makeWeeklySummaryDataPreviewViewModel() -> WeeklySummaryWidgetViewModel {
    WeeklySummaryWidgetViewModel(config: .make(id: .weeklySummary))
}

private func makeWeeklySummaryErrorPreviewViewModel() -> WeeklySummaryWidgetViewModel {
    let mock = WeeklySummaryWidgetInteractorMock()
    mock.outputError = NSError.internalError()
    return WeeklySummaryWidgetViewModel(config: .make(id: .weeklySummary), interactor: mock)
}

#endif
