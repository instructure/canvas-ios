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
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    @State private var weekPagerProxy = WeekPagerProxy()
    @State private var cardHeaderHeight: CGFloat = 42
    @ScaledMetric private var calendarRowHeight: CGFloat = 80

    var body: some View {
        VStack(
            alignment: .leading,
            spacing: InstUI.Styles.Padding.sectionHeaderVertical.rawValue
        ) {
            titleRow
            ZStack(alignment: .top) {
                DashboardWidgetCard {
                    VStack(spacing: 0) {
                        cardHeader
                        calendarRow
                        InstUI.Divider(.full)
                        contentView
                            .animation(.dashboardWidget, value: viewModel.layoutIdentifier)
                    }
                }
                HStack {
                    circleNavButton(
                        systemImage: "chevron.left",
                        a11yLabel: String(localized: "Previous week", bundle: .student)
                    ) {
                        weekPagerProxy.scrollToPreviousWeek()
                    }
                    .offset(x: -12)
                    Spacer()
                    circleNavButton(
                        systemImage: "chevron.right",
                        a11yLabel: String(localized: "Next week", bundle: .student)
                    ) {
                        weekPagerProxy.scrollToNextWeek()
                    }
                    .offset(x: 12)
                }
                .frame(height: calendarRowHeight + 16)
                .padding(.top, cardHeaderHeight)
            }
        }
        .snackBar(viewModel: viewModel.snackBarViewModel)
    }

    // MARK: - Title Row

    private var titleRow: some View {
        HStack(alignment: .center) {
            Text("Daily To-do", bundle: .student)
                .font(.regular14, lineHeight: .fit)
                .foregroundStyle(.textDarkest)
                .accessibilityAddTraits(.isHeader)
            Spacer()
            if !viewModel.isShowingToday {
                Button {
                    viewModel.navigateToToday()
                    weekPagerProxy.scrollToToday()
                } label: {
                    InstUI.PillContent(
                        title: String(localized: "Today", bundle: .core),
                        size: .height24
                    )
                }
                .buttonStyle(.pillTintFilled)
                .tint(.accentColor)
            }
        }
    }

    // MARK: - Card Header

    private var cardHeader: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 0) {
                if !isCurrentYear {
                    Text(viewModel.selectedDay.formatted(.dateTime.year()))
                        .font(.regular12, lineHeight: .fit)
                        .foregroundStyle(Color.textDark)
                }
                Text(viewModel.selectedDay.formatted(.dateTime.month(.wide)))
                    .font(.semibold22)
                    .foregroundStyle(Color.textDarkest)
            }
            Spacer()
            InstUI.Toggle(isOn: showCompletedBinding) {
                Text("Show Completed", bundle: .core)
                    .font(.regular14)
                    .foregroundStyle(Color.accentColor)
            }
            .fixedSize()
        }
        .paddingStyle(.horizontal, .standard)
        .padding(.top, 12)
        .padding(.bottom, 4)
        .background {
            GeometryReader { geometry in
                Color.clear
                    .onAppear { cardHeaderHeight = geometry.size.height }
                    .onChange(of: geometry.size.height) { _, value in cardHeaderHeight = value }
            }
        }
    }

    // MARK: - Calendar Row

    private var calendarRow: some View {
        ToDoWeekPager(
            viewModel: viewModel,
            proxy: weekPagerProxy,
            onWeekOffsetChanged: { viewModel.setWeek(absoluteOffset: $0) },
            weekDays: weekDays(forOffset:)
        )
        .frame(height: calendarRowHeight)
        .padding(.vertical, 8)
    }

    // MARK: - Content

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
                Text("Oops, something went wrong", bundle: .student)
                    .textStyle(.infoDescription)
                Button(String(localized: "Refresh", bundle: .core)) {
                    viewModel.retryLoad()
                }
                .font(.semibold14)
                .foregroundStyle(Color.accentColor)
            }
            .padding()

        case .data, .empty:
            if viewModel.isDayLoading {
                skeletonView
            } else if viewModel.dayItems.isEmpty {
                emptyDayView
            } else {
                itemListView
            }
        }
    }

    private var skeletonView: some View {
        VStack(spacing: 0) {
            ForEach(0..<3, id: \.self) { _ in
                ToDoSkeletonCell()
                InstUI.Divider(.padded)
            }
        }
    }

    private var emptyDayView: some View {
        HStack(spacing: 12) {
            Image.emptyLine
                .scaledIcon(size: 48)
                .foregroundStyle(Color.textLight)

            VStack(alignment: .leading, spacing: 4) {
                Text("You're all done for now!", bundle: .student)
                    .font(.semibold16)
                    .foregroundStyle(Color.textDarkest)
                Text("Looks like you're free for this day. Do you want to add some To-dos?", bundle: .student)
                    .font(.regular14)
                    .foregroundStyle(Color.textDark)
                addToDoButton
                    .padding(.top, 4)
            }

            Spacer(minLength: 0)
        }
        .paddingStyle(.horizontal, .standard)
        .padding(.vertical, 16)
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
                    isSwiping: .constant(false)
                )
                .paddingStyle(.leading, .standard)
                InstUI.Divider(.padded)
            }
            addToDoButton
                .padding(.horizontal, 80)
                .padding(.vertical, 16)
        }
    }

    private var addToDoButton: some View {
        Button {
            viewModel.createToDo(from: viewController)
        } label: {
            InstUI.PillContent(
                title: String(localized: "Add To-do", bundle: .student),
                leadingIcon: Image.noteLine,
                size: .height30
            )
        }
        .buttonStyle(.pillTintFilled)
        .tint(.accentColor)
    }

    // MARK: - Helpers

    private var isCurrentYear: Bool {
        Calendar.current.isDate(viewModel.selectedDay, equalTo: Clock.now, toGranularity: .year)
    }

    private var showCompletedBinding: Binding<Bool> {
        Binding(
            get: { viewModel.showCompleted },
            set: { _ in viewModel.toggleShowCompleted() }
        )
    }

    private func weekDays(forOffset offset: Int) -> [Date] {
        let base = Calendar.current.dateInterval(of: .weekOfYear, for: Clock.now)?.start
            ?? Calendar.current.startOfDay(for: Clock.now)
        guard let start = Calendar.current.date(byAdding: .weekOfYear, value: offset, to: base) else { return [] }
        return (0..<7).compactMap { Calendar.current.date(byAdding: .day, value: $0, to: start) }
    }

    private func circleNavButton(systemImage: String, a11yLabel: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.textLightest)
                .frame(width: 24, height: 24)
                .background(Circle().fill(Color.accentColor))
        }
        .accessibilityLabel(a11yLabel)
    }
}

// MARK: - Skeleton Cell

private struct ToDoSkeletonCell: View {
    @ScaledMetric private var uiScale: CGFloat = 1
    @State private var isAnimating = false

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color.backgroundMedium)
                .frame(width: 24 * uiScale, height: 24 * uiScale)

            VStack(alignment: .leading, spacing: 6) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.backgroundMedium)
                    .frame(height: 14 * uiScale)

                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.backgroundMedium)
                    .frame(height: 12 * uiScale)
                    .padding(.trailing, 60)
            }
        }
        .padding(.vertical, 12)
        .paddingStyle(.horizontal, .standard)
        .opacity(isAnimating ? 0.4 : 1.0)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                isAnimating = true
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
        snackBarViewModel: SnackBarViewModel(),
        sessionDefaults: AppEnvironment.shared.userDefaults ?? .fallback
    )
}

#endif
