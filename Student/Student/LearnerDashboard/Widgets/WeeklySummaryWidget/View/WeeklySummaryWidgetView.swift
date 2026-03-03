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
    @Environment(\.viewController) var controller
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    @State var viewModel: WeeklySummaryWidgetViewModel

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
                        WeeklySummaryWidgetWeekSelectorView(viewModel: viewModel)
                        WeeklySummaryWidgetSegmentedControl(viewModel: viewModel)
                        assignmentList
                    }
                    .redacted(reason: viewModel.state == .loading ? .placeholder : [])
                    .allowsHitTesting(viewModel.state != .loading)
                    .paddingStyle(.top, .sectionHeaderVertical)
                    .paddingStyle(.horizontal, .standard)
                    .paddingStyle(.bottom, .standard)
                }
                .animation(Self.animation, value: viewModel.expandedFilter)
                .animation(Self.animation, value: viewModel.weekStartDate)
            }
        }
        .animation(Self.animation, value: viewModel.state)
    }

    @ViewBuilder
    private var assignmentList: some View {
        ZStack {
            if let expanded = viewModel.expandedFilter {
                if expanded.assignments.isEmpty {
                    WeeklySummaryWidgetEmptyView(filter: expanded)
                        .transition(.opacity.combined(with: .offset(y: -20)))
                } else {
                    WeeklySummaryWidgetAssignmentListView(
                        viewModel: viewModel,
                        assignments: expanded.assignments,
                        controller: controller
                    )
                    .transition(.opacity.combined(with: .offset(y: -20)))
                }
            }
        }
        .frame(maxWidth: .infinity)
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
