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
    @State private var toggleViewIsVisible = true
    public let screenViewTrackingParameters: ScreenViewTrackingParameters

    // MARK: - Private properties
    @State private var offsets = CGSize.zero
    @State private var isScoreEditorPresented = false
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
        GeometryReader { geometry in
            ZStack {
                ScrollView(showsIndicators: false) {
                    contentView(geometry: geometry)
                }
                .background(Color.backgroundLightest)
                .accessibilityHidden(isScoreEditorPresented)
                .refreshable {
                    await withCheckedContinuation { continuation in
                        viewModel.pullToRefreshDidTrigger.accept {
                            continuation.resume()
                        }
                    }
                }
                whatIfScoreEditorView()

                if viewModel.isLoaderVisible {
                    ProgressView()
                        .progressViewStyle(.indeterminateCircle())
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.backgroundLightest)

                }
            }
            .animation(.smooth, value: isScoreEditorPresented)
        }
        .safeAreaInset(edge: .top, spacing: 0) {
            if viewModel.gradeHeaderIsVisible {
                courseSummaryView(viewModel.totalGradeText)
            }
        }
        .background(Color.backgroundLightest)
        .navigationTitle(String(localized: "Grades", bundle: .core), subtitle: viewModel.courseName)
        .toolbar {
            RevertWhatIfScoreButton(isWhatIfScoreModeOn: viewModel.isWhatIfScoreModeOn) {
                viewModel.isShowingRevertDialog = true
            }
            ToolbarItem(placement: .primaryAction) {
                filterButton
            }
        }
        .confirmationAlert(
            isPresented: $viewModel.isShowingRevertDialog,
            presenting: viewModel.confirmRevertAlertViewModel
        )
    }

    private var filterButton: some View {
        Button(action: {
            viewModel.navigateToFilter(viewController: viewController)
        }) {
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

    private func contentView(geometry: GeometryProxy) -> some View {
        VStack(spacing: 0) {
            switch viewModel.state {
            case .initialLoading:
                loadingView(geometry: geometry)
            case let .data(data):
                dataView(
                    data,
                    isRefreshing: false,
                    isEmpty: false,
                    geometry: geometry
                )
            case let .empty(data):
                dataView(
                    data,
                    isRefreshing: false,
                    isEmpty: true,
                    geometry: geometry
                )
            case .error:
                ZStack(alignment: .center) {
                    errorView()
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
            Spacer()
        }
        .background(Color.backgroundLightest)
    }

    private func loadingView(geometry: GeometryProxy) -> some View {
        ZStack(alignment: .center) {
            ProgressView()
                .progressViewStyle(.indeterminateCircle())
        }
        .frame(width: geometry.size.width, height: geometry.size.height)
    }

    @ViewBuilder
    private func dataView(
        _ gradeListData: GradeListData,
        isRefreshing: Bool,
        isEmpty: Bool,
        geometry: GeometryProxy
    ) -> some View {
        if isEmpty {
            emptyView()
                .frame(width: geometry.size.width, height: geometry.size.height)
        } else {
            assignmentListView(
                courseColor: gradeListData.courseColor,
                assignmentSections: gradeListData.assignmentSections,
                userID: gradeListData.userID ?? ""
            )
            .accessibilityFocused($accessibilityFocus, equals: .list)
        }
    }

    private func gradeDetailsView(_ totalGrade: String?) -> some View {
        HStack {
            totalLabelText()
                .frame(maxWidth: .infinity, alignment: .leading)
            if let totalGrade {
                totalGradeText(totalGrade)
            } else {
                Image(uiImage: .lockLine)
                    .size(16)
                    .accessibilityHidden(true)
                    .accessibilityIdentifier("lockIcon")
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 20)
        .background(
            Color.backgroundLightest
                .cornerRadius(6)
        )
        .shadow(color: Color.textDark.opacity(0.2), radius: 5, x: 0, y: 0)
    }

    @ViewBuilder
    private func courseSummaryView(_ totalGrade: String?) -> some View {
        let hasBottomPadding = (totalGrade == nil || !toggleViewIsVisible)
        VStack(spacing: 0) {
            HStack(alignment: .center) {
                gradeDetailsView(totalGrade)
                if viewModel.isParentApp {
                    filterButton
                        .paddingStyle(.leading, .standard)
                }
            }
            .padding([.horizontal, .top], 16)
            .padding(.bottom, 5)
            .padding(.bottom, hasBottomPadding ? 10 : 0)

            if totalGrade != nil {
                if toggleViewIsVisible {
                    togglesView()
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .zIndex(-1)
                }
            }
            InstUI.Divider()
        }
        .background(Color.backgroundLight)
        .fixedSize(horizontal: false, vertical: true)
        .animation(.linear, value: toggleViewIsVisible)
    }

    @ViewBuilder
    private func emptyView() -> some View {
        InteractivePanda(
            scene: SpacePanda(),
            title: String(localized: "No Assignments", bundle: .core),
            subtitle: String(localized: "It looks like assignments haven’t been created in this space yet.", bundle: .core)
        )
        .padding(.horizontal, 16)
    }

    @ViewBuilder
    private func errorView() -> some View {
        Spacer()
        InteractivePanda(
            scene: NoResultsPanda(),
            title: String(localized: "Something Went Wrong", bundle: .core),
            subtitle: String(localized: "Pull to refresh to try again.", bundle: .core)
        )
        .padding(.horizontal, 16)
        .listSectionSeparator(.hidden)
        .listSectionSeparatorTint(Color.clear)
        .listRowBackground(Color.clear)
        Spacer()
    }

    @ViewBuilder
    private func totalLabelText() -> some View {
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
    private func togglesView() -> some View {
        VStack(spacing: 0) {
            Toggle(isOn: $viewModel.baseOnGradedAssignment) {
                Text("Based on graded assignments", bundle: .core)
                    .foregroundStyle(Color.textDarkest)
                    .font(.regular16)
                    .multilineTextAlignment(.leading)
            }
            .toggleStyle(SwitchToggleStyle(tint: Color(Brand.shared.primary)))
            .frame(minHeight: 51)
            .padding(.horizontal, 16)
            .accessibilityIdentifier("BasedOnGradedToggle")

            if viewModel.isWhatIfScoreFlagEnabled {
                Divider()

                Toggle(isOn: $viewModel.isWhatIfScoreModeOn) {
                    Text("Show What-if Score", bundle: .core)
                        .foregroundStyle(Color.textDarkest)
                        .font(.regular16)
                        .multilineTextAlignment(.leading)
                }
                .toggleStyle(SwitchToggleStyle(tint: Color(Brand.shared.primary)))
                .frame(minHeight: 51)
                .padding(.horizontal, 16)
            }
        }
    }

    @ViewBuilder
    private func assignmentListView(
        courseColor: UIColor?,
        assignmentSections: [GradeListData.AssignmentSections],
        userID: String
    ) -> some View {

        topView // For reading frame

        LazyVStack(spacing: 0, pinnedViews: .sectionHeaders) {
            ForEach(assignmentSections, id: \.id) { section in
                let itemCountLabel = String.localizedStringWithFormat(String(localized: "d_items", bundle: .core), section.assignments.count)
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

        Rectangle()
            .fill(Color.backgroundLightest)
            .frame(height: 30)

    }

    /// For reading frames while scrolling top and down
    private var topView: some View {
        Color.clear
            .frame(height: 0)
            .readingFrame { frame in
                toggleViewIsVisible = frame.minY > 0
            }
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
    private func whatIfScoreEditorView() -> some View {
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
