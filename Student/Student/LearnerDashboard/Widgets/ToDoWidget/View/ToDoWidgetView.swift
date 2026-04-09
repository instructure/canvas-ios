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
    @Environment(\.viewController) private var viewController
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private let viewModel: ToDoWidgetViewModel
    @State private var weekPagerProxy = WeekPagerProxy()

    @AccessibilityFocusState private var isTitleFocused: Bool

    init(viewModel: ToDoWidgetViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            widgetHeader

            ZStack(alignment: Alignment(horizontal: .center, vertical: .weekCenter)) {
                DashboardWidgetCard {
                    VStack(alignment: .center, spacing: 0) {
                        cardHeader
                            .padding(.bottom, 8)

                        weekPager
                            .alignmentGuide(.weekCenter) { $0[VerticalAlignment.center] }
                            .padding(.bottom, 8)

                        AUI.Divider()

                        dayContentView
                            .animation(.dashboardWidget, value: viewModel.layoutIdentifier)
                    }
                }

                // These need to be in a ZStack next to DashboardWidgetCard,
                // because otherwise the card would clip the offset navigation buttons.
                weekNavigationButtons
                    .alignmentGuide(.weekCenter) { d in d[VerticalAlignment.center] }
            }
        }
    }

    // MARK: - Widget header

    private var widgetHeader: some View {
        HStack(alignment: .center, spacing: 0) {
            widgetTitle
                .frame(maxWidth: .infinity, alignment: .leading)
            todayButton
                .opacity(viewModel.shouldShowTodayButton ? 1 : 0)
        }
        .padding(.bottom, 8)
    }

    private var widgetTitle: some View {
        Text("Daily To-do", bundle: .student)
            .font(.regular14, lineHeight: .fit)
            .foregroundStyle(.textDarkest)
            .accessibilityAddTraits(.isHeader)
            .accessibilityFocused($isTitleFocused)
    }

    private var todayButton: some View {
        Button {
            isTitleFocused = true // TODO: focus on the day button
            viewModel.didTapTodayButton()
            weekPagerProxy.scrollToToday()
        } label: {
            AUI.PillContent(
                title: String(localized: "Today", bundle: .student),
                trailingIcon: .calendarTodayLine,
                size: .height24
            )
        }
        .buttonStyle(.pillTintFilled)
        .identifier("Dashboard.Todo.todayButton")
    }

    // MARK: - Card Header

    private var cardHeader: some View {
        CardHeaderView(
            yearTitle: viewModel.yearTitle,
            monthTitle: viewModel.monthTitle,
            showCompleted: Bindable(viewModel).showCompleted
        )
    }

    private struct CardHeaderView: View {
        @Environment(\.dynamicTypeSize) private var dynamicTypeSize

        let yearTitle: String?
        let monthTitle: String
        @Binding var showCompleted: Bool

        var body: some View {
            HStack(alignment: .center, spacing: 8) {
                VStack(alignment: .leading, spacing: 0) {
                    if let yearTitle {
                        yearLabel(yearTitle)
                    }
                    monthLabel
                }

                showCompletedToggle
                    .padding(.vertical, 8)
            }
            .paddingStyle(.horizontal, .standard)
            .padding(.vertical, 8)
        }

        private func yearLabel(_ yearTitle: String) -> some View {
            Text(yearTitle)
                .font(.regular12, lineHeight: .fit)
                .foregroundStyle(.textDark)
        }

        private var monthLabel: some View {
            Text(monthTitle)
                .font(.semibold22)
                .foregroundStyle(.textDarkest)
        }

        private var showCompletedToggle: some View {
            AUI.Toggle(isOn: $showCompleted, labelAlignment: .trailing) {
                Text("Show Completed", bundle: .student)
                    .font(.regular14)
                    .applyTint()
            }
            .identifier("Dashboard.Todo.showCompletedToggle")
        }
    }

    // MARK: - Week pager

    private var weekPager: some View {
        ToDoWidgetWeekPagerView(
            viewModel: viewModel,
            proxy: weekPagerProxy,
            onWeekOffsetChange: { viewModel.setWeek(absoluteOffset: $0) },
            weekDaysForOffset: { viewModel.weekDays(forOffset: $0) }
        )
        .padding(.horizontal, 32)
        .accessibilityRepresentation {
            HStack(spacing: 0) {
                weekNavigationButton(toPrevious: true)
                ToDoWidgetWeekView(weekDays: viewModel.currentWeekDays, viewModel: viewModel)
                weekNavigationButton(toPrevious: false)
            }
        }
    }

    private var weekNavigationButtons: some View {
        HStack {
            weekNavigationButton(toPrevious: true)
            .offset(x: -8)
            Spacer()
            weekNavigationButton(toPrevious: false)
            .offset(x: 8)
        }
        .accessibilityHidden(true)
    }

    private func weekNavigationButton(toPrevious: Bool) -> some View {
        Button(
            action: {
                toPrevious ? weekPagerProxy.scrollToPreviousWeek() : weekPagerProxy.scrollToNextWeek()
            },
            label: {
                Image.chevronRight
                    .scaledIcon(size: 16, paddedTo: 24)
                    .foregroundStyle(.textLightest)
                    .rotationEffect(.degrees(toPrevious ? 180 : 0))
                    .background(Circle().fill(.tint))
            }
        )
        .accessibilityLabel(
            toPrevious
                ? String(localized: "Previous week", bundle: .student)
                : String(localized: "Next week", bundle: .student)
        )
        .identifier(
            toPrevious
                ? "Dashboard.Todo.prevWeekButton"
                : "Dashboard.Todo.nextWeekButton"
        )
    }

    // MARK: - Day Content

    @ViewBuilder
    private var dayContentView: some View {
        switch viewModel.state {
        case .loading:
            skeletonDayView
        case .error:
            errorDayView
        case .empty:
            emptyDayView
        case .data:
            listDayView
                .paddingStyle(.bottom, .standard)
            addToDoButton
                .paddingStyle(.bottom, .standard)
                .identifier("Dashboard.Todo.TodoList.addTodoButton")
        }
    }

    private var skeletonDayView: some View {
        let count = viewModel.itemCountPerDay[viewModel.selectedDay] ?? 2

        return VStack(spacing: 0) {
            ForEach(0..<count, id: \.self) { _ in
                ToDoSkeletonCell()
                AUI.Divider(.padded)
            }
        }
    }

    private var emptyDayView: some View {
        ToDoWidgetPandaView(
            pandaName: "PandaNoEvents",
            title: String(localized: "You're all done for now!", bundle: .student),
            subtitle: String(localized: "Looks like you're free for this day.\nDo you want to add some To-dos?", bundle: .student),
            button: {
                addToDoButton
                    .identifier("Dashboard.Todo.Empty.addTodoButton")
            }
        )
    }

    private var errorDayView: some View {
        ToDoWidgetPandaView(
            pandaName: "PandaUnsupported",
            title: String(localized: "Oops, something went wrong", bundle: .student),
            subtitle: String(localized: "We weren’t able to load your To-dos.\nTry again, or come back later.", bundle: .student),
            button: {
                Button {
                    viewModel.didTapRetryButton()
                } label: {
                    AUI.PillContent(
                        title: String(localized: "Refresh", bundle: .student),
                        leadingIcon: .refreshLine,
                        size: .height30
                    )
                }
                .buttonStyle(.pillTintFilled)
                .identifier("Dashboard.Todo.Error.retryButton")
            }
        )
    }

    private var listDayView: some View {
        ToDoWidgetListView(viewModel: viewModel.listViewModel)
    }

    private var addToDoButton: some View {
        Button {
            viewModel.didTapAddButton(from: viewController)
        } label: {
            AUI.PillContent(
                title: String(localized: "Add To-do", bundle: .student),
                leadingIcon: .addLine,
                size: .height30
            )
        }
        .buttonStyle(.pillTintFilled)
    }
}

// MARK: - Skeleton Cell

private struct ToDoSkeletonCell: View {
    @State private var isAnimating = false

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(.backgroundMedium)
                .scaledFrame(size: 24)

            VStack(alignment: .leading, spacing: 6) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(.backgroundMedium)
                    .scaledFrame(height: 14)

                RoundedRectangle(cornerRadius: 4)
                    .fill(.backgroundMedium)
                    .scaledFrame(height: 12)
                    .padding(.trailing, 60)
            }
        }
        .paddingStyle(.horizontal, .standard)
        .padding(.vertical, 12)
        .opacity(isAnimating ? 0.4 : 1.0)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
    }
}

private struct ToDoWidgetPandaView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let pandaName: String
    let title: String
    let subtitle: String
    let button: AnyView

    init(pandaName: String, title: String, subtitle: String, @ViewBuilder button: () -> some View) {
        self.pandaName = pandaName
        self.title = title
        self.subtitle = subtitle
        self.button = AnyView(button())
    }

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(pandaName, bundle: .core)
                .resizable()
                .scaledToFit()
                .scaledFrame(width: 64, height: 40, useIconScale: true)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 0) {
                Text(title)
                    .font(.semibold16, lineHeight: .fit)
                    .foregroundStyle(.textDarkest)
                    .padding(.bottom, 2)

                Text(subtitle)
                    .font(.regular14, lineHeight: .fit)
                    .foregroundStyle(.textDark)
                    .padding(.bottom, 12)

                button
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.leading, 8)
        .paddingStyle(.trailing, .standard)
        .paddingStyle(.top, .cellTop)
        .paddingStyle(.bottom, .cellBottom)
    }
}

extension VerticalAlignment {
    private struct WeekCenter: AlignmentID {
        static func defaultValue(in context: ViewDimensions) -> CGFloat {
            context[VerticalAlignment.center]
        }
    }

    fileprivate static let weekCenter = VerticalAlignment(WeekCenter.self)
}

#if DEBUG

import Combine

#Preview {
    @Previewable @State var viewModel = makePreviewViewModel()
    @Previewable @State var subscriptions = Set<AnyCancellable>()

    PreviewContainer {
        ToDoWidgetView(viewModel: viewModel)
            .paddingStyle(.horizontal, .standard)
            .onAppear {
                viewModel.refresh(ignoreCache: false)
                    .sink { _ in }
                    .store(in: &subscriptions)
            }
    }
}

private func makePreviewViewModel() -> ToDoWidgetViewModel {
    return ToDoWidgetViewModel(
        config: .make(id: .todo),
        interactor: TodoInteractorPreview(),
        router: AppEnvironment.shared.router,
        snackBarViewModel: SnackBarViewModel()
    )
}

#endif
