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
                RefreshableScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        switch viewModel.state {
                        case .initialLoading:
                            loadingView()
                        case let .refreshing(data):
                            dataView(
                                data,
                                isRefreshing: true,
                                isEmpty: false
                            )
                        case let .data(data):
                            dataView(
                                data,
                                isRefreshing: false,
                                isEmpty: false
                            )
                        case let .empty(data):
                            dataView(
                                data,
                                isRefreshing: false,
                                isEmpty: true
                            )
                        case .error:
                            errorView()
                        }
                    }
                    .frame(width: geometry.size.width)
                    .frame(minHeight: geometry.size.height)
                } refreshAction: { endRefreshing in
                    viewModel.pullToRefreshDidTrigger.accept(endRefreshing)
                }
                .accessibilityHidden(isScoreEditorPresented)
                .background(Color.backgroundLightest)
                whatIfScoreEditorView()
            }
            .animation(.smooth, value: isScoreEditorPresented)
        }
        .navigationTitle(String(localized: "Grades", bundle: .core))
        .toolbar {
            RevertWhatIfScoreButton(isWhatIfScoreModeOn: viewModel.isWhatIfScoreModeOn) {
                viewModel.isShowingRevertDialog = true
            }
        }
        .confirmationAlert(
            isPresented: $viewModel.isShowingRevertDialog,
            presenting: viewModel.confirmRevertAlertViewModel
        )
    }

    @ViewBuilder
    private func loadingView() -> some View {
        ZStack {
            ProgressView()
                .progressViewStyle(.indeterminateCircle())
        }
    }

    @ViewBuilder
    private func dataView(
        _ gradeListData: GradeListData,
        isRefreshing: Bool,
        isEmpty: Bool
    ) -> some View {
        let verticalPadding: CGFloat = gradeListData.isGradingPeriodHidden && isEmpty ? 0 : 16
        courseSummaryView(
            courseName: gradeListData.courseName ?? "",
            totalGrade: gradeListData.totalGradeText,
            isEmpty: isEmpty && gradeListData.isGradingPeriodHidden
        )
        HStack(spacing: 8) {
            if !gradeListData.isGradingPeriodHidden {
                gradingPeriodMenu(
                    gradingPeriods: gradeListData.gradingPeriods,
                    currentGradingPeriod: gradeListData.currentGradingPeriod
                )
                .disabled(offlineModeViewModel.isOffline)
                .opacity(offlineModeViewModel.isOffline ? 0.5 : 1)
            }
            Spacer()
            if !isEmpty {
                sortByMenu()
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, verticalPadding)

        Divider()

        if isRefreshing {
            GeometryReader { proxy in
                loadingView()
                    .padding(.vertical, 16)
                    .frame(width: proxy.size.width)
                    .frame(minHeight: proxy.size.height)
            }
        } else if isEmpty {
            emptyView()
                .padding(.vertical, 16)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            assignmentListView(
                courseColor: gradeListData.courseColor,
                assignmentSections: gradeListData.assignmentSections,
                userID: gradeListData.userID
            )
            .frame(minHeight: 208, maxHeight: .infinity)
            .accessibilityFocused($accessibilityFocus, equals: .list)
        }
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
        Spacer()
    }

    @ViewBuilder
    private func courseSummaryView(
        courseName: String,
        totalGrade: String?,
        isEmpty: Bool
    ) -> some View {
        VStack(spacing: 0) {
            courseDetailsView(
                courseName: courseName,
                totalGrade: totalGrade
            )
            if totalGrade != nil {
                Divider()
                togglesView()
            }
        }
        .cornerRadius(6)
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color.borderDark, lineWidth: 0.5)
        )
        .padding(.horizontal, 16)
        .padding(.top, 16)
        .padding(.bottom, isEmpty ? 16 : 8)
    }

    @ViewBuilder
    private func courseDetailsView(
        courseName: String,
        totalGrade: String?
    ) -> some View {
        if let totalGrade {
            VStack(spacing: 4) {
                HStack(spacing: 4) {
                    courseLabelText()
                    Spacer()
                    totalLabelText()
                }
                HStack(spacing: 4) {
                    courseNameText(courseName)
                    Spacer()
                    totalGradeText(totalGrade)
                }
            }
            .padding(.top, 12)
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        } else {
            HStack(spacing: 4) {
                VStack(alignment: .leading, spacing: 4) {
                    courseLabelText()
                    courseNameText(courseName)
                }
                Spacer()
                Image(uiImage: .lockLine)
                    .resizable()
                    .frame(width: 40, height: 40)
                    .accessibilityIdentifier("lockIcon")
            }
            .padding(.top, 12)
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
    }

    @ViewBuilder
    private func courseLabelText() -> some View {
        Text("Course", bundle: .core)
            .foregroundStyle(Color.textDark)
            .font(.regular14)
            .accessibilityHidden(true)
    }

    @ViewBuilder
    private func totalLabelText() -> some View {
        Text("Total", bundle: .core)
            .foregroundStyle(Color.textDark)
            .font(.regular14)
            .accessibilityHidden(true)
    }

    @ViewBuilder
    private func totalGradeText(_ totalGrade: String) -> some View {
        Text(totalGrade)
            .foregroundStyle(Color.textDarkest)
            .font(.semibold28)
            .accessibilityLabel(Text("Total grade is \(totalGrade)", bundle: .core))
            .accessibilityIdentifier("CourseTotalGrade")
    }

    @ViewBuilder
    private func courseNameText(_ courseName: String) -> some View {
        Text(courseName)
            .foregroundStyle(Color.textDarkest)
            .font(.semibold28)
            .accessibilityLabel(Text("\(courseName) course", bundle: .core))
            .fixedSize(horizontal: false, vertical: true)
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
    private func gradingPeriodMenu(
        gradingPeriods: [GradingPeriod],
        currentGradingPeriod: GradingPeriod?
    ) -> some View {
        Menu {
            Button {
                viewModel.selectedGradingPeriod.accept(nil)
            } label: {
                gradingAndArrangeText(title: String(localized: "All", bundle: .core))
            }
            ForEach(gradingPeriods) { gradingPeriod in
                if let title = gradingPeriod.title {
                    Button {
                        viewModel.selectedGradingPeriod.accept(gradingPeriod)
                    } label: {
                        gradingAndArrangeText(title: title)
                    }
                }
            }
        } label: {
            Label(
                title: {
                    if let title = currentGradingPeriod?.title {
                        gradingAndArrangeText(title: title)
                    } else {
                        gradingAndArrangeText(title: String(localized: "All", bundle: .core))
                    }
                },
                icon: { Image.arrowOpenDownSolid.resizable().frame(width: 12, height: 12) }
            ).labelStyle(HorizontalRightAlignedLabelStyle())
        }
        .accessibilityRemoveTraits(.isButton)
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    private func sortByMenu() -> some View {
        Menu {
            Button {
                viewModel.selectedGroupByOption.accept(.groupName)
            } label: {
                gradingAndArrangeText(title: String(localized: "By Group", bundle: .core))
            }
            Button {
                viewModel.selectedGroupByOption.accept(.dueDate)
            } label: {
                gradingAndArrangeText(title: String(localized: "By Due Date", bundle: .core))
            }
        } label: {
            Label(
                title: {
                    switch viewModel.selectedGroupByOption.value {
                    case .dueDate:
                        gradingAndArrangeText(title: String(localized: "Arrange By Due Date", bundle: .core))
                    case .groupName:
                        gradingAndArrangeText(title: String(localized: "Arrange By Group", bundle: .core))
                    }
                },
                icon: { Image.arrowOpenDownSolid.resizable().frame(width: 12, height: 12) }
            ).labelStyle(HorizontalRightAlignedLabelStyle())
        }
        .accessibilityRemoveTraits(.isButton)
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    private func gradingAndArrangeText(title: String) -> some View {
        Text(title)
            .foregroundStyle(Color(Brand.shared.primary))
            .font(.regular16)
    }

    @ViewBuilder
    private func assignmentListView(
        courseColor: UIColor?,
        assignmentSections: [GradeListData.AssignmentSections],
        userID: String
    ) -> some View {
        List {
            ForEach(assignmentSections) { section in
                Section(header: listSectionView(title: section.title)) {
                    ForEach(section.assignments) { assignment in
                        listRowView(
                            assignment: assignment,
                            userID: userID,
                            courseColor: courseColor
                        )
                    }
                }
                .listSectionSeparator(.hidden)
            }
        }
        .background(Color.backgroundLightest)
        .scrollContentBackground(.hidden)
        .listStyle(.plain)
    }

    @ViewBuilder
    private func listSectionView(title: String?) -> some View {
        Text(title ?? "")
            .foregroundStyle(Color.textDark)
            .font(.semibold14)
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity, minHeight: 35, alignment: .leading)
            .padding(.horizontal, -16)
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
        }
        .listRowInsets(EdgeInsets())
        .removeListRowSeparatorLeadingInset()
        .swipeActions(edge: .trailing) { revertWhatIfScoreSwipeButton() }
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

    @ViewBuilder
    private func revertWhatIfScoreSwipeButton() -> some View {
        if viewModel.isWhatIfScoreModeOn {
            Button {
                viewModel.isShowingRevertDialog = true
            } label: {
                Image(uiImage: .replyLine)
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundColor(Color.textLightest)
            }
            .tint(Color.backgroundDark)
        }
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
                        .foregroundColor(Color.white)
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
                router: PreviewEnvironment.shared.router
            )
        )
    }
}

#endif
