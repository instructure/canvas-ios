//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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
import SwiftUI

public struct GradeListView: View, ScreenViewTrackable {
    private enum AccessibilityFocusArea: Hashable, Equatable {
        case list, editor
    }

    // MARK: - Dependencies
    @ObservedObject private var viewModel: GradeListViewModel
    @ObservedObject private var offlineModeViewModel: OfflineModeViewModel
    @Environment(\.viewController) private var viewController
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    public let screenViewTrackingParameters: ScreenViewTrackingParameters

    // MARK: - Private properties
    @State private var offsets = CGSize.zero
    @State private var isScoreEditorPresented = false

    @State private var originalScrollOffset: CGFloat = 0
//    @State private var nonCollapsableHeaderHeight: CGFloat = 0
    @State private var scrollOffset: CGFloat?
    @State private var collapsableHeaderHeight: CGFloat = 0

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    private var toggleViewIsVisible: Bool {
        scrollOffset ?? 0 > originalScrollOffset - collapsableHeaderHeight
    }

    @AccessibilityFocusState private var accessibilityFocus: AccessibilityFocusArea?
    private var subscriptions = Set<AnyCancellable>()

    // MARK: - Init

    public init(
        viewModel: GradeListViewModel,
        offlineViewModel: OfflineModeViewModel = OfflineModeViewModel(interactor: OfflineModeAssembly.make())
    ) {
        self.viewModel = viewModel
        offlineModeViewModel = offlineViewModel
        screenViewTrackingParameters = ScreenViewTrackingParameters(
            eventName: "/courses/\(viewModel.courseID)/grades"
        )
    }

    // MARK: - Components

    public var body: some View {
        ZStack {
            ScrollView(showsIndicators: false) {
                contentView
            }
            .background(Color.backgroundLight)
            .accessibilityHidden(isScoreEditorPresented)
            .refreshable {
                await withCheckedContinuation { continuation in
                    viewModel.pullToRefreshDidTrigger.accept {
                        continuation.resume()
                    }
                }
            }

            whatIfScoreEditorView
        }
        .animation(.smooth, value: isScoreEditorPresented)
        .safeAreaInset(edge: .top, spacing: 0) {
            switch viewModel.state {
            case .data, .empty:
                nonCollapsableGradeDetails
//                    .readingFrame { frame in
//                        if nonCollapsableHeaderHeight != frame.height {
//                            nonCollapsableHeaderHeight = frame.height
//                        }
//                    }
            default: SwiftUI.EmptyView()
            }
        }
        .background(Color.backgroundLightest)
        .navigationBarTitleView(
            title: String(localized: "Grades", bundle: .core),
            subtitle: viewModel.courseName
        )
        .toolbar {
            RevertWhatIfScoreButton(isWhatIfScoreModeOn: viewModel.isWhatIfScoreModeOn) {
                viewModel.isShowingRevertDialog = true
            }
            ToolbarItem(placement: .primaryAction) {
                filterButton
            }
        }
        .navigationBarStyle(.color(nil))
        .confirmationAlert(
            isPresented: $viewModel.isShowingRevertDialog,
            presenting: viewModel.confirmRevertAlertViewModel
        )
    }

    private var filterButton: some View {
        Button {
            viewModel.navigateToFilter(viewController: viewController)
        } label: {
            Image.filterLine
                .size(24)
                .padding(5)
                .foregroundStyle(viewModel.isParentApp
                                 ? Color(Brand.shared.primary)
                                 : .textLightest)

        }
        .hidden(viewModel.state == .initialLoading)
        .accessibilityLabel(Text("Filter", bundle: .core))
        .accessibilityHint(Text("Filter grades options", bundle: .core))
        .accessibilityIdentifier("GradeList.filterButton")
    }

    @ViewBuilder
    private var contentView: some View {
        VStack(spacing: 0) {
            switch viewModel.state {
            case .data, .empty:
                collapsableToggles
                    .bindTopPosition(id: "collapsableHeader", coordinateSpace: .global, to: $scrollOffset)
                    .readingFrame { frame in
                        if collapsableHeaderHeight != frame.height {
                            collapsableHeaderHeight = frame.height
                        }
                    }
//                    .onChange(of: scrollOffset) { _, _ in
//                        print("nonCollapsableHeaderHeight", nonCollapsableHeaderHeight)
//                        print("collapsableHeaderHeight", collapsableHeaderHeight)
//                        print("originalScrollOffset", originalScrollOffset)
//                        print("scrollOffset", scrollOffset ?? 0)
//                        print(originalScrollOffset - collapsableHeaderHeight)
//                        print("--------------------------------------------------------------------")
//
//                    }
                    .onFirstAppear {
                        originalScrollOffset = scrollOffset ?? 0
                    }
//                    .onAppear {
//                        originalScrollOffset = scrollOffset ?? 0
//                    }
            default:
                SwiftUI.EmptyView()
            }

            switch viewModel.state {
            case .initialLoading: loadingView
            case .data(let data): dataView(data)
            case .empty: emptyView
            case .error: errorView
            }
            Spacer()
        }
        .background(Color.backgroundLightest)
    }

    @ViewBuilder
    private var loadingView: some View {
        ProgressView()
            .progressViewStyle(.indeterminateCircle())
            .containerRelativeFrame([.vertical, .horizontal])
    }

    @ViewBuilder
    private func dataView(_ gradeListData: GradeListData) -> some View {
        assignmentListView(
            courseColor: gradeListData.courseColor,
            assignmentSections: gradeListData.assignmentSections,
            userID: gradeListData.userID ?? ""
        )
        .accessibilityFocused($accessibilityFocus, equals: .list)
    }

    @ViewBuilder
    private var gradeDetailsView: some View {
        HStack {
            totalLabelText
                .frame(maxWidth: .infinity, alignment: .leading)
            if let totalGrade = viewModel.totalGradeText {
                Text(totalGrade)
                    .foregroundStyle(Color.textDarkest)
                    .font(.semibold22)
                    .multilineTextAlignment(.center)
                    .accessibilityLabel(Text("Total grade is \(totalGrade)", bundle: .core))
                    .accessibilityIdentifier("CourseTotalGrade")
            } else {
                Image(uiImage: .lockLine)
                    .size(16)
                    .accessibilityHidden(true)
                    .accessibilityIdentifier("lockIcon")
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, verticalSizeClass == .regular ? 20 : 5)
        .background(
            Color.backgroundLightest
                .cornerRadius(6)
        )
        .shadow(color: Color.textDark.opacity(0.2), radius: 5, x: 0, y: 0)
    }

    @ViewBuilder
    private var nonCollapsableGradeDetails: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center) {
                gradeDetailsView
                if viewModel.isParentApp {
                    filterButton
                        .paddingStyle(.leading, .standard)
                }
            }
            .padding([.horizontal, .top], 16)
            .padding(.bottom, 10)
            .background(Color.backgroundLight)
            .overlay(alignment: .bottom) {
                if !toggleViewIsVisible {
                    InstUI.Divider()
                }
            }
        }
    }

    @ViewBuilder
    private var collapsableToggles: some View {
        VStack(spacing: 0) {
            if viewModel.totalGradeText != nil {
                togglesView
                    .frame(minHeight: 51)
                    .padding(.horizontal, 16)
            }
            InstUI.Divider()
        }
        .background(Color.backgroundLight)
    }

    @ViewBuilder
    private var emptyView: some View {
        InteractivePanda(
            scene: SpacePanda(),
            title: String(localized: "No Assignments", bundle: .core),
            subtitle: String(localized: "It looks like assignments haven’t been created in this space yet.", bundle: .core)
        )
        .padding(.horizontal, 16)
        .containerRelativeFrame([.horizontal, .vertical])
        .accessibilityIdentifier("GradeList.emptyView")
    }

    @ViewBuilder
    private var errorView: some View {
        InteractivePanda(
            scene: NoResultsPanda(),
            title: String(localized: "Something Went Wrong", bundle: .core),
            subtitle: String(localized: "Pull to refresh to try again.", bundle: .core)
        )
        .padding(.horizontal, 16)
        .listSectionSeparator(.hidden)
        .listSectionSeparatorTint(Color.clear)
        .listRowBackground(Color.clear)
        .containerRelativeFrame([.horizontal, .vertical])
    }

    @ViewBuilder
    private var totalLabelText: some View {
        let isShowGradeAssignment = !toggleViewIsVisible &&
        viewModel.baseOnGradedAssignment &&
        viewModel.totalGradeText != nil

        let totalText = String(localized: "Total", bundle: .core)
        let restrictedText = String(localized: "Total grades are restricted", bundle: .core)
        let gradedAssignmentsText = String(localized: "Based on graded assignments", bundle: .core)
        let text = isShowGradeAssignment ? gradedAssignmentsText : totalText
        Text(viewModel.totalGradeText == nil ? restrictedText : text)
            .foregroundStyle(Color.textDark)
            .font(.regular14)
            .accessibilityHidden(true)
            .animation(.smooth, value: isShowGradeAssignment)
            .lineLimit(1)
    }

    @ViewBuilder
    private func totalGradeText(_ totalGrade: String) -> some View {
        Text(totalGrade)
            .foregroundStyle(Color.textDarkest)
            .font(.semibold22)
            .multilineTextAlignment(.center)
            .accessibilityLabel(Text("Total grade is \(totalGrade)", bundle: .core))
            .accessibilityIdentifier("CourseTotalGrade")
    }

    @ViewBuilder
    private var togglesView: some View {
        VStack(spacing: 0) {
            InstUI.Toggle(isOn: $viewModel.baseOnGradedAssignment) {
                Text("Based on graded assignments", bundle: .core)
                    .foregroundStyle(Color.textDarkest)
                    .font(.regular16)
                    .multilineTextAlignment(.leading)
            }
            .frame(minHeight: 51)
            .accessibilityIdentifier("BasedOnGradedToggle")

            if viewModel.isWhatIfScoreFlagEnabled {
                Divider()

                InstUI.Toggle(isOn: $viewModel.isWhatIfScoreModeOn) {
                    Text("Show What-if Score", bundle: .core)
                        .foregroundStyle(Color.textDarkest)
                        .font(.regular16)
                        .multilineTextAlignment(.leading)
                }
                .frame(minHeight: 51)
            }
        }
    }

    @ViewBuilder
    private func assignmentListView(
        courseColor: UIColor?,
        assignmentSections: [GradeListData.AssignmentSections],
        userID: String
    ) -> some View {
        LazyVStack(spacing: 0, pinnedViews: .sectionHeaders) {
            ForEach(assignmentSections, id: \.id) { section in
                let itemCountLabel = String.localizedNumberOfItems(section.assignments.count)
                AssignmentSection {
                    VStack(spacing: 0) {
                        listSectionView(title: section.title)
                            .frame(height: 40)
                            .paddingStyle(.horizontal, .standard)
                    }
                    .accessibilityLabel(Text(verbatim: "\(section.title), \(itemCountLabel)"))
                } content: {
                    ForEach(section.assignments, id: \.id) { assignment in
                        VStack(alignment: .leading, spacing: 0) {
                            listRowView(
                                assignment: assignment,
                                userID: userID,
                                courseColor: courseColor
                            )

                            if assignment.id != section.assignments.last?.id {
                                InstUI.Divider()
                                    .paddingStyle(.horizontal, .standard)
                                    .accessibilityHidden(true)
                            }
                        }.id(assignment.id)
                    }
                }
            }
        }

        Color.backgroundLightest
            .frame(height: 30)
    }

    @ViewBuilder
    private func listSectionView(title: String?) -> some View {
        Text(title ?? "")
            .foregroundStyle(Color.textDark)
            .font(.semibold14)
            .frame(maxWidth: .infinity, minHeight: 40, alignment: .leading)
    }

    @ViewBuilder
    private func listRowView(
        assignment: Assignment,
        userID: String,
        courseColor _: UIColor?
    ) -> some View {
        Button {
            viewModel.didSelectAssignment.accept((viewController, assignment))
        } label: {
            GradeRowView(
                assignment: assignment,
                userID: userID,
                isWhatIfScoreModeOn: viewModel.isWhatIfScoreModeOn
            ) {
                isScoreEditorPresented.toggle()
            }
            .onSwipe(trailing: revertWhatIfScoreSwipeButton(id: assignment.id))
            .contentShape(Rectangle())
        }
        .background(Color.backgroundLightest)
        .buttonStyle(ContextButton(contextColor: viewModel.courseColor))
        .accessibilityAction(named: Text("Edit What-if score", bundle: .core)) {
            isScoreEditorPresented.toggle()
        }
        .accessibilityAction(named: Text("Revert to official score", bundle: .core)) {
            viewModel.isShowingRevertDialog = true
        }
    }

    @ViewBuilder
    private var whatIfScoreEditorView: some View {
        if isScoreEditorPresented {
            WhatIfScoreEditorView(isPresented: $isScoreEditorPresented) {}
                .accessibilitySortPriority(1)
                .accessibilityFocused($accessibilityFocus, equals: .editor)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                        accessibilityFocus = .editor
                    }
                }
                .onDisappear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                        accessibilityFocus = .list
                    }
                }
        }
    }

    private func revertWhatIfScoreSwipeButton(id: String) -> [SwipeModel] {
        let slot = SwipeModel(id: id,
                              image: { Image(uiImage: .replyLine)},
                              action: { viewModel.isShowingRevertDialog = true },
                              style: .init(background: Color.backgroundDark))
        return viewModel.isWhatIfScoreModeOn ? [slot] : []
    }
}

// This is workaround, because .toolbar doesn't allow optional `ToolBarContent`.
private struct RevertWhatIfScoreButton: ToolbarContent {
    let isWhatIfScoreModeOn: Bool
    let buttonDidTap: () -> Void

    var body: some ToolbarContent {
        ToolbarItemGroup(placement: .navigationBarTrailing) {
            if isWhatIfScoreModeOn {
                Button(action: {
                    buttonDidTap()
                }) {
                    Image(uiImage: .replyLine)
                        .resizable()
                        .foregroundColor(.textLightest.variantForLightMode)
                }
                .frame(alignment: .leading)
                .accessibilityLabel(Text("Revert", bundle: .core))
                .accessibilityHint(Text("Double tap to revert to official score.", bundle: .core))
            }
        }
    }
}

extension Assignment: Identifiable {}
extension GradingPeriod: Identifiable {}

#if DEBUG
struct GradeListViewPreview: PreviewProvider {
    static var previews: some View {
        GradeListView(
            viewModel: .init(
                interactor: GradeListInteractorPreview(),
                gradeFilterInteractor: GradeFilterInteractorLive(
                    appEnvironment: .shared,
                    courseId: "courseId"
                ),
                router: PreviewEnvironment.shared.router
            )
        )
    }
}

#endif
