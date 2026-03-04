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

import Core
import SwiftUI

struct ToDoWidgetView: View {
    @State var viewModel: ToDoWidgetViewModel
    @Environment(\.viewController) private var viewController
    @State private var isSwiping = false

    var body: some View {
        DashboardTitledWidget(String(localized: "To Do", bundle: .student)) {
            VStack(spacing: 0) {
                ToDoWidgetWeekView(
                    selectedDay: viewModel.selectedDay,
                    weekStart: viewModel.weekStart,
                    datesWithItems: viewModel.datesWithItems,
                    isShowingCurrentWeek: viewModel.isShowingCurrentWeek,
                    onPreviousWeek: viewModel.navigateToPreviousWeek,
                    onNextWeek: viewModel.navigateToNextWeek,
                    onToday: viewModel.navigateToToday,
                    onSelectDay: viewModel.selectDay
                )

                InstUI.Divider(.full)

                contentView
                    .animation(.dashboardWidget, value: viewModel.dayItems.count)
            }
        }
        .snackBar(viewModel: viewModel.snackBarViewModel)
    }

    @ViewBuilder
    private var contentView: some View {
        switch viewModel.state {
        case .loading:
            HStack {
                Spacer()
                ProgressView()
                    .progressViewStyle(.indeterminateCircle(size: 32))
                Spacer()
            }
            .padding()

        case .error:
            VStack(spacing: 16) {
                Text("Something went wrong", bundle: .student)
                    .textStyle(.infoDescription)
                Button(String(localized: "Retry", bundle: .core)) {
                    viewModel.retryLoad()
                }
                .font(.semibold14)
                .foregroundStyle(Color.accentColor)
            }
            .padding()

        case .data, .empty:
            if viewModel.dayItems.isEmpty {
                emptyDayView
            } else {
                itemListView
            }
        }
    }

    private var emptyDayView: some View {
        VStack(spacing: 8) {
            EmptyPanda(
                .NoEvents,
                title: Text("No To-dos!", bundle: .student),
                message: Text("It looks like a great time to rest, relax, and recharge.", bundle: .core)
            )
            Button {
                viewModel.createToDo(from: viewController)
            } label: {
                Label {
                    Text("Add To Do", bundle: .core)
                } icon: {
                    Image.noteLine
                }
            }
            .font(.semibold14)
            .foregroundStyle(Color.accentColor)
            .padding(.bottom)
        }
    }

    private var itemListView: some View {
        VStack(spacing: 0) {
            ForEach(viewModel.dayItems, id: \.id) { item in
                TodoListItemCell(
                    item: item,
                    onTap: { item, vc in viewModel.didTapItem(item, vc) },
                    onMarkAsDone: { viewModel.markItemAsDone($0) },
                    onSwipe: { viewModel.handleSwipeAction($0) },
                    onSwipeCommitted: { viewModel.handleSwipeCommitted($0) },
                    isSwiping: $isSwiping
                )
                InstUI.Divider(.padded)
            }
        }
    }
}

#if DEBUG

#Preview {
    @Previewable @State var viewModel = makePreviewViewModel()
    @Previewable @State var subscriptions = Set<AnyCancellable>()

    ToDoWidgetView(viewModel: viewModel)
        .padding()
        .frame(maxHeight: .infinity, alignment: .top)
        .onAppear {
            viewModel.refresh(ignoreCache: false)
                .sink { _ in }
                .store(in: &subscriptions)
        }
}

import Combine

private func makePreviewViewModel() -> ToDoWidgetViewModel {
    let config = DashboardWidgetConfig(id: .toDo, order: 0, isVisible: true, settings: nil)
    let interactor = TodoInteractorPreview()
    return ToDoWidgetViewModel(
        config: config,
        interactor: interactor,
        router: AppEnvironment.shared.router,
        snackBarViewModel: SnackBarViewModel()
    )
}

#endif
